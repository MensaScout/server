//
//  Meal.swift
//  server
//
//  Created by Lars Winzer on 20.12.25.
//

import Foundation

struct Meal {
    let id: UUID
    let name: String
    let description: String?
    let weekday: Weekday
    let price: Price
}
