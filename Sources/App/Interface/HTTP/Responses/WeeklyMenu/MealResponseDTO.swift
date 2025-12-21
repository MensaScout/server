//
//  MealResponseDTO.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

public struct MealResponseDTO: Content, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let price: PriceResponseDTO?

    public init(
        id: String,
        name: String,
        description: String?,
        price: PriceResponseDTO?
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
    }
}
