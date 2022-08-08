//
//  TodoCreationPopView.swift
//  Todo
//
//  Created by N0ne1eft on 29/07/2022.
//

import SwiftUI
import SymbolPicker

struct TodoCreationPopView: View {
    
    @State var title: String = ""
    @State var dateDue: Date = Date.now
    @State var dateDueEnabled = true
    @State var taskDescription: String = ""
    
    @State var iconPickerPresented = false
    @State var iconURL = "list.bullet"
    
    @State var currentSelectedProject: Project?
    @Binding var showPopover: Bool
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        predicate: NSPredicate(format: "archived == false"),
        animation: .default)
    var projects: FetchedResults<Project>
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    addItem()
                }
            HStack {
                #if os(iOS)
                DatePicker("Date Due", selection: $dateDue, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.automatic)
                #else
                DatePicker("Date Due", selection: $dateDue, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.stepperField)
                #endif
                Toggle("", isOn: $dateDueEnabled)
            }.foregroundColor(dateDueEnabled ? .primary : .gray)
            
            Picker("Project", selection: $currentSelectedProject) {
                Text("None").tag(nil as Project?)
                ForEach(getProjectsForSelection()) { project in
                    Text(project.name!).tag(project as Project?)
                }
            }
            
            Text("Description")
            TextEditor(text: $taskDescription)
                .lineLimit(5)
                .onSubmit {
                    addItem()
                }
            Text("Icon")
            Button( action: {
                iconPickerPresented = true
            }) {
                HStack {
                    Image(systemName: iconURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20, alignment: .center)
                        
                    Text(iconURL)
                }
            }
            .sheet(isPresented: $iconPickerPresented) {
                SymbolPicker(symbol: $iconURL)
            }
            .buttonStyle(.plain)
            
            HStack {
                Spacer()
                Button("Cancel") {
                    showPopover = false
                }
                Button("Done") {
                    addItem()
                }
            }
            
        }
        .padding(20)
        .frame(width: 400, height: 400, alignment: .leading)
    }
    
    private func addItem() {
        let viewContext = PersistenceController.shared.container.viewContext
        withAnimation {
            let todo = Todo(context: viewContext)
            todo.iconURL = iconURL
            todo.dateAdded = Date.now
            todo.title = title
            todo.taskDescription = taskDescription
            todo.project = currentSelectedProject
            if dateDueEnabled {
                todo.dateDue = dateDue
            }
            todo.completed = false
            
            do {
                todo.willSave()
                try viewContext.save()
                showPopover = false
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TodoCreationPopView_Previews: PreviewProvider {
    @State static var showPopover = true
    static var previews: some View {
        Group {
            TodoCreationPopView(showPopover: $showPopover)
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.dark)
        }
    }
}
