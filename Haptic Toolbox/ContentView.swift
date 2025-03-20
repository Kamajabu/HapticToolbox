import SwiftUI

struct ContentView: View {
    @StateObject private var hapticsManager = HapticsManager()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ViewTab()
            }
            .tabItem {
                Label("View", systemImage: "eye")
            }
            .tag(0)

            NavigationView {
                CreateTab()
            }
            .tabItem {
                Label("Create", systemImage: "plus")
            }
            .tag(1)

            NavigationView {
                SettingsTab()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .environmentObject(hapticsManager)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}

struct SettingsTab: View {
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback = true
    @AppStorage("defaultHapticStrength") private var defaultHapticStrength = 0.6
    @AppStorage("autoSaveDrafts") private var autoSaveDrafts = true
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Form {
            Section(header: Text("Haptics")) {
                Toggle("Enable Haptic Feedback", isOn: $enableHapticFeedback)

                VStack(alignment: .leading) {
                    Text("Default Strength")
                    Slider(value: $defaultHapticStrength, in: 0...1) {
                        Text("Default Strength")
                    } minimumValueLabel: {
                        Text("Light")
                    } maximumValueLabel: {
                        Text("Strong")
                    }
                    .padding(.top, 2)
                }
                .padding(.vertical, 8)
            }

            Section(header: Text("Editor")) {
                Toggle("Auto-save drafts", isOn: $autoSaveDrafts)
            }

            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                Link(destination: URL(string: "https://developer.apple.com/documentation/corehaptics")!) {
                    HStack {
                        Text("Core Haptics Documentation")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }

                Link(destination: URL(string: "https://github.com/yourname/haptic-toolbox")!) {
                    HStack {
                        Text("GitHub Repository")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
