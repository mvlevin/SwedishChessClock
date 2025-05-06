import SwiftUI

enum TimeControlType: String, CaseIterable {
    case simple = "Simple"
    case increment = "Increment"
}

struct GameSettings: Equatable {
    var team1Player1Name: String = "Player1"
    var team1Player2Name: String = "Player3"
    var team2Player1Name: String = "Player2"
    var team2Player2Name: String = "Player4"
    var timeControlType: TimeControlType = .simple
    var baseMinutes: Int = 5
    var incrementSeconds: Int = 0
    
    static func == (lhs: GameSettings, rhs: GameSettings) -> Bool {
        return lhs.team1Player1Name == rhs.team1Player1Name &&
               lhs.team1Player2Name == rhs.team1Player2Name &&
               lhs.team2Player1Name == rhs.team2Player1Name &&
               lhs.team2Player2Name == rhs.team2Player2Name &&
               lhs.timeControlType == rhs.timeControlType &&
               lhs.baseMinutes == rhs.baseMinutes &&
               lhs.incrementSeconds == rhs.incrementSeconds
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
                    TextField("Player 1", text: $settings.team1Player1Name)
                    TextField("Player 2", text: $settings.team2Player1Name)
                    TextField("Player 3", text: $settings.team1Player2Name)
                    TextField("Player 4", text: $settings.team2Player2Name)
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
                    
                    if settings.timeControlType == .increment {
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