import SwiftUI

struct StoryModeView: View {
    var currentTheme: AppTheme
    var onBack: () -> Void
    
    @StateObject private var engine: TypingGameEngine
    
    // Vi lager en egen init for å kunne sende med tema-ID til motoren
    init(currentTheme: AppTheme, onBack: @escaping () -> Void) {
        self.currentTheme = currentTheme
        self.onBack = onBack
        // Her forteller vi motoren: "Vi er i Story mode, og vi bruker dette temaet!"
        _engine = StateObject(wrappedValue: TypingGameEngine(mode: .story, themeId: currentTheme.id))
    }
    
    @State private var enableTouchKeyboard = false
    // ... (resten av koden fortsetter som før)
    
    @State private var flyingCoins: [FlyingCoin] = []
    @State private var activeCursorPosition: CGPoint = .zero
    @State private var coinTargetPosition: CGPoint = .zero
    
    let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                currentTheme.background.ignoresSafeArea()
                KeyboardInputView { key in engine.checkInput(key) }
                    .frame(width: 0, height: 0)
                
                VStack(spacing: isPhone ? 5 : 20) {
                    
                    HStack {
                        Button(action: onBack) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("MENU")
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
                                        // FIX: .centerPoint
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
                    
                    VStack(spacing: 5) {
                        Text("STORY MODE")
                            .font(.system(size: 12, weight: .bold, design: .serif))
                            .tracking(4)
                            .foregroundColor(currentTheme.textColor.opacity(0.6))
                        
                        Text(engine.currentLevel.title)
                            .font(.system(size: isPhone ? 18 : 28, weight: .medium, design: .serif))
                            .italic()
                            .foregroundColor(currentTheme.activeColor)
                    }
                    
                    Spacer()
                    
                    TypingAreaView(engine: engine, theme: currentTheme, geometry: geometry, isPhone: isPhone)
                    
                    if engine.isCompleted {
                        LevelCompleteView(
                            theme: currentTheme,
                            wpm: engine.wpm,           // Send med WPM
                            accuracy: engine.accuracy, // Send med Accuracy
                            onReset: engine.reset,
                            onNext: engine.nextLevel
                        )
                    }

                    Spacer()
                    
                    if !engine.isCompleted {
                        ThemedKeyboard(
                            targetChar: engine.currentTargetChar,
                            isInteractive: enableTouchKeyboard,
                            theme: currentTheme,
                            activeColor: currentTheme.activeColor,
                            onKeyPress: { key in engine.checkInput(key) }
                        )
                        .scaleEffect(fitScale(size: geometry.size))
                        .frame(width: geometry.size.width)
                        .padding(.bottom, 10)
                    }
                }
                
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
    
    func fitScale(size: CGSize) -> CGFloat {
        let keyboardBaseWidth: CGFloat = 850.0
        let keyboardBaseHeight: CGFloat = 300.0
        let widthScale = size.width / keyboardBaseWidth
        let maxVerticalSpace = isPhone ? 0.55 : 0.8
        let heightScale = (size.height * maxVerticalSpace) / keyboardBaseHeight
        return min(widthScale, heightScale)
    }
}
