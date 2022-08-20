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
                }
                
                Spacer()
                
                if todo.dateDue != nil {
                    VStack(alignment: .trailing) {
                        Text(humanReadableTimeDiff(todo.dateDue!, Date.now))
                            .font(.title2)
                        HStack {
                            Text( todo.dateDue!.formatted(.dateTime.hour().minute()) )
                                .font(.footnote)
                            Text( todo.dateDue!.formatted(.dateTime.day().month()) )
                                .font(.footnote)
                        }
                    }
                }
            }
        }
        .foregroundColor(todo.stateColor())
        .swipeActions(edge: .leading) {
            Button {
                todo.toggle()
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
                    todo.delete()
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
