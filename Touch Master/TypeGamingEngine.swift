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
            // DEL 1: Hjem-raden (Grunnposisjon)
            Level(id: 1, title: "Pekefingre (og tommelfinger)", text: "f j f j j f j f"),
            Level(id: 2, title: "Langfingre (og tommelfinger)", text: "d k d k k d k d"),
            Level(id: 3, title: "Ringfingre (og tommelfinger)", text: "s l s l l s l s"),
            Level(id: 4, title: "Lillefingre (og tommelfinger)", text: "a ø a ø ø a ø a"),
            Level(id: 5, title: "Hjem-raden", text: "asdf jklø"),
            Level(id: 6, title: "Pekefingre strekk (G og H)", text: "f g f j h j f g f j h j"),
            Level(id: 7, title: "Lillefinger strekk (Æ)", text: "ø æ ø a æ a ø æ ø"),
            Level(id: 8, title: "Ord på hjem-raden", text: "sjø dal laks flak halm hage glass"),
            
            // DEL 2: Øvre rad
            Level(id: 9, title: "Øvre rad - Pekefingre (R, T, U, Y)", text: "f r f j u j f t f j y j"),
            Level(id: 10, title: "Øvre rad - Langfingre (E, I)", text: "d e d k i k d e d k i k"),
            Level(id: 11, title: "Øvre rad - Ringfingre (W, O)", text: "s w s l o l s w s l o l"),
            Level(id: 12, title: "Øvre rad - Lillefingre (Q, P, Å)", text: "a q a ø p ø æ å æ"),
            Level(id: 13, title: "Ord med øvre rad", text: "tre rute purre type kopi stål"),
            
            // DEL 3: Nedre rad
            Level(id: 14, title: "Nedre rad - Pekefingre (V, B, M, N)", text: "f v f j m j f b f j n j"),
            Level(id: 15, title: "Nedre rad - Langfingre (C, ,)", text: "d c d k , k d c d k , k"),
            Level(id: 16, title: "Nedre rad - Ringfingre (X, .)", text: "s x s l . l s x s l . l"),
            Level(id: 17, title: "Nedre rad - Lillefinger (Z, -)", text: "a z a ø - ø a z a ø - ø"),
            Level(id: 18, title: "Ord med nedre rad", text: "sykkel vindu paraply zoo max"),
            
            // DEL 4: Avansert og flyt
            Level(id: 19, title: "Korte setninger", text: "jeg vil ha is. du er god."),
            Level(id: 20, title: "Store bokstaver (Shift)", text: "Per og Kari. Harstad er bra."),
            Level(id: 21, title: "Blandet praksis", text: "Kjappe rever hopper over late hunder."),
            Level(id: 22, title: "Mesterprøven", text: "Touchmetoden gjør meg raskere og mer effektiv!")
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
