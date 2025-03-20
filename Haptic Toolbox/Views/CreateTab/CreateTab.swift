//
//  CreateTab.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI
import CoreHaptics

struct CreateTab: View {
    @EnvironmentObject private var hapticsManager: HapticsManager

    @State var hapticEvents: [HapticEvent] = []
    @State var patternName: String = "New Pattern"
    @State var patternDescription: String = ""
    
    @State private var selectedEventIndex: Int? = nil
    @State private var showSaveDialog = false
    
    var body: some View {
        VStack {
            // Header
            Text("Haptic Pattern Creator")
                .font(.title)
                .padding(.top)
            
            // Pattern metadata
            VStack(spacing: 8) {
                TextField("Pattern Name", text: $patternName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Description (Optional)", text: $patternDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            // Timeline visualization
            TimelineView(events: hapticEvents, selectedEventIndex: $selectedEventIndex)
            
            // Event editor
            if let index = selectedEventIndex, hapticEvents.indices.contains(index) {
                EventEditorView(
                    event: hapticEvents[index],
                    onUpdate: { updatedEvent in
                        hapticEvents[index] = updatedEvent
                    },
                    onDelete: {
                        hapticEvents.remove(at: index)
                        selectedEventIndex = nil
                    }
                )
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button {
                    addNewEvent()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Event")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    playPattern()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Test")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(hapticEvents.isEmpty)
                
                Button {
                    showSaveDialog = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(hapticEvents.isEmpty || patternName.isEmpty)
            }
            .padding()
        }
        .padding()
        .alert("Save Haptic Pattern", isPresented: $showSaveDialog) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                savePattern()
            }
        } message: {
            Text("Save this pattern as '\(patternName)'?")
        }
    }
    
    private func addNewEvent() {
        let newEvent = HapticEvent(
            time: hapticEvents.isEmpty ? 0.0 : (hapticEvents.map { $0.time }.max() ?? 0.0) + 0.2,
            type: "HapticTransient",
            intensity: 0.6,
            sharpness: 0.5
        )
        hapticEvents.append(newEvent)
        selectedEventIndex = hapticEvents.count - 1
    }
    
    private func playPattern() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let ahapString = generateAHAPString()
        do {
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent("temp_test.ahap")
            try ahapString.write(to: tempFileURL, atomically: true, encoding: .utf8)
            
            try hapticsManager.engine?.playPattern(from: tempFileURL)
        } catch {
            print("Error playing test pattern: \(error)")
        }
    }
    
    private func savePattern() {
        let ahapString = generateAHAPString()
        hapticsManager.addAHAPFromText(content: ahapString, name: patternName)
        
        // Reset the form
        patternName = "New Pattern"
        patternDescription = ""
        hapticEvents = []
        selectedEventIndex = nil
    }
    
    private func generateAHAPString() -> String {
        var patternArray: [[String: Any]] = []
        
        for event in hapticEvents.sorted(by: { $0.time < $1.time }) {
            var eventDict: [String: Any] = [
                "Event": [
                    "Time": event.time,
                    "EventType": event.type
                ]
            ]
            
            // Add parameters
            var parameters: [[String: Any]] = []
            
            // Intensity parameter
            parameters.append([
                "ParameterID": "HapticIntensity",
                "ParameterValue": event.intensity
            ])
            
            // Sharpness parameter
            parameters.append([
                "ParameterID": "HapticSharpness",
                "ParameterValue": event.sharpness
            ])
            
            // Add parameters to event
            if var eventData = eventDict["Event"] as? [String: Any] {
                eventData["EventParameters"] = parameters
                eventDict["Event"] = eventData
            }
            
            patternArray.append(eventDict)
        }
        
        // Create the main AHAP dictionary
        let ahapDict: [String: Any] = [
            "Version": 1.0,
            "Metadata": [
                "Project": patternName,
                "Created": ISO8601DateFormatter().string(from: Date()),
                "Description": patternDescription
            ],
            "Pattern": patternArray
        ]
        
        // Convert to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: ahapDict, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return ""
    }
}
