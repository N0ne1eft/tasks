//
//  ViewUpdater.swift
//  Tasks
//
//  Created by N0ne1eft on 30/07/2022.
//

import Foundation

class ViewUpdater : ObservableObject {
    
    @Published var status = false
    var timer: Timer?
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            self.status.toggle()
        })
    }
    deinit {
        timer?.invalidate()
    }
}
