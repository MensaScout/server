//
//  WeeklyMenu.swift
//  server
//
//  Created by Lars Winzer on 20.12.25.
//

import Foundation

struct WeeklyMenu {
    let canteen: Canteen
    let mealsByDay: [Weekday: [Meal]]
}
