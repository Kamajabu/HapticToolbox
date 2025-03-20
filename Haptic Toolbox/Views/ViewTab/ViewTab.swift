//
//  ViewTab.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct ViewTab: View {
    @EnvironmentObject private var hapticsManager: HapticsManager

    @State private var urlString = ""
    @State private var showScanner = false
    @State private var showCodeEditor = false
    @State private var showVisualizer = false
    @State private var showAddHapticSheet = false

    var body: some View {
        VStack(spacing: 16) {
            Text("AHAP Haptics Library")
                .font(.title)
                .padding(.top)

            // Add Haptic Files Section
            VStack {
                Button {
                    showAddHapticSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Haptic File")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            // List of Haptic Files
            if hapticsManager.hapticFiles.isEmpty {
                EmptyLibraryView()
            } else {
                HapticFileListView()

                // Action Buttons for selected file
                if hapticsManager.selectedFile != nil {
                    HapticFileActionsView(
                        showVisualizer: $showVisualizer,
                        showCodeEditor: $showCodeEditor
                    )
                }

                // Clear All button
                ClearAllButton()
            }
        }
        .sheet(isPresented: $showScanner) {
            QRCodeScannerView { code in
                urlString = code
                showScanner = false
                hapticsManager.downloadAHAP(from: code)
            }
        }
        .sheet(isPresented: $showCodeEditor) {
            if let file = hapticsManager.selectedFile {
                CodeEditorView(
                    ahapContent: file.content,
                    fileName: file.name,
                    onSave: { updatedContent, updatedName in
                        if let index = hapticsManager.selectedFileIndex {
                            var updatedFile = hapticsManager.hapticFiles[index]
                            updatedFile.content = updatedContent
                            updatedFile.name = updatedName
                            updatedFile.metadata = hapticsManager.extractMetadata(from: updatedContent)
                            hapticsManager.hapticFiles[index] = updatedFile
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showVisualizer) {
            if let index = hapticsManager.selectedFileIndex {
                HapticVisualizerView(
                    events: hapticsManager.parseAHAPForVisualization(fileIndex: index),
                    fileName: hapticsManager.hapticFiles[index].name
                )
            }
        }
        .sheet(isPresented: $showAddHapticSheet) {
            AddHapticView(isPresented: $showAddHapticSheet)
        }
    }
}
