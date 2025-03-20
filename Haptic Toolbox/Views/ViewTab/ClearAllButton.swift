//
//  ClearAllButton.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct ClearAllButton: View {
    @EnvironmentObject private var hapticsManager: HapticsManager
    
    var body: some View {
        Button {
            hapticsManager.clearAllFiles()
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Clear All")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding([.horizontal, .bottom])
    }
}