import SwiftUI
import Combine
import UIKit

// ==========================================
// DEL 1: DATAMODELLER OG SPILLMOTOR (SHARED)
// ==========================================



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

// ==========================================
// DEL 2: DELTE UI-KOMPONENTER (HELPER VIEWS)
// ==========================================

struct CoinCounterView: View {
    let coins: Int
    let theme: AppTheme
    let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "dollarsign.circle.fill")
                .foregroundColor(.yellow)
            Text("\(coins)")
                .font(.system(size: isPhone ? 16 : 22, weight: .bold, design: .monospaced))
                .foregroundColor(["candy", "rainbow"].contains(theme.id) ? .black : .white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            ["candy", "rainbow"].contains(theme.id)
            ? Color.white.opacity(0.6)
            : Color.black.opacity(0.6)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.activeColor.opacity(0.5), lineWidth: 1)
        )
    }
}

struct LevelCompleteView: View {
    let theme: AppTheme
    let onReset: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Text("COMPLETE!")
                .font(.title)
                .foregroundColor(theme.activeColor)
                .padding()
                .background(Color.black.opacity(0.8).cornerRadius(10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.activeColor, lineWidth: 2))
            
            HStack(spacing: 20) {
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .padding()
                        .background(theme.kbdKeyFill.opacity(0.9))
                        .cornerRadius(8)
                        .foregroundColor(theme.textColor)
                }
                
                Button("CONTINUE") { onNext() }
                    .font(.headline)
                    .padding()
                    .background(theme.activeColor)
                    .foregroundColor(theme.id == "cyber" || theme.id == "matrix" ? .black : .white)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
        }
    }
}

struct TypingAreaView: View {
    @ObservedObject var engine: TypingGameEngine
    var theme: AppTheme
    var geometry: GeometryProxy
    var isPhone: Bool
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(Array(engine.targetText.enumerated()), id: \.offset) { index, char in
                    let isActive = (index == engine.currentIndex)
                    let fontSize = min(geometry.size.width / 13, isPhone ? 45 : 70)
                    
                    Text(String(char))
                        .font(.system(size: fontSize, weight: .bold, design: theme.fontDesign))
                        .foregroundColor(getColor(at: index))
                        .overlay(alignment: .bottom) {
                            if char == " " {
                                Rectangle()
                                    .fill(getColor(at: index))
                                    .frame(height: isPhone ? 3 : 5)
                                    .offset(y: isPhone ? 5 : 10)
                            }
                        }
                        .background(
                            isActive ? GeometryReader { geo in
                                Color.clear.preference(
                                    key: ViewPositionKey.self,
                                    // FIX: Endret fra .center til .centerPoint
                                    value: ["cursor": geo.frame(in: .named("gameArea")).centerPoint]
                                )
                            } : nil
                        )
                        .shadow(color: isActive ? theme.activeColor : .clear, radius: isActive ? 15 : 0)
                        .zIndex(isActive ? 1 : 0)
                }
            }
        }
        .modifier(ShakeEffect(animatableData: engine.shakeTrigger ? 1 : 0))
    }
    
    func getRainbowColor(at index: Int) -> Color {
        let hue = Double(index % 20) / 20.0
        return Color(hue: hue, saturation: 0.8, brightness: 1.0)
    }

    func getColor(at index: Int) -> Color {
        if index < engine.currentIndex { return theme.completedColor }
        else if index == engine.currentIndex {
            if theme.id == "rainbow" { return getRainbowColor(at: index) }
            return theme.activeColor
        }
        else { return theme.textColor }
    }
}

struct FlyingCoinsOverlay: View {
    let coins: [FlyingCoin]
    let target: CGPoint
    let onRemove: (UUID) -> Void
    
    var body: some View {
        ForEach(coins) { coin in
            FlyingCoinView(
                start: coin.startPoint,
                end: target,
                onComplete: { onRemove(coin.id) }
            )
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(maxWidth: 300)
            .background(theme.activeColor.opacity(0.1))
            .foregroundColor(theme.activeColor)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(theme.activeColor, lineWidth: 2)
            )
        }
    }
}

// --- STANDARD KOMPONENTER ---

struct FlyingCoinView: View {
    let start: CGPoint
    let end: CGPoint
    let onComplete: () -> Void
    @State private var position: CGPoint
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 0.5
    
    init(start: CGPoint, end: CGPoint, onComplete: @escaping () -> Void) {
        self.start = start
        self.end = end
        self.onComplete = onComplete
        _position = State(initialValue: start)
    }

    var body: some View {
        Image(systemName: "dollarsign.circle.fill")
            .font(.title)
            .foregroundColor(.yellow)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            .scaleEffect(scale)
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    position = end
                    scale = 1.0
                }
                withAnimation(.easeIn(duration: 0.2).delay(0.5)) {
                    opacity = 0
                    scale = 0.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    onComplete()
                }
            }
    }
}

class InvisibleTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect { .zero }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { false }
}

struct KeyboardInputView: UIViewRepresentable {
    var onKeyPress: (String) -> Void
    func makeUIView(context: Context) -> InvisibleTextField {
        let textField = InvisibleTextField()
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.spellCheckingType = .no
        textField.inputView = UIView()
        textField.becomeFirstResponder()
        return textField
    }
    func updateUIView(_ uiView: InvisibleTextField, context: Context) {
        if !uiView.isFirstResponder { uiView.becomeFirstResponder() }
    }
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KeyboardInputView
        init(parent: KeyboardInputView) { self.parent = parent }
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if !string.isEmpty { parent.onKeyPress(string) }
            return false
        }
    }
}

struct ThemedToggleStyle: ToggleStyle {
    var theme: AppTheme
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(configuration.isOn ? theme.activeColor : .gray)
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.6))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(configuration.isOn ? theme.activeColor.opacity(0.6) : .gray.opacity(0.3), lineWidth: 2))
                    .shadow(color: configuration.isOn ? theme.activeColor.opacity(0.6) : .clear, radius: 8)
                    .frame(width: 50, height: 26)
                RoundedRectangle(cornerRadius: 2)
                    .fill(configuration.isOn ? theme.activeColor : .gray)
                    .frame(width: 20, height: 18)
                    .padding(4)
                    .offset(x: configuration.isOn ? 12 : -12)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
            }
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

// ==========================================
// DEL 3: HOVEDMENYEN (CONTENTVIEW)
// ==========================================

struct ContentView: View {
    @State private var currentThemeIndex = 0
    @State private var selectedMode: GameMode? = nil
    
    var currentTheme: AppTheme {
        return AppTheme.allThemes[currentThemeIndex]
    }
    
    var body: some View {
        if let mode = selectedMode {
            switch mode {
            case .training:
                TrainingView(currentTheme: currentTheme, onBack: { selectedMode = nil })
            case .story:
                StoryModeView(currentTheme: currentTheme, onBack: { selectedMode = nil })
            case .help: //
                            ConnectionHelpView(theme: currentTheme, onBack: { selectedMode = nil })
                        }
            
        } else {
            ZStack {
                currentTheme.background.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    VStack(spacing: 10) {
                        Text("TOUCH MASTER")
                            .font(.system(size: 40, weight: .black, design: currentTheme.fontDesign))
                            .foregroundColor(currentTheme.activeColor)
                            .shadow(color: currentTheme.activeColor.opacity(0.5), radius: 10)
                        Text("SELECT MODE")
                            .font(.headline)
                            .tracking(4)
                            .foregroundColor(currentTheme.textColor.opacity(0.7))
                    }
                    .padding(.top, 50)
                    
                    VStack(spacing: 20) {
                        MenuButton(title: "TRAINING", icon: "keyboard", theme: currentTheme) {
                            withAnimation { selectedMode = .training }
                        }
                        MenuButton(title: "STORY MODE", icon: "book.closed.fill", theme: currentTheme) {
                            withAnimation { selectedMode = .story }
                            
                        }
                        MenuButton(title: "CONNECT KEYBOARD", icon: "cable.connector", theme: currentTheme) {
                                                    withAnimation { selectedMode = .help }
                                                }
                    }
                    
                    
                    Spacer()
                    
                    // Tema-velger i bunnen
                                        Button(action: toggleTheme) {
                                            HStack {
                                                Image(systemName: "paintpalette.fill")
                                                Text("THEME: \(currentTheme.id.uppercased())")
                                                    .fontWeight(.bold)
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 20)
                                            // ENDRING: Bruk activeColor i stedet for textColor
                                            .foregroundColor(currentTheme.activeColor)
                                            // ENDRING: Tydeligere bakgrunn og ramme
                                            .background(
                                                ZStack {
                                                    currentTheme.background // Sikrer at knappen ikke er gjennomsiktig
                                                    currentTheme.activeColor.opacity(0.1) // Litt farge
                                                }
                                            )
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(currentTheme.activeColor, lineWidth: 1)
                                            )
                                            .shadow(color: currentTheme.activeColor.opacity(0.3), radius: 5)
                                        }
                                        .padding(.bottom, 30)
                }
            }
            .transition(.opacity)
        }
    }
    
    func toggleTheme() {
        if currentThemeIndex < AppTheme.allThemes.count - 1 {
            currentThemeIndex += 1
        } else {
            currentThemeIndex = 0
        }
    }
}

// --- FIX: ENDRET NAVN FRA CENTER TIL CENTERPOINT ---
extension CGRect {
    var centerPoint: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
