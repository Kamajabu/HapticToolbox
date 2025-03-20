//
//  IntensityChartView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI
import Charts

struct IntensityChartView: View {
    let events: [HapticEvent]

    var body: some View {
        Chart {
            ForEach(events) { event in
                LineMark(
                    x: .value("Time", event.time),
                    y: .value("Intensity", event.intensity)
                )
                .foregroundStyle(.blue)

                PointMark(
                    x: .value("Time", event.time),
                    y: .value("Intensity", event.intensity)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYScale(domain: 0...1)
        .chartXAxisLabel("Time (seconds)")
        .chartYAxisLabel("Intensity")
        .padding()
    }
}