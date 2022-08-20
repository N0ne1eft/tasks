//
//  Todo.swift
//  Tasks
//
//  Created by N0ne1eft on 18/08/2022.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

enum TodoState {
    case InProgress
    case OverDue
    case Completed
}

extension Todo {
    
    func state() -> TodoState {
        if self.completed {return .Completed}
        if self.dateDue == nil {
            return .InProgress
        } else {
            return self.dateDue! < Date.now ? .OverDue : .InProgress
        }
    }
    
    func stateColor() -> Color {
        switch self.state() {
        case .InProgress: return .primary
        case .OverDue: return .orange
        case .Completed: return .gray
        }
    }
    
    func delete() {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(self)
        do {
            try viewContext.save()
        } catch {
            fatalError("Unable to save changes to Todo Store")
        }
    }
    
    func toggle() {
        let viewContext = PersistenceController.shared.container.viewContext
        self.completed.toggle()
        do {
            try viewContext.save()
        } catch {
            fatalError("Unable to save changes to Todo Store")
        }
    }
    
    func setupLocalNotification() {
        if self.dateDue == nil {return}
        let content = UNMutableNotificationContent()
    
        content.title = self.title ?? "Unnamed Task"
        content.body = self.taskDescription ?? "No description provided."
        
        let dateCompnents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: self.dateDue!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompnents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                notificationCenter.requestAuthorization(options: [.alert,.badge,.sound]) { granted, error in
                    if let error = error {
                        print("Unable to get notification authorization. \(error.localizedDescription)")
                    }
                }
            }
        }
        
        if self.notificationUUID != nil {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.notificationUUID!])
        }
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                fatalError("Unable to schedule notification.")
            }
        }
        
        self.notificationUUID = uuidString
        
    }
    
}
