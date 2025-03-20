//
//  HapticVisualizerView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI
import Charts

struct HapticVisualizerView: View {
    @Environment(\.presentationMode) var presentationMode
    let events: [HapticEvent]
    let fileName: String
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                // Visualization type selector
                Picker("View Type", selection: $selectedTab) {
                    Text("Intensity").tag(0)
                    Text("Sharpness").tag(1)
                    Text("Combined").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if events.isEmpty {
                    // Empty state
                    Spacer()
                    Text("No haptic events found or invalid AHAP data")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    // Charts
                    TabView(selection: $selectedTab) {
                        // Intensity Chart
                        IntensityChartView(events: events)
                            .tag(0)

                        // Sharpness Chart
                        SharpnessChartView(events: events)
                            .tag(1)

                        // Combined Chart
                        CombinedChartView(events: events)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }

                // Event list
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
            .navigationBarTitle(fileName, displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                // Analytics tracking or initialization code could go here
            }
        }
    }
}