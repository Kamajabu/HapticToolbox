//
//  EventListView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct EventListView: View {
    let events: [HapticEvent]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Events").font(.headline).padding(.bottom, 2)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(events.prefix(10)) { event in
                        HStack {
                            Text("\(String(format: "%.2f", event.time))s")
                                .frame(width: 60, alignment: .leading)

                            Text(event.type)
                                .frame(width: 120, alignment: .leading)

                            Spacer()

                            Text("I: \(String(format: "%.2f", event.intensity))")
                            Text("S: \(String(format: "%.2f", event.sharpness))")
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.vertical, 2)
                    }

                    if events.count > 10 {
                        Text("+ \(events.count - 10) more events...")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .padding(.top, 4)
                    }
                }
            }
            .frame(height: 150)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
    }
}