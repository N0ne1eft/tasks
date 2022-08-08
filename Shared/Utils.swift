//
//  Utils.swift
//  Tasks
//
//  Created by N0ne1eft on 08/08/2022.
//

import Foundation
import CoreData

public func getProjectsForSelection() -> [Project] {
    let fetchRequest = Project.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "archived == false")
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Project.name, ascending: true)]
    do {
        return try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
    } catch {
        fatalError("Unable to fetch projects")
    }
}
