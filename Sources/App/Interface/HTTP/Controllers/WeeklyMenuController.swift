//
//  WeeklyMenuController.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

struct WeeklyMenuController {

    func getWeeklyMenu(_ req: Request) async throws -> WeeklyMenuResponseDTO {
        let domainMenu = mockWeeklyMenu()
        return WeeklyMenuResponseMapper.map(domainMenu)
    }
}

private extension WeeklyMenuController {

    func mockWeeklyMenu() -> WeeklyMenu {
        let `operator` = CanteenOperator(
            id: UUID(),
            name: "ZFV"
        )

        let address = Address(
            street: "Klingelbergstrasse 48",
            postalCode: "4056",
            city: "Basel",
            country: "CH"
        )

        let canteen = Canteen(
            id: UUID(),
            name: "Flavour Kitchen",
            operator: `operator`,
            address: address
        )

        let meal_monday_1 = Meal(
            id: UUID(),
            name: "Pasta all’arrabbiata & Meatballs",
            description: "Pasta / mini Rindsmeatballs / All’arrabbiata-Sauce",
            price: Price(amount: 14.0, currency: "CHF")
        )
        
        let meal_monday_2 = Meal(
            id: UUID(),
            name: "Randenfalafel & Zitronenjoghurt",
            description: "Randenfalafel / Zitronenjoghurt mit Granatapfelkernen / Kartoffel- Petersilienwurzstock / Kefen / Knackerbsen",
            price: Price(amount: 14.0, currency: "CHF")
        )
        
        let meal_monday_3 = Meal(
            id: UUID(),
            name: "Lachs & Zitronenjoghurt",
            description: "Lachssteak / Zitronenjoghurt mit Granatapfelkernen / Kartoffel- Petersilienwurzstock / Kefen / Knackerbsen",
            price: Price(amount: 14.0, currency: "CHF")
        )
        
        let meal_tuesday_1 = Meal(
            id: UUID(),
            name: "Pasta mit Rauchlachs",
            description: "«Flavour-Kitchen» Pasta / Rauchlachs / Lauch / Dill / Rahmsauce",
            price: Price(amount: 14.0, currency: "CHF")
        )
        
        let meal_tuesday_2 = Meal(
            id: UUID(),
            name: "Seitangulasch & Polenta",
            description: "Seitan Gulasch Ungarische Art / Peperoni / Zwiebel / Polenta / Mascarpone / weihnachtliches Gemüse",
            price: Price(amount: 14.0, currency: "CHF")
        )
        
        let meal_tuesday_3 = Meal(
            id: UUID(),
            name: "Weihnachtmenü",
            description: "Kalbsschulterbraten glasiert / Jus mit Thymian / Butternudeln / weihnachtliches Gemüse",
            price: Price(amount: 14.0, currency: "CHF")
        )

        return WeeklyMenu(
            canteen: canteen,
            mealsByDay: [
                .monday: [meal_monday_1, meal_monday_2, meal_monday_3],
                .tuesday: [meal_tuesday_1, meal_tuesday_2, meal_tuesday_3]
            ]
        )
    }
}
