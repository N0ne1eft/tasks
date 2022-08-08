//
//  ProjectCreationView.swift
//  Tasks
//
//  Created by N0ne1eft on 04/08/2022.
//

import SwiftUI
import SymbolPicker

struct ProjectCreationView: View {
    @State var newProjectName: String = ""
    @State var newProjectIconURL: String = "list.bullet"
    @State var iconPickerPresented = false
    @Binding var currentWindowPopupStatus: Bool
    var viewContext = PersistenceController.shared.container.viewContext
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Name new project:")
            HStack {
                Image(systemName: newProjectIconURL)
                    .sheet(isPresented: $iconPickerPresented) {
                        SymbolPicker(symbol: $newProjectIconURL)
                            .preferredColorScheme(.dark)
                    }
                    .onTapGesture {
                        iconPickerPresented.toggle()
                    }
                TextField("New Project", text: $newProjectName)
                    .onSubmit {
                        createNewProject()
                    }
            }
            
            HStack {
                Spacer()
                Button("Cancel") {
                    currentWindowPopupStatus = false
                }
                Button("OK") {
                    createNewProject()
                }

            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        } .frame(
            minWidth: 150,
            idealWidth: 150,
            maxWidth: 200,
            alignment: .center
        )
        .padding(10)
    }
    
    private func createNewProject() {
        let project = Project(context: viewContext)
        project.name = newProjectName
        project.iconURL = newProjectIconURL
        do {
            try viewContext.save()
            currentWindowPopupStatus = false
        } catch {
            fatalError("Unable to create new project")
        }
    }
}

struct ProjectCreationView_Previews: PreviewProvider {
    @State static var currentWindowPopupStatus = true
    static var previews: some View {
        ProjectCreationView(
            currentWindowPopupStatus: $currentWindowPopupStatus
        )
    }
}
