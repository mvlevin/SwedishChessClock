import SwiftUI

struct ContentView: View {
    @StateObject private var board1State = GameState(settings: GameSettings())
    @StateObject private var board2State = GameState(settings: GameSettings())
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // Main layout with 4 player zones
            HStack(spacing: 0) {
                // Team 1 (Left side)
                VStack(spacing: 0) {
                    // Board 1 - Player 1
                    ZStack {
                        Rectangle()
                            .fill(board1State.activeTeam == 1 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        VStack {
                            Text(board1State.settings.team1Player1Name)
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
                    
                    // Board 2 - Player 3
                    ZStack {
                        Rectangle()
                            .fill(board2State.activeTeam == 1 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        VStack {
                            Text(board2State.settings.team1Player2Name)
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
                }
                
                // Team 2 (Right side)
                VStack(spacing: 0) {
                    // Board 1 - Player 2
                    ZStack {
                        Rectangle()
                            .fill(board1State.activeTeam == 2 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        VStack {
                            Text(board1State.settings.team2Player1Name)
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
                    
                    // Board 2 - Player 4
                    ZStack {
                        Rectangle()
                            .fill(board2State.activeTeam == 2 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        VStack {
                            Text(board2State.settings.team2Player2Name)
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
            
            // Settings button overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: $board1State.settings, isGameRunning: board1State.isRunning)
        }
        .onChange(of: board1State.settings) { newSettings in
            board2State.settings = newSettings
            // Reset both boards with new settings
            board1State.startNewGame()
            board2State.startNewGame()
        }
        .alert("Game Over", isPresented: $board1State.gameOver) {
            VStack {
                Button("New Game") {
                    board1State.startNewGame()
                    board2State.startNewGame()
                }
                Button("Keep Current State", role: .cancel) {}
            }
        } message: {
            if board1State.winningTeam == 1 {
                Text("\(board1State.settings.team1Player1Name) and \(board1State.settings.team1Player2Name) win!")
            } else {
                Text("\(board1State.settings.team2Player1Name) and \(board1State.settings.team2Player2Name) win!")
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
            if settings.timeControlType == .increment {
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
    ContentView()
} 