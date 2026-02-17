import SwiftUI
import Combine
import UIKit

// --- 1. DATASTRUKTUR FOR LEVELS ---
struct Level {
    let id: Int
    let title: String
    let text: String
}

// --- 2. SPILLMOTOREN ---
class TypingGameEngine: ObservableObject {
    // Her er kurset ditt! Du kan legge til så mange du vil her.
    let levels = [
        Level(id: 1, title: "Pekefingre", text: "f j f j j f j f"),
        Level(id: 2, title: "Langfingre", text: "d k d k k d k d"),
        Level(id: 3, title: "Ringfingre", text: "s l s l l s l s"),
        Level(id: 4, title: "Lillefingre", text: "a ø a ø ø a ø a"),
        Level(id: 5, title: "Hjem-raden", text: "asdf jklø"),
        Level(id: 6, title: "Små ord", text: "sjø dal laks flak"),
        Level(id: 7, title: "Setninger", text: "alle skal ha laks"),
        Level(id: 8, title: "Sjefs-testen", text: "kul kode på ipad")
    ]
    
    @Published var currentLevelIndex = 0
    @Published var currentIndex = 0
    @Published var isCompleted = false
    @Published var shakeTrigger = false
    
    // Henter ut nåværende level basert på index
    var currentLevel: Level {
        return levels[currentLevelIndex]
    }
    
    // Teksten vi skal skrive nå
    var targetText: String {
        return currentLevel.text
    }
    
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
    
    // Gå til neste level
    func nextLevel() {
        if currentLevelIndex < levels.count - 1 {
            currentLevelIndex += 1
        } else {
            // Hvis vi er ferdig med alle, start forfra (eller lag en victory screen senere)
            currentLevelIndex = 0
        }
        reset()
    }
    
    func reset() {
        currentIndex = 0
        isCompleted = false
    }
}

// --- 3. USYNLIG INPUT-FELT ---
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

// --- 4. HOVEDVISNING ---
struct ContentView: View {
    @StateObject private var engine = TypingGameEngine()
    @State private var enableTouchKeyboard = false
    @State private var currentTheme: AppTheme = cyberTheme
    
    let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                currentTheme.background.ignoresSafeArea()
                KeyboardInputView { key in engine.checkInput(key) }
                    .frame(width: 0, height: 0)
                
                VStack(spacing: isPhone ? 5 : 20) {
                    
                    // --- MENY ---
                    HStack {
                        Text(currentTheme.id.uppercased())
                            .font(.system(size: isPhone ? 14 : 20, weight: .bold, design: currentTheme.fontDesign))
                            .foregroundColor(currentTheme.activeColor)
                        Spacer()
                        Button(action: toggleTheme) {
                            Image(systemName: "paintpalette.fill")
                                .font(isPhone ? .body : .title2)
                                .foregroundColor(currentTheme.activeColor)
                                .padding(8)
                                .background(currentTheme.kbdKeyFill.opacity(0.8))
                                .cornerRadius(8)
                        }
                        Toggle("TOUCH", isOn: $enableTouchKeyboard)
                            .toggleStyle(ThemedToggleStyle(theme: currentTheme))
                            .scaleEffect(isPhone ? 0.8 : 1.0)
                            .fixedSize()
                    }
                    .padding(.horizontal)
                    .padding(.top, isPhone ? 5 : 20)
                    
                    Spacer()
                    
                    // --- LEVEL INFO ---
                    VStack(spacing: 5) {
                        Text("LEVEL \(engine.currentLevel.id)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(currentTheme.textColor)
                            .opacity(0.8)
                        
                        Text(engine.currentLevel.title.uppercased())
                            .font(.system(size: isPhone ? 20 : 30, weight: .heavy, design: currentTheme.fontDesign))
                            .foregroundColor(currentTheme.activeColor)
                            .shadow(color: currentTheme.activeColor.opacity(0.3), radius: 10)
                    }
                    
                    Spacer()
                    
                    // --- SPILLOMRÅDE (TEKST) ---
                    ZStack {
                        HStack(spacing: 0) {
                            ForEach(Array(engine.targetText.enumerated()), id: \.offset) { index, char in
                                
                                let isActive = (index == engine.currentIndex)
                                let fontSize = min(geometry.size.width / 13, isPhone ? 45 : 70)
                                let charColor = getColor(at: index)
                                
                                Text(String(char))
                                    .font(.system(size: fontSize, weight: .bold, design: currentTheme.fontDesign))
                                    .foregroundColor(charColor)
                                    .overlay(alignment: .bottom) {
                                        if char == " " {
                                            Rectangle()
                                                .fill(charColor)
                                                .frame(height: isPhone ? 3 : 5)
                                                .offset(y: isPhone ? 5 : 10)
                                        }
                                    }
                                    .shadow(color: getGlow(at: index), radius: isActive ? 15 : 0)
                                    .zIndex(isActive ? 1 : 0)
                            }
                        }
                    }
                    .modifier(ShakeEffect(animatableData: engine.shakeTrigger ? 1 : 0))
                    
                    // --- LEVEL COMPLETE ---
                    if engine.isCompleted {
                         VStack {
                            Text("LEVEL COMPLETE")
                                .font(.title)
                                .foregroundColor(currentTheme.activeColor)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(currentTheme.activeColor, lineWidth: 2))
                            
                            HStack(spacing: 20) {
                                // Restart (Liten knapp)
                                Button(action: { engine.reset() }) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .padding()
                                        .background(currentTheme.kbdKeyFill.opacity(0.5))
                                        .cornerRadius(8)
                                        .foregroundColor(currentTheme.textColor)
                                }
                                
                                // Neste Level (Stor knapp)
                                Button("NEXT LEVEL") { engine.nextLevel() }
                                    .font(.headline)
                                    .padding()
                                    .background(currentTheme.activeColor)
                                    .foregroundColor(currentTheme.id == "cyber" || currentTheme.id == "matrix" ? .black : .white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 20)
                        }
                    }

                    Spacer()
                    
                    // --- TASTATUR ---
                    if !engine.isCompleted {
                        let currentKeyColor = getColor(at: engine.currentIndex)
                        
                        ThemedKeyboard(
                            targetChar: engine.currentTargetChar,
                            isInteractive: enableTouchKeyboard,
                            theme: currentTheme,
                            activeColor: currentKeyColor,
                            onKeyPress: { key in engine.checkInput(key) }
                        )
                        .scaleEffect(fitScale(size: geometry.size))
                        .frame(width: geometry.size.width)
                        .padding(.bottom, (isPhone && geometry.size.width > geometry.size.height) ? 5 : 10)
                    }
                }
            }
        }
    }
    
    // --- HJELPEFUNKSJONER ---
    
    func getRainbowColor(at index: Int) -> Color {
        let hue = Double(index % 20) / 20.0
        return Color(hue: hue, saturation: 0.8, brightness: 1.0)
    }

    func getColor(at index: Int) -> Color {
        if index < engine.currentIndex {
            return currentTheme.completedColor
        } else if index == engine.currentIndex {
            if currentTheme.id == "rainbow" {
                return getRainbowColor(at: index)
            }
            return currentTheme.activeColor
        } else {
            return currentTheme.textColor
        }
    }
    
    func getGlow(at index: Int) -> Color {
        if index == engine.currentIndex {
            return getColor(at: index)
        }
        return .clear
    }
    
    func fitScale(size: CGSize) -> CGFloat {
        let keyboardBaseWidth: CGFloat = 850.0
        let keyboardBaseHeight: CGFloat = 300.0
        let widthScale = size.width / keyboardBaseWidth
        let maxVerticalSpace = isPhone ? 0.55 : 0.8
        let heightScale = (size.height * maxVerticalSpace) / keyboardBaseHeight
        return min(widthScale, heightScale)
    }
    
    func toggleTheme() {
        withAnimation {
            if let currentIndex = allThemes.firstIndex(where: { $0.id == currentTheme.id }) {
                let nextIndex = (currentIndex + 1) % allThemes.count
                currentTheme = allThemes[nextIndex]
            }
        }
    }
}

// --- TOGGLE & SHAKE ---
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(configuration.isOn ? theme.activeColor.opacity(0.6) : .gray.opacity(0.3), lineWidth: 2)
                    )
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
