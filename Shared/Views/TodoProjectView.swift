//
//  TodoProjectView.swift
//  Tasks
//
//  Created by N0ne1eft on 05/08/2022.
//

import SwiftUI
import CoreData

struct TodoProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var showPopover: Bool = false
    var project: Project?

    @State private var selectedFilter: Filter = .Todo
    @StateObject var viewUpdater = ViewUpdater()

    private func getTargetFilteredResult() -> [Todo] {
        let fetchRequest: NSFetchRequest<Todo>
        fetchRequest = Todo.fetchRequest()
        do {
            switch selectedFilter {
            case .All:
                if project != nil {
                    fetchRequest.predicate = NSPredicate(format: "project == %@", project!)
                }
                return try viewContext.fetch(fetchRequest)
            case .Todo:
                fetchRequest.predicate = project != nil ? NSPredicate(format: "project == %@ && completed == false", project!) : NSPredicate(format:"completed == false")
                return try viewContext.fetch(fetchRequest)
            case .Completed:
                fetchRequest.predicate = project != nil ? NSPredicate(format: "project == %@ && completed == true", project!) : NSPredicate(format:"completed == true")
                return try viewContext.fetch(fetchRequest)
            }
        } catch {
            fatalError("Unable to fetch todos")
        }
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag(Filter.All)
                Text("Todo").tag(Filter.Todo)
                Text("Completed").tag(Filter.Completed)
            }.pickerStyle(.segmented)
            List {
                ForEach (getTargetFilteredResult()) { todo in
                    NavigationLink {
                        TodoDetailView(todo: todo)
                    } label: {
                        TodoView(todo: todo)
                    }
                }
            }
            Spacer()
            HStack {
                Button {
                    showPopover = true
                } label: {
                    Image(systemName: "note.text.badge.plus")
                        .resizable()
                        .onTapGesture {
                            showPopover = true
                        }
                        .sheet(isPresented: $showPopover) {
                            TodoCreationPopView(currentSelectedProject: project, showPopover: $showPopover)
                        }
                        .frame(width:15, height: 15)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: [.command])
            }
        }.frame(minWidth: 600, idealWidth: 700, minHeight: 500, idealHeight: 600, alignment: .topLeading)
            .padding(10)
    }
}

struct TodoProjectView_Previews: PreviewProvider {
    static var previews: some View {
        TodoProjectView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)

            .preferredColorScheme(.dark)
    }
}
