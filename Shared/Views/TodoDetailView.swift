//
//  TodoDetailView.swift
//  Tasks
//
//  Created by N0ne1eft on 05/08/2022.
//

import SwiftUI

struct TodoDetailView: View {
    
    @State var todo: Todo?
    
    @State var title = ""
    @State var showTitleEditor = false
    
    @State var date = Date.now
    @State var showDateEditor = false
    
    @State var taskDescription = ""
    @State var showTaskDescription = false
    
    @State var project: Project? = nil as Project?
    @State var showProjectSelector = false
    
    @State var showEditingView = false
    
    var body: some View {
        if todo == nil {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                
                
                if !showEditingView {
                    Text(todo!.title ?? "")
                        .font(.largeTitle)
                        .onTapGesture {
                            populateEditView()
                        }
                } else {
                    TextField("Title", text: $title)
                        .onChange(of: title) { title in
                            todo!.title = title
                            saveContext()
                        }
                }
                
                if !showEditingView {
                    Text((todo!.taskDescription == "" ? "No Description Provided" : todo!.taskDescription)!)
                        .font(.body)
                        .onTapGesture {
                            populateEditView()
                        }
                        //
                } else {
                    TextEditor(text: $taskDescription)
                        .frame(height: 200)
                        .onChange(of: taskDescription) { taskDescription in
                            todo!.taskDescription = taskDescription
                            saveContext()
                        }
                }
                
                if !showEditingView {
                    Text(todo!.dateDue?.formatted() ?? "No Due Date")
                        .font(.title3)
                        .onTapGesture {
                            populateEditView()
                        }
                        .padding(EdgeInsets(top:1, leading: 0, bottom: 1, trailing: 0))
                } else {
                    DatePicker("Date due", selection: $date)
                        .onChange(of: date) { date in
                            todo!.dateDue = date
                            saveContext()
                        }
                        .pickerStyle(.menu)
                }
                
                if !showEditingView {
                    Text(todo!.project != nil ? todo!.project!.name ?? "" : "No Project Assigned")
                        .font(.title3)
                        .onTapGesture {
                            populateEditView()
                        }
                } else {
                    Picker("Project", selection: $project) {
                        Text("None").tag(nil as Project?)
                        ForEach(getProjectsForSelection()) { project in
                            Text(project.name ?? "").tag(project as Project?)
                        }
                    }
                    .onChange(of: project) { project in
                        todo!.project = project
                        saveContext()
                    }
                }
                
                if showEditingView {
                    Button("Done") {
                        todo!.setupLocalNotification()
                        saveContext()
                        showEditingView = false
                    }
                }
                Spacer()
            }
            .frame(minWidth: 200, idealWidth: 200, maxWidth: 300, alignment: .leading)
            .padding(20)
        }
    }
    
    private func populateEditView() {
        title = todo!.title ?? ""
        date = todo!.dateDue ?? Date.now
        taskDescription = todo!.taskDescription ?? ""
        project = todo!.project
        showEditingView = true
    }
    
    private func saveContext() {
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            fatalError("Unable to update todo")
        }
    }
}

struct TodoDetailView_Previews: PreviewProvider {
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
        TodoDetailView(todo: newTodo)
    }
}
