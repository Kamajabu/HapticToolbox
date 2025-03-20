//
//  HapticFileActionsView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct HapticFileActionsView: View {
    @EnvironmentObject private var hapticsManager: HapticsManager
    @Binding var showVisualizer: Bool
    @Binding var showCodeEditor: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                showVisualizer = true
            } label: {
                VStack {
                    Image(systemName: "waveform")
                        .font(.system(size: 20))
                    Text("Visualize")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }

            Button {
                showCodeEditor = true
            } label: {
                VStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                    Text("Edit")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }

            Button {
                hapticsManager.playSelectedHaptics()
            } label: {
                VStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                    Text("Play")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}