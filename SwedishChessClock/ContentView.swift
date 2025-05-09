import SwiftUI

struct ContentView: View {
    @ObservedObject var settings: GameSettings
    @StateObject var board1State: GameState
    @StateObject private var board2State: GameState
    @State private var showingSettings = false
    
    init(settings: GameSettings) {
        self.settings = settings
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
                                    board1State.toggleClock(forTeam: 1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .rotationEffect(.degrees(180))
                        
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
                                    board2State.toggleClock(forTeam: 1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .rotationEffect(.degrees(180))
                    }
                    
                    // Control buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            board1State.togglePause()
                            board2State.togglePause()
                        }) {
                            Image(systemName: board1State.isPaused ? "play.fill" : "pause.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            board1State.startNewGame()
                            board2State.startNewGame()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 10)
                    
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
                                    board1State.toggleClock(forTeam: 2)
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
                                    board2State.toggleClock(forTeam: 2)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                    .disabled(board1State.isRunning || board1State.viewingFinalState)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
            .alert("Game Over", isPresented: $board1State.showGameOverAlert) {
                Button("New Game") {
                    board1State.startNewGame()
                    board2State.startNewGame()
                }
                Button("View Final State") {
                    board1State.viewingFinalState = true
                    board2State.viewingFinalState = true
                }
            } message: {
                Text("\(board1State.getWinningTeamNames()) have won!")
            }
            .onReceive(NotificationCenter.default.publisher(for: .timeControlChanged)) { _ in
                if !board1State.isRunning {
                    board1State.timeRemaining1 = TimeInterval(settings.baseMinutes * 60)
                    board1State.timeRemaining2 = TimeInterval(settings.baseMinutes * 60)
                    board2State.timeRemaining1 = TimeInterval(settings.baseMinutes * 60)
                    board2State.timeRemaining2 = TimeInterval(settings.baseMinutes * 60)
                }
            }
            .onAppear {
                // Force landscape orientation
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                
                // Connect the boards to each other
                board1State.otherBoard = board2State
                board2State.otherBoard = board1State
            }
            .onChange(of: settings) { newSettings in
                board1State.settings = newSettings
                board2State.settings = newSettings
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let deciseconds = Int((timeInterval * 10).truncatingRemainder(dividingBy: 10))
        return String(format: "%02d:%02d.%01d", minutes, seconds, deciseconds)
    }
}

class GameState: ObservableObject {
    @Published var settings: GameSettings {
        didSet {
            // Update player names when settings change
            objectWillChange.send()
        }
    }
    @Published var timeRemaining1: TimeInterval
    @Published var timeRemaining2: TimeInterval
    @Published var activeTeam: Int = 0  // 0: none, 1: team1, 2: team2
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var gameOver: Bool = false
    @Published var winningTeam: Int = 0  // 0: none, 1: team1, 2: team2
    @Published var showGameOverAlert: Bool = false
    @Published var viewingFinalState: Bool = false
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 0.1
    weak var otherBoard: GameState?
    
    init(settings: GameSettings) {
        self.settings = settings
        self.timeRemaining1 = TimeInterval(settings.baseMinutes * 60)
        self.timeRemaining2 = TimeInterval(settings.baseMinutes * 60)
    }
    
    func resetGame() {
        timeRemaining1 = TimeInterval(settings.baseMinutes * 60)
        timeRemaining2 = TimeInterval(settings.baseMinutes * 60)
        activeTeam = 0
        isRunning = false
        isPaused = false
        gameOver = false
        winningTeam = 0
        showGameOverAlert = false
        viewingFinalState = false
        timer?.invalidate()
        timer = nil
    }
    
    func toggleClock(forTeam team: Int) {
        // First check if the game is already over (either from this board or the other board)
        if gameOver || (otherBoard?.gameOver ?? false) {
            return
        }
        
        // Check if time has run out for either team
        if (activeTeam == 1 && timeRemaining1 <= 0) || (activeTeam == 2 && timeRemaining2 <= 0) {
            endGame(winningTeam: activeTeam == 1 ? 2 : 1)
            return
        }
        
        if !isRunning {
            // Start the game with the opposing team active
            activeTeam = team == 1 ? 2 : 1
            isRunning = true
            startTimer()
        } else if !isPaused && activeTeam == team {
            // Only switch if the active team tapped
            activeTeam = activeTeam == 1 ? 2 : 1
            
            // Add increment if using increment time control
            if settings.timeControlType == .increment {
                let initialTime = TimeInterval(settings.baseMinutes * 60)
                if team == 1 {
                    timeRemaining1 = min(timeRemaining1 + TimeInterval(settings.incrementSeconds), initialTime)
                } else {
                    timeRemaining2 = min(timeRemaining2 + TimeInterval(settings.incrementSeconds), initialTime)
                }
            }
        }
    }
    
    func startNewGame() {
        resetGame()
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
            
            // Don't decrease time if game is over
            if self.gameOver || (self.otherBoard?.gameOver ?? false) {
                self.timer?.invalidate()
                self.timer = nil
                return
            }
            
            if self.activeTeam == 1 {
                self.timeRemaining1 -= self.updateInterval
                if self.timeRemaining1 <= 0 {
                    self.timeRemaining1 = 0
                    self.gameOver = true
                    self.endGame(winningTeam: 2)
                }
            } else if self.activeTeam == 2 {
                self.timeRemaining2 -= self.updateInterval
                if self.timeRemaining2 <= 0 {
                    self.timeRemaining2 = 0
                    self.gameOver = true
                    self.endGame(winningTeam: 1)
                }
            }
        }
    }
    
    private func endGame(winningTeam: Int) {
        // Stop this board's timer and update state
        self.gameOver = true
        self.winningTeam = winningTeam
        self.isRunning = false
        self.activeTeam = 0
        self.timer?.invalidate()
        self.timer = nil
        self.isPaused = false
        self.showGameOverAlert = true
        
        // Stop the other board's timer and update its state
        if let otherBoard = otherBoard {
            otherBoard.gameOver = true
            otherBoard.winningTeam = winningTeam
            otherBoard.isRunning = false
            otherBoard.activeTeam = 0
            otherBoard.timer?.invalidate()
            otherBoard.timer = nil
            otherBoard.isPaused = false
            otherBoard.showGameOverAlert = true
        }
    }
    
    func stopGame() {
        self.gameOver = true
        self.isRunning = false
        self.activeTeam = 0
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func getWinningTeamNames() -> String {
        if winningTeam == 1 {
            return "\(settings.player1Name) and \(settings.player3Name)"
        } else if winningTeam == 2 {
            return "\(settings.player2Name) and \(settings.player4Name)"
        }
        return ""
    }
}

#Preview {
    ContentView(settings: GameSettings())
} 