//
//  ProjectSideBarView.swift
//  Tasks
//
//  Created by N0ne1eft on 05/08/2022.
//

import SwiftUI
import CoreData

struct ProjectSideBarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        predicate: NSPredicate(format: "archived == false"),
        animation: .default
    )
    private var activeProjects: FetchedResults<Project>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        predicate: NSPredicate(format: "archived == true"),
        animation: .default
    )
    private var archivedProjects: FetchedResults<Project>
    
    @State var showProjectCreationPopover = false
    @State var showProjectDeletionDialog = false
    @State var projectAwaitingDeletion: Project? = nil
    
    var body: some View {
        VStack {
            List {
                NavigationLink {
                    TodoProjectView(project: nil)
                } label: {
                    VStack(alignment: .leading) {
                        Text("ALL")
                            .font(.system(size: 25.0, weight: .bold, design: .default))
                        Text("TASKS")
                            .font(.system(size: 10.0, weight: .bold, design: .default))
                    }
                }
                Text("")
                VStack(alignment: .leading) {
                    Text("ACTIVE")
                        .font(.system(size: 25.0, weight: .bold, design: .default))
                    Text("PROJECTS")
                        .font(.system(size: 10.0, weight: .bold, design: .default))
                }
                .foregroundColor(.gray)
                ForEach(activeProjects) { project in
                    NavigationLink {
                        TodoProjectView(project: project)
                    } label: {
                        Text(project.name!)
                    }
                    .contextMenu {
                        Button("Delete") {
                            projectAwaitingDeletion = project
                            showProjectDeletionDialog = true
                        }
                        Button("Archive") {
                            withAnimation {
                                project.archived = true
                                do {try viewContext.save()} catch {fatalError("Archive project failed.")}
                            }
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Text("")
                    Text("ARCHIVED")
                        .font(.system(size: 25.0, weight: .bold, design: .default))
                    Text("PROJECTS")
                        .font(.system(size: 10.0, weight: .bold, design: .default))
                }
                .foregroundColor(.gray)
                ForEach(archivedProjects) { project in
                    NavigationLink {
                        TodoProjectView(project: project)
                    } label: {
                        Text(project.name!)
                    }
                    .contextMenu {
                        Button("Delete") {
                            projectAwaitingDeletion = project
                            showProjectDeletionDialog = true
                        }
                        Button("Unarchive") {
                            withAnimation {
                                project.archived = false
                                do {try viewContext.save()} catch {fatalError("Unarchive project failed.")}
                            }
                        }
                    }
                }
            }
            .confirmationDialog("Do you wish to delete todos under this project?", isPresented: $showProjectDeletionDialog) {
                Button("Unassign project from todo", role:.destructive) {
                    deleteProject(deleteTasks: false)
                }
                Button("Delete All", role:.destructive) {
                    deleteProject(deleteTasks: true)
                }
                Button("Cancel", role: .cancel, action: {})
            }
            Spacer()
            HStack {
                Button {
                    showProjectCreationPopover.toggle()
                } label: {
                    Image(systemName: "plus.app")
                        .resizable()
                        .onTapGesture {
                            showProjectCreationPopover.toggle()
                        }
                        .sheet(isPresented: $showProjectCreationPopover) {
                            ProjectCreationView(currentWindowPopupStatus: $showProjectCreationPopover)
                        }
                        .frame(width: 15, height: 15)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: [.shift, .command])
                Button {
                    
                } label: {
                    Image(systemName: "timer")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                Spacer()
            }.padding(10)
        }
    }
    
    private func deleteProject(deleteTasks: Bool) {
        guard projectAwaitingDeletion != nil else {
            return
        }
        withAnimation {
            if deleteTasks {
                for todo in projectAwaitingDeletion!.todos!.allObjects {
                    if let todo = todo as? Todo {
                        viewContext.delete(todo)
                    }
                }
            } else {
                for todo in projectAwaitingDeletion!.todos!.allObjects {
                    if let todo = todo as? Todo {
                        todo.project = nil
                    }
                }
            }
            viewContext.delete(projectAwaitingDeletion!)
            projectAwaitingDeletion = nil
            do {
                try viewContext.save()
            } catch {
                fatalError("Unable to delete project")
            }
        }

    }
    
}

struct ProjectSideBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectSideBarView()
    }
}
