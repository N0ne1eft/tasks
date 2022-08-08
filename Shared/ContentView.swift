//
//  ContentView.swift
//  Tasks
//
//  Created by N0ne1eft on 28/07/2022.
//

import SwiftUI
import CoreData

enum Filter: String, CaseIterable, Identifiable {
    case All, Todo, Completed
    var id: Self { self }
}


struct ContentView: View {
    @State var selectedProject: Project? = nil
    @State var selectedTodo: Todo? = nil
    var body: some View {
        
        NavigationView {
            
            ProjectSideBarView()
            
            TodoProjectView()
            
            TodoDetailView()
            
        }.navigationTitle("Todos")
            .toolbar {
                #if(os(macOS))
                ToolbarItem(placement: .navigation) {
                    Button {
                        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    } label: {
                        Label("Toggle Sidebar", systemImage: "sidebar.left")
                    }
                }
                #endif
            }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .previewDevice("iPhone 12 Pro Max")
            .preferredColorScheme(.dark)
    }
}
