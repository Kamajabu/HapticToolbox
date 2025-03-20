//
//  HapticFileRow.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct HapticFileRow: View {
    let file: HapticFile
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.headline)

                if let description = file.metadata?.description {
                    Text(description)
                        .font(.subheadline)
                        .lineLimit(1)
                }

                HStack {
                    Text(formatDate(file.loadedTime))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let duration = file.metadata?.duration {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(String(format: "%.1f", duration))s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let version = file.metadata?.version {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("v\(version)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}