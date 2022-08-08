//
//  TasksApp.swift
//  Shared
//
//  Created by N0ne1eft on 29/07/2022.
//

import SwiftUI

@main
struct TasksApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            SidebarCommands()
        }
    }
}
