//
//  TodoView.swift
//  Counter
//
//  Created by N0ne1eft on 25/07/2022.
//

import SwiftUI
import CoreData

struct TodoView: View {
    
    @ObservedObject var todo: Todo
    
    private func deleteTodo(_ todo: Todo) {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(todo)
        do {
            try viewContext.save()
        } catch {
            fatalError("Unable to save changes to Todo Store")
        }
    }
    
    private func toggleTodo(_ todo: Todo) {
        let viewContext = PersistenceController.shared.container.viewContext
        todo.completed.toggle()
        do {
            try viewContext.save()
        } catch {
            fatalError("Unable to save changes to Todo Store")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: todo.iconURL ?? "checklist")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20, alignment: .leading)
                    
                VStack(alignment: .leading) {
                    HStack {
                        Text(todo.title ?? "")
                            .font(.title2)
                    }
                    HStack {
                        Text((todo.project == nil ? "No Project" : todo.project!.name)!)
                            .font(.footnote)
                        Text("")
                        Text(todo.taskDescription ?? "")
                            .font(.footnote)
                    }
                }.foregroundColor(todo.completed ? .gray : .white)
                
                Spacer()
                
                if todo.dateDue != nil {
                    VStack {
                        Text( todo.dateDue!.formatted(.dateTime.hour().minute()) )
                            .font(.title2)
                        Text( todo.dateDue!.formatted(.dateTime.day().month()) )
                            .font(.footnote)
                    }
                }
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                toggleTodo(todo)
            } label: {
                if todo.completed {
                    Label("Untag as completed", systemImage: "arrow.clockwise.circle.fill")
                } else {
                    Label("Mark as finished", systemImage: "arrow.right.to.line.circle.fill")
                }
                            }
            .tint(todo.completed ? .yellow : .green)
        }
        .swipeActions(edge: .trailing) {
            Button {
                withAnimation {
                    deleteTodo(todo)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let newTodo: Todo = {
            let newTodo = Todo.init(context: context)
            let newProject = Project.init(context: context)
            newProject.name = "Project Name"
            newProject.iconURL = "list.bulletin"
            newProject.archived = false
            newTodo.dateDue = Date.now
            newTodo.dateAdded = Date.now
            newTodo.iconURL = "checklist"
            newTodo.taskDescription = "Task descrption goes here"
            newTodo.title = "Example Task"
            //newProject.addToTodos(newTodo)
            return newTodo
        }()
        TodoView(todo: newTodo)
            .environment(\.managedObjectContext, context)
    }
}
