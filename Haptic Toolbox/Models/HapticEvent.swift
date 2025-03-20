//
//  HapticEvent.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


// Models/HapticEvent.swift
import Foundation

struct HapticEvent: Identifiable {
    let id: UUID
    let time: Double
    let type: String
    let intensity: Double
    let sharpness: Double
    
    init(id: UUID = UUID(), time: Double, type: String, intensity: Double, sharpness: Double) {
        self.id = id
        self.time = time
        self.type = type
        self.intensity = intensity
        self.sharpness = sharpness
    }
}