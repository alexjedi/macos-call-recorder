import SwiftUI
import AVFAudio

struct Preferences: View {
    @AppStorage("audioFormat")   private var audioFormat: AudioFormat = .aac
    @AppStorage("audioQuality")  private var audioQuality: AudioQuality = .high
    @AppStorage("frameRate")     private var frameRate: Int = 60
    @AppStorage("videoFormat")   private var videoFormat: VideoFormat = .mp4
    @AppStorage("encoder")       private var encoder: Encoder = .h264
    @AppStorage("saveDirectory") private var saveDirectory: String?
    @AppStorage("hideSelf")      private var hideSelf: Bool = true
    @AppStorage("showMouse")     private var showMouse: Bool = false
    @AppStorage("recordMic")     private var recordMic: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            GroupBox(label: Text("Video Output".uppercased()).fontWeight(.bold)) {
                Form() {
                    Picker("FPS", selection: $frameRate) {
                        Text("60").tag(60)
                        Text("30").tag(30)
                        Text("25").tag(25)
                        Text("24").tag(24)
                        Text("15").tag(15)
                    }.scaledToFit()
                    Picker("Format", selection: $videoFormat) {
                        Text("MOV").tag(VideoFormat.mov)
                        Text("MP4").tag(VideoFormat.mp4)
                    }.scaledToFit()
                    Picker("Encoder", selection: $encoder) {
                        Text("h264").tag(Encoder.h264)
                        Text("h265").tag(Encoder.h265)
                    }.scaledToFit()
                }.frame(maxWidth: .infinity).padding(.top, 10)
                Toggle(isOn: $hideSelf) {
                    Text("Exclude Playbook AI itself")
                }.toggleStyle(CheckboxToggleStyle())
                Toggle(isOn: $showMouse) {
                    Text("Show mouse cursor")
                }.toggleStyle(CheckboxToggleStyle()).padding(.bottom, 10)
            }
            GroupBox(label: Text("Audio Output".uppercased()).fontWeight(.bold)) {
                Form() {
                    Picker("Format", selection: $audioFormat) {
                        Text("AAC").tag(AudioFormat.aac)
                        Text("ALAC (Lossless)").tag(AudioFormat.alac)
                        Text("FLAC (Lossless)").tag(AudioFormat.flac)
                        Text("Opus").tag(AudioFormat.opus)
                    }.scaledToFit()
                    Picker("Quality", selection: $audioQuality) {
                        if audioFormat == .alac || audioFormat == .flac {
                            Text("Lossless").tag(audioQuality)
                        }
                        Text("Normal - 128Kbps").tag(AudioQuality.normal)
                        Text("Good - 192Kbps").tag(AudioQuality.good)
                        Text("High - 256Kbps").tag(AudioQuality.high)
                        Text("Extreme - 320Kbps").tag(AudioQuality.extreme)
                    }.scaledToFit().disabled(audioFormat == .alac || audioFormat == .flac)
                }.frame(maxWidth: .infinity).padding(.top, 10)
                Text("These settings are also used when recording video. If set to Opus, MP4 will fall back to AAC.")
                .font(.footnote).foregroundColor(Color.gray).padding(.leading, 2).padding(.trailing, 2).padding(.bottom, 4).fixedSize(horizontal: false, vertical: true)
                if #available(macOS 14, *) { // apparently they changed onChange in Sonoma
                    Toggle(isOn: $recordMic) {
                        Text("Record microphone input")
                    }.toggleStyle(CheckboxToggleStyle()).onChange(of: recordMic) {
                        Task { await performMicCheck() }
                    }
                } else {
                    Toggle(isOn: $recordMic) {
                        Text("Record microphone input")
                    }.toggleStyle(CheckboxToggleStyle()).onChange(of: recordMic) { _ in
                        Task { await performMicCheck() }
                    }
                }
                Text("The currently set input device will be used, and will be written as a separate audio track.")
                .font(.footnote).foregroundColor(Color.gray).padding(.leading, 2).padding(.trailing, 2).padding(.bottom, 8).fixedSize(horizontal: false, vertical: true)
            }
            Divider()
            Spacer()
            VStack(spacing: 2) {
                Button("Select output directory", action: updateOutputDirectory)
                Text("Currently set to \"\(URL(fileURLWithPath: saveDirectory!).lastPathComponent)\"").font(.footnote).foregroundColor(Color.gray)
            }.frame(maxWidth: .infinity)
        }.frame(width: 260).padding([.leading, .trailing, .top], 10)
        HStack {
            Text("Playbook AI \(getVersion()) (\(getBuild()))").foregroundColor(Color.secondary)
            Spacer()
            Text("https://hints.so")
        }.padding(12).background(VisualEffectView()).frame(height: 42)
    }

    func performMicCheck() async {
//        guard recordMic == true else { return }
//        if #available(macOS 14.0, *) {
//            if await AVAudioApplication.requestRecordPermission() {
//                return // we have perms!
//            }
//        } else {
//            // to-do: fallback for ventura
//        }
//        recordMic = false
//        DispatchQueue.main.async {
//            let alert = NSAlert()
//            alert.messageText = "Playbook AI needs permissions!"
//            alert.informativeText = "Playbook AI has to be able to record the microphone for this to work."
//            alert.addButton(withTitle: "Open Settings")
//            alert.addButton(withTitle: "No thanks")
//            alert.alertStyle = .warning
//            if alert.runModal() == .alertFirstButtonReturn {
//                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
//            }
//        }
    }

    func updateOutputDirectory() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowedContentTypes = []
        openPanel.allowsOtherFileTypes = false
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            saveDirectory = openPanel.urls.first?.path
        }
    }

    func getVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    func getBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    struct VisualEffectView: NSViewRepresentable {
        func makeNSView(context: Context) -> NSVisualEffectView { return NSVisualEffectView() }
        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}

extension AppDelegate {
    @objc func openPreferences() {
        preferences.isReleasedWhenClosed = false
        preferences.title = "Playbook AI"
        //preferences.subtitle = "Preferences"
        preferences.contentView = NSHostingView(rootView: Preferences())
        preferences.styleMask = [.titled, .closable]
        preferences.center()
        NSApp.activate(ignoringOtherApps: true)
        preferences.makeKeyAndOrderFront(nil)
    }
}
