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
                
                // Main layout with 2 boards side by side
                HStack(spacing: 0) {
                    // Left side - Board 1 (Team 1 & 2)
                    VStack(spacing: 0) {
                        // Board 1 - Team 1
                        ZStack {
                            Rectangle()
                                .fill(board1State.activeTeam == 1 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            VStack {
                                Text(board1State.settings.player1Name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text(timeString(board1State.timeRemaining1))
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(board1State.timeRemaining1 < 10 ? .red : .primary)
                            }
                        }
                        .onTapGesture {
                            board1State.toggleClock()
                        }
                        
                        // Board 1 - Team 2
                        ZStack {
                            Rectangle()
                                .fill(board1State.activeTeam == 2 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            VStack {
                                Text(board1State.settings.player2Name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text(timeString(board1State.timeRemaining2))
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(board1State.timeRemaining2 < 10 ? .red : .primary)
                            }
                        }
                        .onTapGesture {
                            board1State.toggleClock()
                        }
                    }
                    
                    // Right side - Board 2 (Team 3 & 4)
                    VStack(spacing: 0) {
                        // Board 2 - Team 3
                        ZStack {
                            Rectangle()
                                .fill(board2State.activeTeam == 1 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            VStack {
                                Text(board2State.settings.player3Name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text(timeString(board2State.timeRemaining1))
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(board2State.timeRemaining1 < 10 ? .red : .primary)
                            }
                        }
                        .onTapGesture {
                            board2State.toggleClock()
                        }
                        
                        // Board 2 - Team 4
                        ZStack {
                            Rectangle()
                                .fill(board2State.activeTeam == 2 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            VStack {
                                Text(board2State.settings.player4Name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text(timeString(board2State.timeRemaining2))
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(board2State.timeRemaining2 < 10 ? .red : .primary)
                            }
                        }
                        .onTapGesture {
                            board2State.toggleClock()
                        }
                    }
                }
                
                // Overlay controls
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: {
                            board1State.togglePause()
                            board2State.togglePause()
                        }) {
                            Image(systemName: board1State.isPaused ? "play.fill" : "pause.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(!board1State.isRunning)
                        
                        Button(action: {
                            board1State.startNewGame()
                            board2State.startNewGame()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarItems(trailing: Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.primary)
            })
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: $settings, isGameRunning: board1State.isRunning)
        }
        .onChange(of: settings) { newSettings in
            board1State.settings = newSettings
            board2State.settings = newSettings
            // Reset both boards with new settings
            board1State.startNewGame()
            board2State.startNewGame()
        }
        .alert("Game Over", isPresented: $board1State.gameOver) {
            Button("New Game") {
                board1State.startNewGame()
                board2State.startNewGame()
            }
            Button("Keep Current State", role: .cancel) {}
        } message: {
            if board1State.winningTeam == 1 {
                Text("\(board1State.settings.player1Name) and \(board1State.settings.player2Name) win!")
            } else {
                Text("\(board1State.settings.player3Name) and \(board1State.settings.player4Name) win!")
            }
        }
    }
    
    private func timeString(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let tenths = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
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