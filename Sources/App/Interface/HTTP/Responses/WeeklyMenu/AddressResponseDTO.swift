//
//  AddressResponseDTO.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

public struct AddressResponseDTO: Content, Sendable {
    public let street: String
    public let postalCode: String
    public let city: String
    public let country: String

    public init(
        street: String,
        postalCode: String,
        city: String,
        country: String
    ) {
        self.street = street
        self.postalCode = postalCode
        self.city = city
        self.country = country
    }
}
