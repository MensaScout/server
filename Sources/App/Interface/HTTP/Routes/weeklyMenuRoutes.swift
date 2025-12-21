//
//  File.swift
//  server
//
//  Created by Lars Winzer on 21.12.25.
//

import Vapor

func weeklyMenuRoutes(_ app: Application) {
    let controller = WeeklyMenuController()

    app.get("weekly-menu") { req async throws in
        try await controller.getWeeklyMenu(req)
    }
}
