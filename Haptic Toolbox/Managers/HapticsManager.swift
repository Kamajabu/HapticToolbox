//
//  HapticsManager.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


// Managers/HapticsManager.swift
import Foundation
import CoreHaptics
import SwiftUI

class HapticsManager: ObservableObject {
    @Published var hapticFiles: [HapticFile] = []
    @Published var selectedFileIndex: Int? = nil
    private(set) var engine: CHHapticEngine?

    var selectedFile: HapticFile? {
        guard let index = selectedFileIndex, hapticFiles.indices.contains(index) else { return nil }
        return hapticFiles[index]
    }

    init() {
        prepareHaptics()
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            NotificationCenter.default.addObserver(self, selector: #selector(handleAppBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleAppForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        } catch {
            print("Failed to create haptic engine: \(error.localizedDescription)")
        }
    }

    @objc func handleAppBackground() {
        do {
            try engine?.stop()
        } catch {
            print("Error stopping engine: \(error)")
        }
    }

    @objc func handleAppForeground() {
        do {
            try engine?.start()
        } catch {
            print("Error restarting engine: \(error)")
        }
    }

    // File management methods
    func downloadAHAP(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading AHAP: \(error.localizedDescription)")
                return
            }

            guard let data = data, let content = String(data: data, encoding: .utf8) else {
                print("Invalid data received")
                return
            }

            DispatchQueue.main.async {
                let filename = url.lastPathComponent.replacingOccurrences(of: ".ahap", with: "")
                let newFile = HapticFile(
                    name: filename,
                    content: content,
                    loadedTime: Date(),
                    metadata: self.extractMetadata(from: content)
                )

                self.hapticFiles.append(newFile)
                self.selectedFileIndex = self.hapticFiles.count - 1
            }
        }.resume()
    }

    func addAHAPFromText(content: String, name: String = "Untitled") {
        let newFile = HapticFile(
            name: name,
            content: content,
            loadedTime: Date(),
            metadata: extractMetadata(from: content)
        )

        hapticFiles.append(newFile)
        selectedFileIndex = hapticFiles.count - 1
    }

    func updateSelectedFile(content: String) {
        guard let index = selectedFileIndex, hapticFiles.indices.contains(index) else { return }

        var updatedFile = hapticFiles[index]
        updatedFile.content = content
        updatedFile.metadata = extractMetadata(from: content)
        hapticFiles[index] = updatedFile
    }

    func removeFile(at index: Int) {
        guard hapticFiles.indices.contains(index) else { return }

        hapticFiles.remove(at: index)

        if selectedFileIndex == index {
            if hapticFiles.isEmpty {
                selectedFileIndex = nil
            } else if index >= hapticFiles.count {
                selectedFileIndex = hapticFiles.count - 1
            }
        } else if let selected = selectedFileIndex, selected > index {
            selectedFileIndex = selected - 1
        }
    }

    func clearAllFiles() {
        hapticFiles.removeAll()
        selectedFileIndex = nil
    }

    // AHAP playback and analysis
    func playSelectedHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device doesn't support haptics")
            return
        }

        guard let file = selectedFile, !file.content.isEmpty else {
            print("No AHAP content to play")
            return
        }

        do {
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent("temp.ahap")
            try file.content.write(to: tempFileURL, atomically: true, encoding: .utf8)
            try engine?.playPattern(from: tempFileURL)
        } catch {
            print("Error playing haptics: \(error.localizedDescription)")
        }
    }

    func extractMetadata(from content: String) -> HapticFile.HapticMetadata? {
        guard !content.isEmpty else { return nil }

        var metadata = HapticFile.HapticMetadata()

        do {
            if let jsonData = content.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                if let version = json["Version"] as? String {
                    metadata.version = version
                }

                if let description = json["Description"] as? String {
                    metadata.description = description
                }

                if let pattern = json["Pattern"] as? [[String: Any]] {
                    var maxTime = 0.0

                    for item in pattern {
                        if let event = item["Event"] as? [String: Any],
                           let time = event["Time"] as? Double {
                            maxTime = max(maxTime, time)
                        }
                    }

                    metadata.duration = maxTime + 0.5
                }
            }

            return metadata

        } catch {
            print("Error parsing AHAP metadata: \(error.localizedDescription)")
            return nil
        }
    }

    func parseAHAPForVisualization(fileIndex: Int? = nil) -> [HapticEvent] {
        var events: [HapticEvent] = []

        let content: String
        if let index = fileIndex, hapticFiles.indices.contains(index) {
            content = hapticFiles[index].content
        } else if let file = selectedFile {
            content = file.content
        } else {
            return events
        }

        guard !content.isEmpty else { return events }

        do {
            if let jsonData = content.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let pattern = json["Pattern"] as? [[String: Any]] {

                for item in pattern {
                    if let event = item["Event"] as? [String: Any],
                       let time = event["Time"] as? Double,
                       let eventType = event["EventType"] as? String {

                        var intensity: Double = 0
                        var sharpness: Double = 0

                        if let parameters = event["EventParameters"] as? [[String: Any]] {
                            for param in parameters {
                                if let parameterID = param["ParameterID"] as? String {
                                    if parameterID == "HapticIntensity", let value = param["ParameterValue"] as? Double {
                                        intensity = value
                                    } else if parameterID == "HapticSharpness", let value = param["ParameterValue"] as? Double {
                                        sharpness = value
                                    }
                                }
                            }
                        }

                        let hapticEvent = HapticEvent(
                            time: time,
                            type: eventType,
                            intensity: intensity,
                            sharpness: sharpness
                        )
                        events.append(hapticEvent)
                    }
                }
            }
        } catch {
            print("Error parsing AHAP: \(error.localizedDescription)")
        }

        return events.sorted { $0.time < $1.time }
    }
}
