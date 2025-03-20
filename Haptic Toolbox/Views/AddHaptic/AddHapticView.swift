//
//  AddHapticView.swift
//  Haptic Toolbox
//
//  Created by Kamil Buczel on 20/03/2025.
//


import SwiftUI

struct AddHapticView: View {
    @EnvironmentObject private var hapticsManager: HapticsManager
    @Binding var isPresented: Bool
    @State private var urlString = ""
    @State private var showScanner = false
    @State private var showPasteEditor = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Haptic File")
                    .font(.headline)
                    .padding(.top)

                VStack {
                    HStack {
                        TextField("Enter AHAP URL", text: $urlString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Download") {
                            hapticsManager.downloadAHAP(from: urlString)
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(urlString.isEmpty)
                    }
                    .padding(.horizontal)

                    Button {
                        showScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scan QR")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Button {
                        showPasteEditor = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Paste Code")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()

                Spacer()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .sheet(isPresented: $showScanner) {
                QRCodeScannerView { code in
                    urlString = code
                    showScanner = false
                    hapticsManager.downloadAHAP(from: code)
                    isPresented = false
                }
            }
            .sheet(isPresented: $showPasteEditor) {
                PasteHapticView(
                    onComplete: {
                        isPresented = false
                    }
                )
            }
        }
    }
}