//
//  TimelineView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct TimelineView: View {
    let events: [HapticEvent]
    @Binding var selectedEventIndex: Int?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background grid
            VStack(spacing: 0) {
                ForEach(0..<5) { _ in
                    Divider()
                    Spacer()
                }
                Divider()
            }
            
            // Timeline markers
            VStack(alignment: .leading) {
                Text("Timeline (seconds)")
                    .font(.caption)
                    .padding(.bottom, 4)
                
                ZStack(alignment: .topLeading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 150)
                    
                    // Time markers
                    TimelineMarkers(maxTime: maxTime)
                    
                    // Event markers
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        EventMarker(
                            event: event,
                            maxTime: maxTime,
                            isSelected: selectedEventIndex == index
                        )
                        .position(
                            x: CGFloat(event.time / maxTime) * UIScreen.main.bounds.width * 0.9,
                            y: 75
                        )
                        .onTapGesture {
                            selectedEventIndex = index
                        }
                    }
                }
            }
            .padding()
        }
        .frame(height: 200)
    }
    
    private var maxTime: Double {
        max(1.0, (events.map { $0.time }.max() ?? 0.0) + 0.5)
    }
}