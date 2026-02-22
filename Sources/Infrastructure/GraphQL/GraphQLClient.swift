import Vapor

final class GraphQLClient: @unchecked Sendable {
    private let baseURL: URI
    private let httpClient: any Client
    private let authentication: (any APIAuthentication)?

    init(
        baseURL: URI,
        httpClient: any Client,
        authentication: (any APIAuthentication)? = nil
    ) {
        self.baseURL = baseURL
        self.httpClient = httpClient
        self.authentication = authentication
    }
}


extension GraphQLClient {
    func execute<Response: Decodable>(
        query: String,
        variables: [GraphQLVariable],
        responseType: Response.Type
    ) async throws -> Response {
        let request = buildRequest(query: query, variables: variables)
        
        // Create the request context
        var context = GraphQLExecutionContext(request: request)
        
        // Execute request
        let clock = ContinuousClock()
        let start = clock.now
        let response: ClientResponse
        do {
            response = try await executeRequest(request: request)
        } catch {
            throw GraphQLTransportError(
                request: context.request,
                underlyingError: error
            )
        }
        context.response = response
        context.latency = clock.now - start
        
        // Handle HTTP error
        guard (200..<300).contains(response.status.code) else {
            throw GraphQLHTTPStatusError(
                request: context.request,
                response: context.response,
                statusCode: Int(response.status.code)
            )
        }
        
        guard let buffer = response.body else {
            throw GraphQLEmptyResponseBodyError(
                request: context.request,
                response: context.response
            )
        }
        
        // Decode response to provided Decodable
        let decoded: GraphQLResponse<Response>
        do {
            decoded = try JSONDecoder().decode(
                GraphQLResponse<Response>.self,
                from: buffer
            )
            dump(decoded)
        } catch {
            throw GraphQLDecodingError(
                request: context.request,
                response: context.response,
                underlyingError: error
            )
        }

        // Fail if data field of response is nil
        guard let data = decoded.data else {
            throw GraphQLResponseError(
                request: context.request,
                response: context.response
            )
        }
        
        return data
    }
    
    func buildRequest(
        query: String,
        variables: [GraphQLVariable],
    ) -> HTTPRequest {
        var request = HTTPRequest(url: baseURL, headers: HTTPHeaders())
        // Encode provided variables as dictionary
        let encodedVariables: [String: String]? = if variables.isEmpty {
            nil
        } else {
            Dictionary (
                uniqueKeysWithValues: variables.map {
                    ($0.name, $0.value)
                }
            )
        }
        request.body = GraphQLBody(
                query: query,
                variables: encodedVariables
            )
        
        // Add headers
        request.headers.add(name: .contentType, value: "application/json")
        authentication?.apply(to: &request.headers)
        
        return request
    }
    
    func executeRequest(request: HTTPRequest) async throws -> ClientResponse {
        try await httpClient.post(request.url, headers: request.headers) {
                $0.body = .init(
                    data: try JSONEncoder().encode(request.body)
                )
            }
    }
        }
        
// Structs used for the request and response itself
struct HTTPRequest {
    let url: URI
    var headers: HTTPHeaders
    var body: GraphQLBody?
}

struct GraphQLVariable {
    let name: String
    let value: String
}

struct GraphQLBody: Encodable {
    let query: String
    let variables: [String : String]?
}

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

// Error structs
struct GraphQLError: Decodable {
    let message: String
    let locations: [Location]?
    let path: [String]?

    struct Location: Decodable {
        let line: Int
        let column: Int
    }
}

protocol GraphQLClientError: Error {}

struct GraphQLTransportError: GraphQLClientError {
    let request: HTTPRequest
    let underlyingError: any Error
}

struct GraphQLHTTPStatusError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
    let statusCode: Int
}

struct GraphQLEmptyResponseBodyError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
}

struct GraphQLDecodingError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
    let underlyingError: any Error
}

struct GraphQLResponseError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
}

struct GraphQLExecutionContext {
    let request: HTTPRequest
    var response: ClientResponse!
    var latency: Duration!
}
