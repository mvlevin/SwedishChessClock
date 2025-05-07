import SwiftUI

struct ContentView: View {
    @State private var settings: GameSettings
    @StateObject private var board1State: GameState
    @StateObject private var board2State: GameState
    @State private var showingSettings = false
    
    init(settings: GameSettings) {
        _settings = State(initialValue: settings)
        _board1State = StateObject(wrappedValue: GameState(settings: settings))
        _board2State = StateObject(wrappedValue: GameState(settings: settings))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                // Main layout with top team vs bottom team
                VStack(spacing: 0) {
                    // Top team (Players 1 and 3)
                    HStack(spacing: 0) {
                        // Left side (Player 1)
                        VStack {
                            Text(settings.player1Name)
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ZStack {
                                Rectangle()
                                    .fill(board1State.activeTeam == 1 ? Color.green.opacity(0.3) : Color.clear)
                                    .frame(height: 100)
                                
                                Text(formatTime(board1State.timeRemaining1))
                                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                            }
                            .onTapGesture {
                                if !board1State.gameOver {
                                    board1State.toggleClock()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right side (Player 3)
                        VStack {
                            Text(settings.player3Name)
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ZStack {
                                Rectangle()
                                    .fill(board2State.activeTeam == 1 ? Color.green.opacity(0.3) : Color.clear)
                                    .frame(height: 100)
                                
                                Text(formatTime(board2State.timeRemaining1))
                                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                            }
                            .onTapGesture {
                                if !board2State.gameOver {
                                    board2State.toggleClock()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Bottom team (Players 2 and 4)
                    HStack(spacing: 0) {
                        // Left side (Player 2)
                        VStack {
                            Text(settings.player2Name)
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ZStack {
                                Rectangle()
                                    .fill(board1State.activeTeam == 2 ? Color.green.opacity(0.3) : Color.clear)
                                    .frame(height: 100)
                                
                                Text(formatTime(board1State.timeRemaining2))
                                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                            }
                            .onTapGesture {
                                if !board1State.gameOver {
                                    board1State.toggleClock()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right side (Player 4)
                        VStack {
                            Text(settings.player4Name)
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ZStack {
                                Rectangle()
                                    .fill(board2State.activeTeam == 2 ? Color.green.opacity(0.3) : Color.clear)
                                    .frame(height: 100)
                                
                                Text(formatTime(board2State.timeRemaining2))
                                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                            }
                            .onTapGesture {
                                if !board2State.gameOver {
                                    board2State.toggleClock()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Swedish Chess Clock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            // Force landscape orientation
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

class GameState: ObservableObject {
    @Published var settings: GameSettings
    @Published var timeRemaining1: TimeInterval
    @Published var timeRemaining2: TimeInterval
    @Published var activeTeam: Int = 0  // 0: none, 1: team1, 2: team2
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var gameOver: Bool = false
    @Published var winningTeam: Int = 0  // 0: none, 1: team1, 2: team2
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 0.1
    
    init(settings: GameSettings) {
        self.settings = settings
        self.timeRemaining1 = TimeInterval(settings.baseMinutes * 60)
        self.timeRemaining2 = TimeInterval(settings.baseMinutes * 60)
    }
    
    func toggleClock() {
        if !isRunning {
            // Start the game with the opposite team
            activeTeam = activeTeam == 1 ? 2 : 1
            isRunning = true
            startTimer()
        } else if !isPaused {
            // Switch to the other team
            activeTeam = activeTeam == 1 ? 2 : 1
            
            // Add increment if using increment time control
            if settings.timeControlType == .rapid || settings.timeControlType == .blitz || settings.timeControlType == .bullet {
                if activeTeam == 1 {
                    timeRemaining1 += TimeInterval(settings.incrementSeconds)
                } else {
                    timeRemaining2 += TimeInterval(settings.incrementSeconds)
                }
            }
        }
    }
    
    func startNewGame() {
        isRunning = false
        isPaused = false
        gameOver = false
        activeTeam = 0
        winningTeam = 0
        timeRemaining1 = TimeInterval(settings.baseMinutes * 60)
        timeRemaining2 = TimeInterval(settings.baseMinutes * 60)
        timer?.invalidate()
        timer = nil
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
            timer = nil
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.activeTeam == 1 {
                self.timeRemaining1 -= self.updateInterval
                if self.timeRemaining1 <= 0 {
                    self.timeRemaining1 = 0
                    self.gameOver = true
                    self.winningTeam = 2
                    self.timer?.invalidate()
                    self.timer = nil
                }
            } else if self.activeTeam == 2 {
                self.timeRemaining2 -= self.updateInterval
                if self.timeRemaining2 <= 0 {
                    self.timeRemaining2 = 0
                    self.gameOver = true
                    self.winningTeam = 1
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
}

#Preview {
    ContentView(settings: GameSettings())
} 