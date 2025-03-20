//
//  HapticFileListView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct HapticFileListView: View {
    @EnvironmentObject private var hapticsManager: HapticsManager
    
    var body: some View {
        List {
            ForEach(Array(hapticsManager.hapticFiles.enumerated()), id: \.element.id) { index, file in
                HapticFileRow(file: file, isSelected: hapticsManager.selectedFileIndex == index)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hapticsManager.selectedFileIndex = index
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            hapticsManager.removeFile(at: index)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}