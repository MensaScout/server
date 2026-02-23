//
//  Transport.swift
//  server
//
//  Created by Lars Winzer on 23.02.26.
//

import Vapor

protocol GraphQLTransport {
    func execute(_ request: HTTPRequest) async throws -> ClientResponse
}

final class VaporGraphQLTransport: GraphQLTransport {
    private let client: any Client

    init(client: any Client) {
        self.client = client
    }

    func execute(_ request: HTTPRequest) async throws -> ClientResponse {
        try await client.post(request.url, headers: request.headers) {
            $0.body = .init(
                data: try JSONEncoder().encode(request.body)
            )
        }
    }
}
