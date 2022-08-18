//
//  Todo.swift
//  Tasks
//
//  Created by N0ne1eft on 18/08/2022.
//

import Foundation
import CoreData
import UserNotifications

extension Todo {
    
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
