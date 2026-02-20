//
//  UnifiedGameView.swift
//  TouchGame
//
//  Created by Frode Halrynjo on 18/02/2026.
//
import SwiftUI

struct UnifiedGameView: View {
    var mode: GameMode
    var currentTheme: AppTheme
    var onBack: () -> Void
    
    @StateObject private var engine: TypingGameEngine
    
    // Vi initialiserer motoren basert på hvilken modus vi sender inn
    init(mode: GameMode, theme: AppTheme, onBack: @escaping () -> Void) {
        self.mode = mode
        self.currentTheme = theme
        self.onBack = onBack
        _engine = StateObject(wrappedValue: TypingGameEngine(mode: mode, themeId: theme.id))
    }
    
    @State private var enableTouchKeyboard = false
    @State private var flyingCoins: [FlyingCoin] = []
    @State private var activeCursorPosition: CGPoint = .zero
    @State private var coinTargetPosition: CGPoint = .zero
    
    let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                currentTheme.background.ignoresSafeArea()
                
                // Skjult tastatur for input
                KeyboardInputView { key in engine.checkInput(key) }
                    .frame(width: 0, height: 0)
                
                VStack(spacing: isPhone ? 5 : 20) {
                    
                    // --- TOP BAR ---
                    HStack {
                        Button(action: onBack) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("MENY")
                            }
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(currentTheme.activeColor)
                        }
                        
                        Spacer()
                        
                        CoinCounterView(coins: engine.coins, theme: currentTheme)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: ViewPositionKey.self,
                                        value: ["target": geo.frame(in: .named("gameArea")).centerPoint]
                                    )
                                }
                            )
                        
                        Spacer()
                        
                        Toggle("TOUCH", isOn: $enableTouchKeyboard)
                            .toggleStyle(ThemedToggleStyle(theme: currentTheme))
                            .scaleEffect(isPhone ? 0.8 : 1.0)
                            .fixedSize()
                    }
                    .padding(.horizontal)
                    .padding(.top, isPhone ? 5 : 20)
                    
                    Spacer()
                    
                    // --- DYNAMISK HEADER (forskjellig for Story/Training) ---
                    headerView
                    
                    Spacer()
                    
                    // --- SPILLOMRÅDE ---
                    TypingAreaView(engine: engine, theme: currentTheme, geometry: geometry, isPhone: isPhone)
                    
                    // Viser statistikk og bonus når ferdig
                                        if engine.isCompleted {
                                            LevelCompleteView(
                                                theme: currentTheme,
                                                wpm: engine.wpm,
                                                accuracy: engine.accuracy,
                                                bonusWPM: engine.bonusCoinsWPM,       // Sørger for at bonus for OPM vises
                                                bonusAccuracy: engine.bonusCoinsAccuracy, // Sørger for at bonus for nøyaktighet vises
                                                onReset: engine.reset,
                                                onNext: engine.nextLevel
                                            )
                                        }

                    Spacer()
                    
                    // --- TASTATUR (hvis ikke ferdig) ---
                    if !engine.isCompleted {
                        ThemedKeyboard(
                            targetChar: engine.currentTargetChar,
                            isInteractive: enableTouchKeyboard,
                            theme: currentTheme,
                            activeColor: currentTheme.activeColor,
                            onKeyPress: { key in engine.checkInput(key) }
                        )
                        .scaleEffect(fitScale(size: geometry.size))
                        .frame(width: geometry.size.width,
                               height: 300 * fitScale(size: geometry.size)
                        )
                        .padding(.bottom, 10)
                    }
                }
                
                // --- FLYGENDE MYNTER EFFEKT ---
                FlyingCoinsOverlay(coins: flyingCoins, target: coinTargetPosition, onRemove: { id in
                    if let index = flyingCoins.firstIndex(where: { $0.id == id }) {
                        flyingCoins.remove(at: index)
                    }
                })
            }
            .coordinateSpace(name: "gameArea")
            .onPreferenceChange(ViewPositionKey.self) { prefs in
                if let target = prefs["target"] { self.coinTargetPosition = target }
                if let cursor = prefs["cursor"] { self.activeCursorPosition = cursor }
            }
            .onChange(of: engine.coins) { _ in
                if activeCursorPosition != .zero {
                    flyingCoins.append(FlyingCoin(startPoint: activeCursorPosition))
                }
            }
        }
    }
    
    // --- HJELPEVISNING FOR HEADER ---
    @ViewBuilder
    var headerView: some View {
        VStack(spacing: 5) {
            if mode == .story {
                // Story Mode Utseende
                Text("STORY MODE")
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .tracking(4)
                    .foregroundColor(currentTheme.textColor.opacity(0.6))
                
                Text(engine.currentLevel.title)
                    .font(.system(size: isPhone ? 18 : 28, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(currentTheme.activeColor)
            } else {
                // Training Mode Utseende
                Text("TRENINGSMODUL \(engine.currentLevel.id)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(currentTheme.textColor.opacity(0.8))
                
                Text(engine.currentLevel.title.uppercased())
                    .font(.system(size: isPhone ? 20 : 30, weight: .heavy, design: currentTheme.fontDesign))
                    .foregroundColor(currentTheme.activeColor)
            }
        }
    }
    
    func fitScale(size: CGSize) -> CGFloat {
            let keyboardBaseWidth: CGFloat = 850.0
            let keyboardBaseHeight: CGFloat = 300.0
            let widthScale = size.width / keyboardBaseWidth
            
            // Sjekker om skjermen er i landskapsmodus
            let isLandscape = size.width > size.height
            
            // Gir hver enhet og orientering riktig maksimal høyde
            let maxVerticalSpace: CGFloat
            if isPhone {
                // iPhone trenger å krympe tastaturet mye mer i landskap
                maxVerticalSpace = isLandscape ? 0.50 : 0.55
            } else {
                maxVerticalSpace = isLandscape ? 0.50 : 0.8
            }
            
            let heightScale = (size.height * maxVerticalSpace) / keyboardBaseHeight
            return min(widthScale, heightScale)
        }
}
