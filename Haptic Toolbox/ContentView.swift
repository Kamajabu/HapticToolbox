import SwiftUI
import CoreImage.CIFilterBuiltins
import AVFoundation
import CoreHaptics
import Charts

struct ContentView: View {
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
        }
    }
}

struct HapticFile: Identifiable {
    let id = UUID()
    var name: String
    var content: String
    var loadedTime: Date
    var metadata: HapticMetadata?

    struct HapticMetadata {
        var version: String?
        var description: String?
        var duration: Double?
    }
}

class HapticsManager: ObservableObject {
    @Published var hapticFiles: [HapticFile] = []
    @Published var selectedFileIndex: Int? = nil
    private var engine: CHHapticEngine?

    var selectedFile: HapticFile? {
        guard let index = selectedFileIndex, hapticFiles.indices.contains(index) else { return nil }
        return hapticFiles[index]
    }

    init() {
        prepareHaptics()
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            // Stop the engine when app goes to background
            NotificationCenter.default.addObserver(self, selector: #selector(handleAppBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

            // Restart the engine when app comes to foreground
            NotificationCenter.default.addObserver(self, selector: #selector(handleAppForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        } catch {
            print("Failed to create haptic engine: \(error.localizedDescription)")
        }
    }

    @objc func handleAppBackground() {
        do {
            try engine?.stop()
        } catch {
            print("Error stopping engine: \(error)")
        }
    }

    @objc func handleAppForeground() {
        do {
            try engine?.start()
        } catch {
            print("Error restarting engine: \(error)")
        }
    }

    func downloadAHAP(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading AHAP: \(error.localizedDescription)")
                return
            }

            guard let data = data, let content = String(data: data, encoding: .utf8) else {
                print("Invalid data received")
                return
            }

            DispatchQueue.main.async {
                // Extract filename from URL
                let filename = url.lastPathComponent.replacingOccurrences(of: ".ahap", with: "")

                // Create a new haptic file
                let newFile = HapticFile(
                    name: filename,
                    content: content,
                    loadedTime: Date(),
                    metadata: self.extractMetadata(from: content)
                )

                self.hapticFiles.append(newFile)
                self.selectedFileIndex = self.hapticFiles.count - 1
            }
        }.resume()
    }

    func addAHAPFromText(content: String, name: String = "Untitled") {
        let newFile = HapticFile(
            name: name,
            content: content,
            loadedTime: Date(),
            metadata: extractMetadata(from: content)
        )

        hapticFiles.append(newFile)
        selectedFileIndex = hapticFiles.count - 1
    }

    func updateSelectedFile(content: String) {
        guard let index = selectedFileIndex, hapticFiles.indices.contains(index) else { return }

        var updatedFile = hapticFiles[index]
        updatedFile.content = content
        updatedFile.metadata = extractMetadata(from: content)
        hapticFiles[index] = updatedFile
    }

    func removeFile(at index: Int) {
        guard hapticFiles.indices.contains(index) else { return }

        hapticFiles.remove(at: index)

        // Update selected index if needed
        if selectedFileIndex == index {
            if hapticFiles.isEmpty {
                selectedFileIndex = nil
            } else if index >= hapticFiles.count {
                selectedFileIndex = hapticFiles.count - 1
            }
        } else if let selected = selectedFileIndex, selected > index {
            selectedFileIndex = selected - 1
        }
    }

    func clearAllFiles() {
        hapticFiles.removeAll()
        selectedFileIndex = nil
    }

    func playSelectedHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device doesn't support haptics")
            return
        }

        guard let file = selectedFile, !file.content.isEmpty else {
            print("No AHAP content to play")
            return
        }

        do {
            // Create a temporary file to save the AHAP content
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent("temp.ahap")
            try file.content.write(to: tempFileURL, atomically: true, encoding: .utf8)

            // Play the haptics pattern
            try engine?.playPattern(from: tempFileURL)
        } catch {
            print("Error playing haptics: \(error.localizedDescription)")
        }
    }

    func extractMetadata(from content: String) -> HapticFile.HapticMetadata? {
        guard !content.isEmpty else { return nil }

        var metadata = HapticFile.HapticMetadata()

        do {
            if let jsonData = content.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                // Extract version
                if let version = json["Version"] as? String {
                    metadata.version = version
                }

                // Extract description if available
                if let description = json["Description"] as? String {
                    metadata.description = description
                }

                // Calculate approximate duration from pattern
                if let pattern = json["Pattern"] as? [[String: Any]] {
                    var maxTime = 0.0

                    for item in pattern {
                        if let event = item["Event"] as? [String: Any],
                           let time = event["Time"] as? Double {
                            maxTime = max(maxTime, time)
                        }
                    }

                    // Add a small buffer to the duration
                    metadata.duration = maxTime + 0.5
                }
            }

            return metadata

        } catch {
            print("Error parsing AHAP metadata: \(error.localizedDescription)")
            return nil
        }
    }

    func parseAHAPForVisualization(fileIndex: Int? = nil) -> [HapticEvent] {
        var events: [HapticEvent] = []

        let content: String
        if let index = fileIndex, hapticFiles.indices.contains(index) {
            content = hapticFiles[index].content
        } else if let file = selectedFile {
            content = file.content
        } else {
            return events
        }

        guard !content.isEmpty else { return events }

        do {
            if let jsonData = content.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let pattern = json["Pattern"] as? [[String: Any]] {

                for item in pattern {
                    if let event = item["Event"] as? [String: Any],
                       let time = event["Time"] as? Double,
                       let eventType = event["EventType"] as? String {

                        var intensity: Double = 0
                        var sharpness: Double = 0

                        if let parameters = event["EventParameters"] as? [[String: Any]] {
                            for param in parameters {
                                if let parameterID = param["ParameterID"] as? String {
                                    if parameterID == "HapticIntensity", let value = param["ParameterValue"] as? Double {
                                        intensity = value
                                    } else if parameterID == "HapticSharpness", let value = param["ParameterValue"] as? Double {
                                        sharpness = value
                                    }
                                }
                            }
                        }

                        let hapticEvent = HapticEvent(
                            time: time,
                            type: eventType,
                            intensity: intensity,
                            sharpness: sharpness
                        )
                        events.append(hapticEvent)
                    }
                }
            }
        } catch {
            print("Error parsing AHAP: \(error.localizedDescription)")
        }

        return events.sorted { $0.time < $1.time }
    }
}

struct HapticEvent: Identifiable {
    let id = UUID()
    let time: Double
    let type: String
    let intensity: Double
    let sharpness: Double
}

struct ViewTab: View {
    @StateObject private var hapticsManager = HapticsManager()
    @State private var urlString = ""
    @State private var showScanner = false
    @State private var showCodeEditor = false
    @State private var showVisualizer = false
    @State private var showAddHapticSheet = false

    var body: some View {
        VStack(spacing: 16) {
            Text("AHAP Haptics Library")
                .font(.title)
                .padding(.top)

            // Add Haptic Files Section
            VStack {
                Button {
                    showAddHapticSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Haptic File")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            // List of Haptic Files
            if hapticsManager.hapticFiles.isEmpty {
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
            } else {
                List {
                    ForEach(Array(hapticsManager.hapticFiles.enumerated()), id: \.element.id) { index, file in
                        HapticFileRow(file: file, isSelected: hapticsManager.selectedFileIndex == index)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hapticsManager.selectedFileIndex = index
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    hapticsManager.removeFile(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Action Buttons for selected file
                if hapticsManager.selectedFile != nil {
                    HStack(spacing: 16) {
                        Button {
                            showVisualizer = true
                        } label: {
                            VStack {
                                Image(systemName: "waveform")
                                    .font(.system(size: 20))
                                Text("Visualize")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        Button {
                            showCodeEditor = true
                        } label: {
                            VStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20))
                                Text("Edit")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        Button {
                            hapticsManager.playSelectedHaptics()
                        } label: {
                            VStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20))
                                Text("Play")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                // Clear All button
                Button {
                    hapticsManager.clearAllFiles()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .sheet(isPresented: $showScanner) {
            QRCodeScannerView { code in
                urlString = code
                showScanner = false
                hapticsManager.downloadAHAP(from: code)
            }
        }
        .sheet(isPresented: $showCodeEditor) {
            if let file = hapticsManager.selectedFile {
                CodeEditorView(
                    ahapContent: file.content,
                    fileName: file.name,
                    onSave: { updatedContent, updatedName in
                        if let index = hapticsManager.selectedFileIndex {
                            var updatedFile = hapticsManager.hapticFiles[index]
                            updatedFile.content = updatedContent
                            updatedFile.name = updatedName
                            updatedFile.metadata = hapticsManager.extractMetadata(from: updatedContent)
                            hapticsManager.hapticFiles[index] = updatedFile
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showVisualizer) {
            if let index = hapticsManager.selectedFileIndex {
                HapticVisualizerView(
                    events: hapticsManager.parseAHAPForVisualization(fileIndex: index),
                    fileName: hapticsManager.hapticFiles[index].name
                )
            }
        }
        .sheet(isPresented: $showAddHapticSheet) {
            AddHapticView(hapticsManager: hapticsManager, isPresented: $showAddHapticSheet)
        }
    }
}

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

struct AddHapticView: View {
    @ObservedObject var hapticsManager: HapticsManager
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
                    hapticsManager: hapticsManager,
                    onComplete: {
                        isPresented = false
                    }
                )
            }
        }
    }
}

struct PasteHapticView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var hapticsManager: HapticsManager
    var onComplete: () -> Void

    @State private var ahapContent: String = ""
    @State private var fileName: String = "New Haptic"

    var body: some View {
        NavigationView {
            VStack {
                TextField("File Name", text: $fileName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)

                TextEditor(text: $ahapContent)
                    .font(.system(size: 14, design: .monospaced))
                    .padding(4)
                    .border(Color.gray, width: 1)
                    .padding()
            }
            .navigationBarTitle("Paste AHAP Code", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    hapticsManager.addAHAPFromText(content: ahapContent, name: fileName)
                    presentationMode.wrappedValue.dismiss()
                    onComplete()
                }
                .disabled(ahapContent.isEmpty)
            )
        }
    }
}

// Real QR Scanner Implementation
class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var onCodeScanned: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Add cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelScanning), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        // Run session
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    @objc func cancelScanning() {
        dismiss(animated: true)
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.layer.bounds
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onCodeScanned?(stringValue)
        }

        dismiss(animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct QRCodeScannerView: UIViewControllerRepresentable {
    var onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController()
        controller.onCodeScanned = onCodeScanned
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {}
}

struct CodeEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    let ahapContent: String
    @State private var editedContent: String = ""
    @State private var editedName: String = ""
    var fileName: String
    var onSave: (String, String) -> Void

    var body: some View {
        NavigationView {
            VStack {
                TextField("File Name", text: $editedName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)

                TextEditor(text: $editedContent)
                    .font(.system(size: 14, design: .monospaced))
                    .padding(4)
                    .border(Color.gray, width: 1)
                    .padding()
            }
            .navigationBarTitle("Edit AHAP", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onSave(editedContent, editedName)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                formatJSON()
                editedName = fileName
            }
        }
    }

    private func formatJSON() {
        if let jsonData = ahapContent.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                editedContent = prettyString
                return
            }
        }
        editedContent = ahapContent
    }
}

struct HapticVisualizerView: View {
    @Environment(\.presentationMode) var presentationMode
    let events: [HapticEvent]
    let fileName: String
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("View Type", selection: $selectedTab) {
                    Text("Intensity").tag(0)
                    Text("Sharpness").tag(1)
                    Text("Combined").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if events.isEmpty {
                    Spacer()
                    Text("No haptic events found or invalid AHAP data")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
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
        }
    }
}

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

struct CreateTab: View {
    var body: some View {
        VStack {
            Text("Create")
                .font(.title)
                .padding()

            Text("Create functionality coming soon")
                .padding()

            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
