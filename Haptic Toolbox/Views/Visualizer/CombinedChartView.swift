//
//  CombinedChartView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI
import Charts

struct CombinedChartView: View {
    let events: [HapticEvent]

    var body: some View {
        Chart {
            ForEach(events) { event in
                LineMark(
                    x: .value("Time", event.time),
                    y: .value("Intensity", event.intensity)
                )
                .foregroundStyle(.blue)

                LineMark(
                    x: .value("Time", event.time),
                    y: .value("Sharpness", event.sharpness)
                )
                .foregroundStyle(.red)
            }
        }
        .chartYScale(domain: 0...1)
        .chartXAxisLabel("Time (seconds)")
        .chartYAxisLabel("Value")
        .chartForegroundStyleScale([
            "Intensity": .blue,
            "Sharpness": .red
        ])
        .padding()
    }
}