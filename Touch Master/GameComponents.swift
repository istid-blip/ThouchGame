//
//  GameComponents.swift
//  TouchGame
//
//  Created by Frode Halrynjo on 18/02/2026.
//
import SwiftUI

// --- UI COMPONENTS ---

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
    let wpm: Int
    let accuracy: Int
    
    // NYE PARAMETERE FOR BONUS
    let bonusWPM: Int
    let bonusAccuracy: Int
    
    let onReset: () -> Void
    let onNext: () -> Void
    
    var isLightTheme: Bool {
        ["candy", "rainbow"].contains(theme.id)
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // --- HEADER ---
            HStack(spacing: 15) {
                Image(systemName: "star.fill")
                Text("NIVÅ FULLFØRT!")
                    .font(.system(size: 26, weight: .heavy, design: theme.fontDesign))
                Image(systemName: "star.fill")
            }
            .foregroundColor(theme.activeColor)
            .padding(.top, 10)
            
            // --- STATISTIKK OG BONUS KORT ---
            HStack(spacing: 20) {
                // OPM Kort
                StatCard(
                    title: "OPM",
                    value: "\(wpm)",
                    bonus: bonusWPM,
                    theme: theme
                )
                
                // Nøyaktighet Kort
                StatCard(
                    title: "NØYAKTIGHET",
                    value: "\(accuracy)%",
                    bonus: bonusAccuracy,
                    theme: theme,
                    isValueGood: accuracy >= 90
                )
            }
            
            // --- TOTAL BONUS OPPSUMMERING ---
            let totalBonus = bonusWPM + bonusAccuracy
            if totalBonus > 0 {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title2)
                    Text("+\(totalBonus) BONUS MYNTER")
                        .font(.headline.bold())
                }
                .foregroundColor(.yellow)
                .padding(.vertical, 5)
            }
            
            // --- KNAPPER ---
            HStack(spacing: 15) {
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2.bold())
                        .frame(width: 60, height: 60)
                        .background(theme.kbdKeyFill)
                        .foregroundColor(theme.textColor)
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(theme.kbdBorder.opacity(0.5), lineWidth: 1))
                }
                
                Button(action: onNext) {
                    HStack {
                        Text("NESTE NIVÅ")
                            .font(.headline.bold())
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(theme.activeColor)
                    .foregroundColor(["cyber", "matrix"].contains(theme.id) ? .black : .white)
                    .cornerRadius(15)
                    .shadow(color: theme.activeColor.opacity(0.5), radius: 5, x: 0, y: 3)
                }
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(isLightTheme ? Color.white.opacity(0.95) : Color.black.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(theme.activeColor.opacity(0.6), lineWidth: 2)
        )
        .shadow(color: theme.activeColor.opacity(0.2), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 40)
    }
}

// Nytt sub-view for å gjøre tallene ryddigere
struct StatCard: View {
    let title: String
    let value: String
    let bonus: Int
    let theme: AppTheme
    var isValueGood: Bool = true
    
    var isLightTheme: Bool {
        ["candy", "rainbow"].contains(theme.id)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: theme.fontDesign))
                .foregroundColor(theme.textColor.opacity(0.8))
            
            Text(value)
                .font(.system(size: 38, weight: .heavy, design: .monospaced))
                .foregroundColor(isValueGood ? theme.activeColor : .orange)
            
            // Viser hvor mange mynter man fikk for denne staten
            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.caption)
                Text("\(bonus)")
                    .font(.subheadline.bold())
            }
            .foregroundColor(bonus > 0 ? .yellow : .gray.opacity(0.5))
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(theme.kbdKeyFill.opacity(isLightTheme ? 0.5 : 0.8))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(theme.kbdBorder.opacity(0.3), lineWidth: 1)
        )
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
        else { return theme.fadedColor }
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

// Hjelpe-extension for å finne midtpunkt
extension CGRect {
    var centerPoint: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
