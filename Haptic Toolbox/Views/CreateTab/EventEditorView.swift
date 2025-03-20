//
//  EventEditorView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct EventEditorView: View {
    let event: HapticEvent
    let onUpdate: (HapticEvent) -> Void
    let onDelete: () -> Void
    
    @State private var time: Double
    @State private var type: String
    @State private var intensity: Double
    @State private var sharpness: Double
    
    init(event: HapticEvent, onUpdate: @escaping (HapticEvent) -> Void, onDelete: @escaping () -> Void) {
        self.event = event
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        
        _time = State(initialValue: event.time)
        _type = State(initialValue: event.type)
        _intensity = State(initialValue: event.intensity)
        _sharpness = State(initialValue: event.sharpness)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit Event")
                .font(.headline)
            
            // Time slider
            HStack {
                Text("Time:")
                Slider(value: $time, in: 0...3, step: 0.05)
                    .onChange(of: time) { _ in updateEvent() }
                Text(String(format: "%.2fs", time))
                    .frame(width: 50, alignment: .trailing)
                    .font(.caption)
            }
            
            // Event type picker
            HStack {
                Text("Type:")
                Picker("", selection: $type) {
                    Text("Transient").tag("HapticTransient")
                    Text("Continuous").tag("HapticContinuous")
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: type) { _ in updateEvent() }
            }
            
            // Intensity slider
            HStack {
                Text("Intensity:")
                Slider(value: $intensity, in: 0...1, step: 0.05)
                    .onChange(of: intensity) { _ in updateEvent() }
                Text(String(format: "%.2f", intensity))
                    .frame(width: 50, alignment: .trailing)
                    .font(.caption)
            }
            
            // Sharpness slider
            HStack {
                Text("Sharpness:")
                Slider(value: $sharpness, in: 0...1, step: 0.05)
                    .onChange(of: sharpness) { _ in updateEvent() }
                Text(String(format: "%.2f", sharpness))
                    .frame(width: 50, alignment: .trailing)
                    .font(.caption)
            }
            
            // Delete button
            Button(role: .destructive, action: onDelete) {
                Label("Delete Event", systemImage: "trash")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding()
    }
    
    private func updateEvent() {
        let updatedEvent = HapticEvent(
            id: event.id, // Keep the same ID
            time: time,
            type: type,
            intensity: intensity,
            sharpness: sharpness
        )
        onUpdate(updatedEvent)
    }
}
