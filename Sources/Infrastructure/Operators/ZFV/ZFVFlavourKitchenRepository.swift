import Foundation
import Vapor

struct ZFVFlavourKitchenRepositoryKey: StorageKey {
    typealias Value = ZFVFlavourKitchenRepository
}


final class ZFVFlavourKitchenRepository: @unchecked Sendable {
    private let client: GraphQLClient

    init(client: GraphQLClient) {
        self.client = client
    }
    
    func weeklyMenu() async throws -> any Decodable {
        let variables = WeeklyMenuItemsQuery.Variables(
            outletId: "cm1tjb2tn00t572q4mm5oful4",
            categoryId: "cm1tnf9esgu3pdvufinviemvr"
        )
        
        let result = try await client.execute(
            query: WeeklyMenuItemsQuery.query,
            variables: variables.toVariables(),
            responseType: WeeklyMenuItemsQuery.Response.self
        )
        return result
    }
}


enum WeeklyMenuItemsQuery {
    static let query = """
        query GetDishesForMenuCategoryFlavourKitchen($outletId: String!, $categoryId: String!) {
            outlet(where: {id: $outletId}) {
                calendar {
                week {
                    menuCategory(categoryId: $categoryId) {
                    daily {
                        menuItems {
                        prices {
                            menuPriceCategory {
                            name
                            }
                            amount
                            currency
                        }
                        category {
                            name
                        }
                        ... on OutletMenuItemDish {
                            dish {
                            id
                            name
                            media {
                                media {
                                url
                                }
                            }
                            allergens {
                                allergen {
                                name
                                tenantId
                                externalId
                                }
                            }
                            originDeclaration
                            isVegan
                            isVegetarian
                            createdAt
                            updatedAt
                            offeredFrom
                            offeredTo
                            stats {
                                weightScaleFactor
                                servingCount
                                servingWeight {
                                amount
                                unit
                                }
                                totalWeight {
                                amount
                                unit
                                }
                                defaultServingWeight {
                                amount
                                unit
                                }
                                co2Emissions {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                energy {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                fat {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                carbohydrates {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                sugar {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                protein {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                salt {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                fibers {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                fruits {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                                vegetables {
                                unit
                                amountPer100g
                                amount
                                amountPerServing
                                }
                            }
                            }
                        }
                        }
                        date {
                        dateLocal
                        weekday
                        }
                    }
                    }
                    kitchenHours {
                    isOpen
                    entriesOpen {
                        from {
                        dateUtc
                        }
                        to {
                        dateUtc
                        }
                    }
                    }
                    outlet {
                    id
                    tenantId
                    slug
                    menuPriceCategories {
                        name
                    }
                    }
                }
                }
                location {
                address {
                    zipCode
                    city
                    addressLine1
                    addressLine2
                    country
                }
                }
            }
        }
        """
    
    struct Variables: Encodable {
        let outletId: String
        let categoryId: String
        
        func toVariables() -> [GraphQLVariable] {
            return [
                GraphQLVariable(
                    name: "outletId",
                    value: outletId
                ),
                GraphQLVariable(
                    name: "categoryId",
                    value: categoryId
                )
            ]
        }
    }
    
    struct Response: Decodable {
        let location: String?
        let calendar: CalendarContainer
    }
}

extension WeeklyMenuItemsQuery {
    struct Outlet: Decodable {
        let location: String?
        let calendar: CalendarContainer
    }

    struct CalendarContainer: Decodable {
        let week: Week
    }
    
    struct Week: Decodable {
        let openingHours: OpeningHours
        let stats: [StatsEntry]
        let statsTotal: StatsTotal
        let menuCategory: MenuCategory
        let kitchenHours: KitchenHours
        let outlet: WeekOutlet
    }
    
    struct OpeningHours: Codable {
        let entriesOpen: [OpeningEntry]
    }

    struct KitchenHours: Codable {
        let isOpen: Bool
        let entriesOpen: [OpeningEntry]
    }

    struct OpeningEntry: Codable {
    }
    
    struct StatsEntry: Codable {
        let date_from: DateWrapper
        let date_to: DateWrapper
        let energyTotal: Int
        let co2Emissions: Int
        let co2EnergyImpactNumerator: Double
        let countDishes: Int
    }

    struct StatsTotal: Codable {
        let date_from: DateWrapper
        let date_to: DateWrapper
        let energyTotal: Int
        let co2Emissions: Int
        let co2EnergyImpactNumerator: Double
        let countDishes: Int
    }

    struct DateWrapper: Codable {
        let dateUtc: String
    }
    
    struct MenuCategory: Codable {
        let category: Category
        let daily: [DailyMenu]
    }

    struct Category: Codable {
        let name: String
    }

    struct DailyMenu: Codable {
        let menuItems: [MenuItem]
        let date: MenuDate
    }

    struct MenuDate: Codable {
        let dateLocal: String
        let weekday: String
    }
    
    struct MenuItem: Codable {
        let prices: [Price]
        let category: Category
        let dish: Dish
    }

    struct Price: Codable {
        let menuPriceCategory: PriceCategory
        let amount: String
        let currency: String
    }

    struct PriceCategory: Codable {
        let name: String
    }
    
    struct Dish: Codable {
        let id: String
        let name: String
        let media: [DishMedia]
        let allergens: [DishAllergen]
        let originDeclaration: String?
        let isVegan: Bool
        let isVegetarian: Bool
        let createdAt: String
        let updatedAt: String
        let offeredFrom: String
        let offeredTo: String
    }

    struct DishMedia: Codable {
        let media: Media
    }

    struct Media: Codable {
        let url: String
    }

    struct DishAllergen: Codable {
        let allergen: Allergen
    }

    struct Allergen: Codable {
        let name: String
        let tenantId: String
        let externalId: String
    }
    
    struct WeekOutlet: Codable {
        let id: String
        let tenantId: String
        let slug: String
        let menuPriceCategories: [PriceCategory]
    }
}
