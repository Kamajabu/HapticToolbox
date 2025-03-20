//
//  HapticMetadata.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import Foundation

extension HapticFile {
    struct HapticMetadata: Codable {
        var version: String?
        var description: String?
        var duration: Double?
    }
}