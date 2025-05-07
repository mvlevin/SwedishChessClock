import Foundation
import SwiftUI

class GameState: ObservableObject {
    @Published var settings: GameSettings
    @Published var timeRemaining: TimeInterval
    @Published var isActive: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 0.1
    
    init(settings: GameSettings) {
        self.settings = settings
        self.timeRemaining = TimeInterval(settings.baseMinutes * 60)
    }
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        let tenths = Int((timeRemaining.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
    
    func toggleClock() {
        if isPaused {
            isPaused = false
            startTimer()
        } else {
            isActive.toggle()
            if isActive {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    func stopClock() {
        isActive = false
        stopTimer()
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
        } else if isActive {
            startTimer()
        }
    }
    
    func startNewGame() {
        stopTimer()
        timeRemaining = TimeInterval(settings.baseMinutes * 60)
        isActive = false
        isGameOver = false
        isPaused = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isActive && !self.isPaused {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= self.updateInterval
                    if self.timeRemaining <= 0 {
                        self.timeRemaining = 0
                        self.isGameOver = true
                        self.stopTimer()
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
} 