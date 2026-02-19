import SwiftUI
import Combine

// --- DATA MODELS ---

struct FlyingCoin: Identifiable {
    let id = UUID()
    let startPoint: CGPoint
}

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [String: CGPoint] = [:]
    static func reduce(value: inout [String: CGPoint], nextValue: () -> [String: CGPoint]) {
        value.merge(nextValue()) { $1 }
    }
}

enum GameMode {
    case training
    case story
    case help
}

// --- GAME ENGINE ---

class TypingGameEngine: ObservableObject {
    // --- LEVELS DATA ---
    let trainingLevels = [
        Level(id: 1, title: "Pekefingre", text: "f j f j j f j f"),
        Level(id: 2, title: "Langfingre", text: "d k d k k d k d"),
        Level(id: 3, title: "Ringfingre", text: "s l s l l s l s"),
        Level(id: 4, title: "Lillefingre", text: "a ø a ø ø a ø a"),
        Level(id: 5, title: "Hjem-raden", text: "asdf jklø"),
        Level(id: 6, title: "Små ord", text: "sjø dal laks flak")
    ]
    
    @Published var storyLevels: [Level] = []
    
    let mode: GameMode
    
    @Published var currentLevelIndex: Int {
        didSet { UserDefaults.standard.set(currentLevelIndex, forKey: "SavedLevelIndex_\(mode)") }
    }
    
    @Published var coins: Int {
        didSet { UserDefaults.standard.set(coins, forKey: "SavedCoins") }
    }
    
    @Published var currentIndex = 0
    @Published var isCompleted = false
    @Published var shakeTrigger = false
    
    // --- STATISTIKK VARIABLER ---
    @Published var wpm: Int = 0
    @Published var accuracy: Int = 100
    
    // NYE VARIABLER FOR BONUS
        @Published var bonusCoinsWPM: Int = 0
        @Published var bonusCoinsAccuracy: Int = 0
    
    private var startTime: Date?
    private var totalKeystrokes: Int = 0
    
    init(mode: GameMode, themeId: String = "cyber") {
        self.mode = mode
        self.currentLevelIndex = UserDefaults.standard.integer(forKey: "SavedLevelIndex_\(mode)")
        self.coins = UserDefaults.standard.integer(forKey: "SavedCoins")
        self.updateStoryTheme(id: themeId)
    }
    
    func updateStoryTheme(id: String) {
        if mode == .story {
            self.storyLevels = StoryData.getLevels(for: id)
            if currentLevelIndex >= storyLevels.count {
                currentLevelIndex = 0
                reset()
            }
        }
    }
    
    var activeLevels: [Level] {
        return mode == .story ? storyLevels : trainingLevels
    }
    
    var currentLevel: Level {
        if currentLevelIndex >= activeLevels.count { return activeLevels[0] }
        return activeLevels[currentLevelIndex]
    }
    
    var targetText: String { return currentLevel.text }
    
    var currentTargetChar: String {
        if currentIndex < targetText.count {
            return String(Array(targetText)[currentIndex])
        } else { return "" }
    }
    
    func checkInput(_ key: String) {
        guard currentIndex < targetText.count else { return }
        
        // --- 1. START KLOKKEN HVIS DEN IKKE ER STARTET ---
        if startTime == nil {
            startTime = Date()
        }
        
        // --- 2. TELL ALLE TASTETRYKK (FOR NØYAKTIGHET) ---
        totalKeystrokes += 1
        
        let targetChar = String(Array(targetText)[currentIndex])
        let inputMatchesEnter = (key == "\n" && targetChar == "\n")
        
        if key.lowercased() == targetChar.lowercased() || inputMatchesEnter {
            coins += 1
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                currentIndex += 1
            }
            // Sjekk om ferdig
            if currentIndex == targetText.count {
                calculateStats() // <--- VIKTIG: REGN UT FØR VI SIER FERDIG
                isCompleted = true
            }
        } else {
            withAnimation(.default) { shakeTrigger.toggle() }
        }
    }
    
    private func calculateStats() {
            guard let start = startTime else { return }
            let timeElapsed = Date().timeIntervalSince(start)
            
            // WPM: (Antall tegn / 5) / minutter
            let minutes = timeElapsed / 60.0
            let words = Double(targetText.count) / 5.0
            
            if minutes > 0 {
                self.wpm = Int(words / minutes)
            }
            
            // Accuracy
            if totalKeystrokes > 0 {
                let acc = (Double(targetText.count) / Double(totalKeystrokes)) * 100
                self.accuracy = Int(acc)
            }
            
            // --- BEREGN BONUS MYNTER ---
            var wpmBonus = 0
            if self.wpm > 60 { wpmBonus = 30 }
            else if self.wpm > 40 { wpmBonus = 20 }
            else if self.wpm > 20 { wpmBonus = 10 }
            
            var accBonus = 0
            if self.accuracy == 100 { accBonus = 50 }
            else if self.accuracy >= 95 { accBonus = 25 }
            else if self.accuracy >= 90 { accBonus = 10 }
            
            self.bonusCoinsWPM = wpmBonus
            self.bonusCoinsAccuracy = accBonus
            
            // Legg til bonus i total-økonomien
            self.coins += (wpmBonus + accBonus)
        }
    
    func nextLevel() {
        if currentLevelIndex < activeLevels.count - 1 {
            currentLevelIndex += 1
        } else {
            currentLevelIndex = 0
        }
        reset()
    }
    
    func reset() {
            currentIndex = 0
            isCompleted = false
            // --- NULLSTILL STATISTIKK ---
            startTime = nil
            totalKeystrokes = 0
            wpm = 0
            accuracy = 100
            
            // Nullstill bonus
            bonusCoinsWPM = 0
            bonusCoinsAccuracy = 0
        }
}
