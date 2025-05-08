import SwiftUI

enum TimeControlType: String, CaseIterable {
    case classical = "Classical"
    case increment = "Increment"
}

class GameSettings: ObservableObject, Equatable {
    // Player 1 and 3 are in the Top team (opposing each other)
    // Player 2 and 4 are in the Bottom team (opposing each other)
    @Published var player1Name: String = "Top Team - Left"
    @Published var player2Name: String = "Bottom Team - Left"
    @Published var player3Name: String = "Top Team - Right"
    @Published var player4Name: String = "Bottom Team - Right"
    @Published var baseMinutes: Int = 5 {
        didSet {
            resetClocks()
        }
    }
    @Published var incrementSeconds: Int = 0
    @Published var timeControlType: TimeControlType = .classical {
        didSet {
            if timeControlType == .classical {
                incrementSeconds = 0
            }
            resetClocks()
        }
    }
    
    var gameState: GameState?
    
    func resetClocks() {
        if let state = gameState {
            state.resetGame()
        }
    }
    
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
    @ObservedObject var settings: GameSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Top Team")) {
                    TextField("Left Player Name", text: $settings.player1Name)
                    TextField("Right Player Name", text: $settings.player3Name)
                }
                
                Section(header: Text("Bottom Team")) {
                    TextField("Left Player Name", text: $settings.player2Name)
                    TextField("Right Player Name", text: $settings.player4Name)
                }
                
                Section(header: Text("Time Control")) {
                    Picker("Type", selection: $settings.timeControlType) {
                        ForEach(TimeControlType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Stepper("Base Time: \(settings.baseMinutes) min", value: $settings.baseMinutes, in: 1...60)
                    
                    if settings.timeControlType == .increment {
                        Stepper("Increment: \(settings.incrementSeconds) sec", value: $settings.incrementSeconds, in: 0...30)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(settings: GameSettings())
} 