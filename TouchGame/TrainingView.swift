import SwiftUI

struct TrainingView: View {
    var currentTheme: AppTheme
    var onBack: () -> Void
    
    @StateObject private var engine: TypingGameEngine
    
    init(currentTheme: AppTheme, onBack: @escaping () -> Void) {
        self.currentTheme = currentTheme
        self.onBack = onBack
        // Training mode trenger strengt tatt ikke themeId, men init krever det nå (valgfritt)
        _engine = StateObject(wrappedValue: TypingGameEngine(mode: .training, themeId: currentTheme.id))
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
                        Text("TRAINING MODULE \(engine.currentLevel.id)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(currentTheme.textColor.opacity(0.8))
                        
                        Text(engine.currentLevel.title.uppercased())
                            .font(.system(size: isPhone ? 20 : 30, weight: .heavy, design: currentTheme.fontDesign))
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
