//
//  Revision_CalendarApp.swift
//  Revision Calendar
//
//  Created by Tadeáš Juříček on 04.01.2026.
//

import SwiftUI

@main
struct Revision_CalendarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
        }

    }
}
