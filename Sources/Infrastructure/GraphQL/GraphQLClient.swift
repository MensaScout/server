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
        let encodedVariables: [String: String]? = if variables.isEmpty {
            nil
        } else {
            Dictionary (
                uniqueKeysWithValues: variables.map {
                    ($0.name, $0.value)
                }
            )
        }
        
        let body = try JSONEncoder().encode(
            GraphQLBody(
                query: query,
                variables: encodedVariables
            )
        )
        
        // Add headers
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        authentication?.apply(to: &headers)
        
        // Execute request
        let response: ClientResponse
        do {
            response = try await httpClient.post(baseURL, headers: headers) {
                $0.body = .init(data: body)
            }
        } catch {
            throw GraphQLClientError.transport(error)
        }
        
        // Fail if http code not in valid range
        guard (200..<300).contains(response.status.code) else {
            throw GraphQLClientError.httpStatus(Int(response.status.code))
        }
        
        // Fail if response body is nil
        guard let buffer = response.body else {
            throw GraphQLClientError.invalidResponse
        }
        
        // Decode response to provided Decodable
        let decoded = try JSONDecoder().decode(
            GraphQLResponse<Response>.self,
            from: buffer
        )
        
        // Fail if response contains errors
        if let errors = decoded.errors, !errors.isEmpty {
            throw GraphQLClientError.graphql(errors)
        }
        
        // Fail if data field of response is nil
        guard let data = decoded.data else {
            throw GraphQLClientError.invalidResponse
        }
        
        return data
    }
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

struct GraphQLError: Decodable {
    let message: String
    let locations: [Location]?
    let path: [String]?

    struct Location: Decodable {
        let line: Int
        let column: Int
    }
}

enum GraphQLClientError: Error {
    case transport(any Error)
    case httpStatus(Int)
    case graphql([GraphQLError])
    case invalidResponse
}
