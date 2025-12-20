//
//  WeeklyMenuRepository.swift
//  server
//
//  Created by Lars Winzer on 20.12.25.
//

protocol WeeklyMenuRepository {
    func loadWeeklyMenus() async throws -> [WeeklyMenu]
}
