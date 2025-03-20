//
//  EventMarker.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct EventMarker: View {
    let event: HapticEvent
    let maxTime: Double
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(event.type == "HapticTransient" ? Color.blue : Color.orange)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
                )
            
            Text(String(format: "%.2fs", event.time))
                .font(.system(size: 10))
        }
    }
}