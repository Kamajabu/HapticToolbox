//
//  AHAPGenerator.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


// MARK: - Utils
// Utils/AHAPGenerator.swift
import Foundation

struct AHAPGenerator {
    static func generateEmptyAHAP() -> String {
        let ahapDict: [String: Any] = [
            "Version": 1.0,
            "Metadata": [
                "Project": "New Haptic Pattern",
                "Created": ISO8601DateFormatter().string(from: Date()),
                "Description": ""
            ],
            "Pattern": []
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: ahapDict, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return ""
    }
    
    static func formatAHAPString(_ jsonString: String) -> String {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        
        return prettyString
    }
}