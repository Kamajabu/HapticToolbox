//
//  SharpnessChartView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI
import Charts

struct SharpnessChartView: View {
    let events: [HapticEvent]

    var body: some View {
        Chart {
            ForEach(events) { event in
                LineMark(
                    x: .value("Time", event.time),
                    y: .value("Sharpness", event.sharpness)
                )
                .foregroundStyle(.red)

                PointMark(
                    x: .value("Time", event.time),
                    y: .value("Sharpness", event.sharpness)
                )
                .foregroundStyle(.red)
            }
        }
        .chartYScale(domain: 0...1)
        .chartXAxisLabel("Time (seconds)")
        .chartYAxisLabel("Sharpness")
        .padding()
    }
}