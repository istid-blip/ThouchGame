//
//  TypeGamingEngine.swift
//  TouchGame
//
//  Created by Frode Halrynjo on 18/02/2026.
//
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
    
    // Hvilken modus spiller vi?
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
    
    // Init tar nå inn hvilken modus vi vil ha
    init(mode: GameMode, themeId: String = "cyber") {
        self.mode = mode
        // Vi lagrer progress separat for story og training
        self.currentLevelIndex = UserDefaults.standard.integer(forKey: "SavedLevelIndex_\(mode)")
        self.coins = UserDefaults.standard.integer(forKey: "SavedCoins")
        self.updateStoryTheme(id: themeId)
    }
    
    func updateStoryTheme(id: String) {
        if mode == .story {
            self.storyLevels = StoryData.getLevels(for: id)
            // Tilbakestill hvis level-indexen er utenfor rekkevidde for den nye historien
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
        
        let targetChar = String(Array(targetText)[currentIndex])
        let inputMatchesEnter = (key == "\n" && targetChar == "\n")
        
        if key.lowercased() == targetChar.lowercased() || inputMatchesEnter {
            coins += 1
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                currentIndex += 1
            }
            if currentIndex == targetText.count {
                isCompleted = true
            }
        } else {
            withAnimation(.default) { shakeTrigger.toggle() }
        }
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
    }
}
