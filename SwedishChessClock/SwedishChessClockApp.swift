import SwiftUI

@main
struct SwedishChessClockApp: App {
    @StateObject private var settings = GameSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
                .preferredColorScheme(.light)
        }
    }
} 