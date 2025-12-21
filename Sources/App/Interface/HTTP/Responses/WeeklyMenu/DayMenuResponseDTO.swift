//
//  DayMenuResponseDTO.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

public struct DayMenuResponseDTO: Content, Sendable {
    public let weekday: String
    public let meals: [MealResponseDTO]

    public init(weekday: String, meals: [MealResponseDTO]) {
        self.weekday = weekday
        self.meals = meals
    }
}
