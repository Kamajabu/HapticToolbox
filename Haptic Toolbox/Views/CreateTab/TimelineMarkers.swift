//
//  TimelineMarkers.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct TimelineMarkers: View {
    let maxTime: Double
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0...5, id: \.self) { i in
                VStack {
                    Text("\(String(format: "%.1f", Double(i) * maxTime / 5.0))")
                        .font(.caption)
                        .offset(y: -20)
                    
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 150)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}