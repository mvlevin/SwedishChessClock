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
            if oldValue != baseMinutes {
                NotificationCenter.default.post(name: .timeControlChanged, object: nil)
            }
        }
    }
    @Published var incrementSeconds: Int = 0 {
        didSet {
            if oldValue != incrementSeconds {
                NotificationCenter.default.post(name: .timeControlChanged, object: nil)
            }
        }
    }
    @Published var timeControlType: TimeControlType = .classical {
        didSet {
            if oldValue != timeControlType {
                if timeControlType == .classical {
                    incrementSeconds = 0
                }
                NotificationCenter.default.post(name: .timeControlChanged, object: nil)
            }
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

extension Notification.Name {
    static let timeControlChanged = Notification.Name("timeControlChanged")
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: GameSettings
    @State private var tempSettings: GameSettings
    @State private var isGameRunning: Bool
    
    init(settings: GameSettings) {
        self.settings = settings
        _tempSettings = State(initialValue: settings)
        _isGameRunning = State(initialValue: false)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Names")) {
                    TextField("Player 1 (Top Left)", text: $tempSettings.player1Name)
                    TextField("Player 2 (Bottom Left)", text: $tempSettings.player2Name)
                    TextField("Player 3 (Top Right)", text: $tempSettings.player3Name)
                    TextField("Player 4 (Bottom Right)", text: $tempSettings.player4Name)
                }
                
                Section(header: Text("Time Control")) {
                    Picker("Type", selection: $tempSettings.timeControlType) {
                        ForEach(TimeControlType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .disabled(isGameRunning)
                    
                    Stepper("Base Time: \(tempSettings.baseMinutes) minutes", value: $tempSettings.baseMinutes, in: 1...60)
                        .disabled(isGameRunning)
                    
                    if tempSettings.timeControlType == .increment {
                        Stepper("Increment: \(tempSettings.incrementSeconds) seconds", value: $tempSettings.incrementSeconds, in: 0...30)
                            .disabled(isGameRunning)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        settings.player1Name = tempSettings.player1Name
                        settings.player2Name = tempSettings.player2Name
                        settings.player3Name = tempSettings.player3Name
                        settings.player4Name = tempSettings.player4Name
                        settings.baseMinutes = tempSettings.baseMinutes
                        settings.incrementSeconds = tempSettings.incrementSeconds
                        settings.timeControlType = tempSettings.timeControlType
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Check if game is running
            if let gameState = (UIApplication.shared.windows.first?.rootViewController as? UIHostingController<ContentView>)?.rootView.board1State {
                isGameRunning = gameState.isRunning && !gameState.gameOver
            }
        }
    }
}

#Preview {
    SettingsView(settings: GameSettings())
} 