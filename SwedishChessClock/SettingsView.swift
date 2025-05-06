import SwiftUI

enum TimeControlType: String, CaseIterable {
    case classical = "Classical"
    case rapid = "Rapid"
    case blitz = "Blitz"
    case bullet = "Bullet"
}

class GameSettings: ObservableObject, Equatable {
    @Published var player1Name: String = "Player 1"
    @Published var player2Name: String = "Player 2"
    @Published var player3Name: String = "Player 3"
    @Published var player4Name: String = "Player 4"
    @Published var baseMinutes: Int = 5
    @Published var incrementSeconds: Int = 0
    @Published var timeControlType: TimeControlType = .rapid
    
    static func == (lhs: GameSettings, rhs: GameSettings) -> Bool {
        return lhs.player1Name == rhs.player1Name &&
               lhs.player2Name == rhs.player2Name &&
               lhs.player3Name == rhs.player3Name &&
               lhs.player4Name == rhs.player4Name &&
               lhs.baseMinutes == rhs.baseMinutes &&
               lhs.incrementSeconds == rhs.incrementSeconds &&
               lhs.timeControlType == rhs.timeControlType
    }
}

struct SettingsView: View {
    @Binding var settings: GameSettings
    let isGameRunning: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var baseMinutesText: String = ""
    @State private var incrementSecondsText: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Names")) {
                    TextField("Player 1", text: $settings.player1Name)
                    TextField("Player 2", text: $settings.player2Name)
                    TextField("Player 3", text: $settings.player3Name)
                    TextField("Player 4", text: $settings.player4Name)
                }
                
                Section(header: Text("Time Control")) {
                    Picker("Type", selection: $settings.timeControlType) {
                        ForEach(TimeControlType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Base Time (minutes):")
                        TextField("Minutes", text: $baseMinutesText)
                            .keyboardType(.numberPad)
                            .onChange(of: baseMinutesText) { newValue in
                                if let minutes = Int(newValue), minutes >= 1, minutes <= 60 {
                                    settings.baseMinutes = minutes
                                }
                            }
                            .onAppear {
                                baseMinutesText = String(settings.baseMinutes)
                            }
                    }
                    
                    if settings.timeControlType == .rapid || settings.timeControlType == .blitz || settings.timeControlType == .bullet {
                        HStack {
                            Text("Increment (seconds):")
                            TextField("Seconds", text: $incrementSecondsText)
                                .keyboardType(.numberPad)
                                .onChange(of: incrementSecondsText) { newValue in
                                    if let seconds = Int(newValue), seconds >= 0, seconds <= 60 {
                                        settings.incrementSeconds = seconds
                                    }
                                }
                                .onAppear {
                                    incrementSecondsText = String(settings.incrementSeconds)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    SettingsView(settings: .constant(GameSettings()), isGameRunning: false)
} 