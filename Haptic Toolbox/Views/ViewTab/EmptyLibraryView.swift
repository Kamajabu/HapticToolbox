//
//  EmptyLibraryView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "waveform")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No Haptic Files")
                .font(.headline)
            Text("Add a haptic file to get started")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}