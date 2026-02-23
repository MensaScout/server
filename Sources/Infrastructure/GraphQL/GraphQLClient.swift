import Vapor

final class GraphQLClient: @unchecked Sendable {
    private let baseURL: URI
    private let transport: any GraphQLTransport
    private let authentication: (any APIAuthentication)?

    init(
        baseURL: URI,
        transport: any GraphQLTransport,
        authentication: (any APIAuthentication)? = nil
    ) {
        self.baseURL = baseURL
        self.transport = transport
        self.authentication = authentication
    }
}


extension GraphQLClient {
    func execute<Response: Decodable>(
        query: String,
        variables: [GraphQLVariable],
        decoder: JSONDecoder,
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
            response = try await transport.execute(request)
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
            decoded = try decoder.decode(
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

        // Fail if GraphQL response contains errors or no data is returned
        if let errors = decoded.errors, !errors.isEmpty {
            throw GraphQLExecutionError(
                request: context.request,
                response: context.response,
                responseError: errors
            )
        }
        
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

/// Generic class all errors related to the GraphQL client inherit from
protocol GraphQLClientError: Error {}

/// Error thrown during execution of the request
struct GraphQLTransportError: GraphQLClientError {
    let request: HTTPRequest
    let underlyingError: any Error
}

/// Error thrown while reading the response if the HTTP status code is not 200
struct GraphQLHTTPStatusError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
    let statusCode: Int
}

/// Error thrown while reading the request if the response body is nil
struct GraphQLEmptyResponseBodyError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
}

/// Error thrown if decoding of the response into GraphQLResponse struct fails
struct GraphQLDecodingError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
    let underlyingError: any Error
}

/// Error thrown if GraphQL response does not contain data field
struct GraphQLResponseError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
}

/// Error thrown if GraphQL response contains errors
struct GraphQLExecutionError: GraphQLClientError {
    let request: HTTPRequest
    let response: ClientResponse
    let responseError: [GraphQLError]
}

// Internal execution context
struct GraphQLExecutionContext {
    let request: HTTPRequest
    var response: ClientResponse!
    var latency: Duration!
}
