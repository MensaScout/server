//
//  CanteenResponseDTO.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

public struct CanteenResponseDTO: Content, Sendable {
    public let id: String
    public let name: String
    public let operatorName: String
    public let address: AddressResponseDTO

    public init(
        id: String,
        name: String,
        operatorName: String,
        address: AddressResponseDTO
    ) {
        self.id = id
        self.name = name
        self.operatorName = operatorName
        self.address = address
    }
}
