//
//  Haptic+Templates.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//

import Foundation

extension CreateTab {
    func loadTemplatePattern(_ template: HapticTemplate) {
        patternName = template.name
        patternDescription = template.description
        hapticEvents = template.events
    }
}

struct HapticTemplate {
    let name: String
    let description: String
    let events: [HapticEvent]

    static let templates: [HapticTemplate] = [
        HapticTemplate(
            name: "Single Tap",
            description: "A simple tap sensation",
            events: [
                HapticEvent(time: 0.0, type: "HapticTransient", intensity: 0.8, sharpness: 0.5)
            ]
        ),
        HapticTemplate(
            name: "Double Tap",
            description: "Two quick taps in succession",
            events: [
                HapticEvent(time: 0.0, type: "HapticTransient", intensity: 0.8, sharpness: 0.5),
                HapticEvent(time: 0.2, type: "HapticTransient", intensity: 0.8, sharpness: 0.5)
            ]
        ),
        HapticTemplate(
            name: "Success Feedback",
            description: "Positive confirmation sensation",
            events: [
                HapticEvent(time: 0.0, type: "HapticTransient", intensity: 0.5, sharpness: 0.3),
                HapticEvent(time: 0.1, type: "HapticTransient", intensity: 0.8, sharpness: 0.7)
            ]
        ),
        HapticTemplate(
            name: "Error Feedback",
            description: "Negative feedback sensation",
            events: [
                HapticEvent(time: 0.0, type: "HapticTransient", intensity: 0.7, sharpness: 0.8),
                HapticEvent(time: 0.15, type: "HapticTransient", intensity: 0.7, sharpness: 0.8),
                HapticEvent(time: 0.3, type: "HapticTransient", intensity: 0.9, sharpness: 0.8)
            ]
        ),
        HapticTemplate(
            name: "Heartbeat",
            description: "Rhythmic heartbeat sensation",
            events: [
                HapticEvent(time: 0.0, type: "HapticTransient", intensity: 0.7, sharpness: 0.3),
                HapticEvent(time: 0.15, type: "HapticTransient", intensity: 0.5, sharpness: 0.3),
                HapticEvent(time: 0.8, type: "HapticTransient", intensity: 0.7, sharpness: 0.3),
                HapticEvent(time: 0.95, type: "HapticTransient", intensity: 0.5, sharpness: 0.3)
            ]
        )
    ]
}
