//
//  HapticFile.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import Foundation

struct HapticFile: Identifiable, Codable {
    let id: UUID
    var name: String
    var content: String
    var loadedTime: Date
    var metadata: HapticMetadata?
    
    init(id: UUID = UUID(), name: String, content: String, loadedTime: Date, metadata: HapticMetadata? = nil) {
        self.id = id
        self.name = name
        self.content = content
        self.loadedTime = loadedTime
        self.metadata = metadata
    }
}