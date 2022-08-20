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

public func humanReadableTimeDiff(_ d1: Date, _ d2: Date) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day,.hour,.minute]
    formatter.unitsStyle = .abbreviated
    let prefix = d1 > d2 ? "In " : ""
    let postfix = d1 < d2 ? " ago" : ""
    return prefix + (formatter.string(from: d1.distance(to: d2)) ?? "") + postfix
}
