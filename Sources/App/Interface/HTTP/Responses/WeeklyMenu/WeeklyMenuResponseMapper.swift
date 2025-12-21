//
//  WeeklyMenuResponseMapper.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Foundation

struct WeeklyMenuResponseMapper {

    static func map(_ menu: WeeklyMenu) -> WeeklyMenuResponseDTO {
        WeeklyMenuResponseDTO(
            canteen: map(menu.canteen),
            days: menu.mealsByDay
                .sorted { $0.key.rawValue < $1.key.rawValue }
                .map { map(day: $0.key, meals: $0.value) }
        )
    }
}


private extension WeeklyMenuResponseMapper {

    static func map(_ canteen: Canteen) -> CanteenResponseDTO {
        CanteenResponseDTO(
            id: canteen.id.uuidString,
            name: canteen.name,
            operatorName: canteen.operator.name,
            address: map(canteen.address)
        )
    }

    static func map(_ address: Address) -> AddressResponseDTO {
        AddressResponseDTO(
            street: address.street,
            postalCode: address.postalCode,
            city: address.city,
            country: address.country
        )
    }

    static func map(day: Weekday, meals: [Meal]) -> DayMenuResponseDTO {
        DayMenuResponseDTO(
            weekday: String(describing: day),
            meals: meals.map(map)
        )
    }

    static func map(_ meal: Meal) -> MealResponseDTO {
        MealResponseDTO(
            id: meal.id.uuidString,
            name: meal.name,
            description: meal.description,
            price: map(meal.price)
        )
    }

    static func map(_ price: Price) -> PriceResponseDTO {
        PriceResponseDTO(
            amount: price.amount.description,
            currency: price.currency
        )
    }
}
