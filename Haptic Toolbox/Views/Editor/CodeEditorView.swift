//
//  CodeEditorView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct CodeEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    let ahapContent: String
    @State private var editedContent: String = ""
    @State private var editedName: String = ""
    var fileName: String
    var onSave: (String, String) -> Void

    var body: some View {
        NavigationView {
            VStack {
                TextField("File Name", text: $editedName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)

                TextEditor(text: $editedContent)
                    .font(.system(size: 14, design: .monospaced))
                    .padding(4)
                    .border(Color.gray, width: 1)
                    .padding()
            }
            .navigationBarTitle("Edit AHAP", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onSave(editedContent, editedName)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                formatJSON()
                editedName = fileName
            }
        }
    }

    private func formatJSON() {
        if let jsonData = ahapContent.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                editedContent = prettyString
                return
            }
        }
        editedContent = ahapContent
    }
}