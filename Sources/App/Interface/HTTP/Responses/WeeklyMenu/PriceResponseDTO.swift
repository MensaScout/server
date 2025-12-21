//
//  PriceResponseDTO.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

public struct PriceResponseDTO: Content, Sendable {
    public let amount: String
    public let currency: String

    public init(amount: String, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}
