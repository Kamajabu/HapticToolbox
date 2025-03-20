//
//  PasteHapticView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct PasteHapticView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var hapticsManager: HapticsManager
    var onComplete: () -> Void

    @State private var ahapContent: String = ""
    @State private var fileName: String = "New Haptic"

    var body: some View {
        NavigationView {
            VStack {
                TextField("File Name", text: $fileName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)

                TextEditor(text: $ahapContent)
                    .font(.system(size: 14, design: .monospaced))
                    .padding(4)
                    .border(Color.gray, width: 1)
                    .padding()
            }
            .navigationBarTitle("Paste AHAP Code", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    hapticsManager.addAHAPFromText(content: ahapContent, name: fileName)
                    presentationMode.wrappedValue.dismiss()
                    onComplete()
                }
                .disabled(ahapContent.isEmpty)
            )
        }
    }
}
