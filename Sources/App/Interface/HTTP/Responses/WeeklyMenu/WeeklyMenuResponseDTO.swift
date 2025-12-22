//
//  WeeklyMenuResponseDTO.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

public struct WeeklyMenuResponseDTO: Content, Sendable {
    public let canteen: CanteenResponseDTO
    public let days: [DayMenuResponseDTO]

    public init(canteen: CanteenResponseDTO, days: [DayMenuResponseDTO]) {
        self.canteen = canteen
        self.days = days
    }
}
