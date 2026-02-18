import SwiftUI

struct ContentView: View {
    @State private var currentThemeIndex = 0
    @State private var selectedMode: GameMode? = nil
    
    var currentTheme: AppTheme {
        return AppTheme.allThemes[currentThemeIndex]
    }
    
    var body: some View {
        if let mode = selectedMode {
            switch mode {
            case .training, .story:
                            // HER ER ENDRINGEN:
                            // Både story og training bruker nå samme UnifiedGameView.
                            // Vi sender med 'mode' variablen så visningen vet hva den skal vise.
                            UnifiedGameView(
                                mode: mode,
                                theme: currentTheme,
                                onBack: { selectedMode = nil }
                            )
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
                        Text("VELG MODE")
                            .font(.headline)
                            .tracking(4)
                            .foregroundColor(currentTheme.textColor.opacity(0.7))
                    }
                    .padding(.top, 50)
                    
                    VStack(spacing: 20) {
                        MenuButton(title: "TRENING", icon: "keyboard", theme: currentTheme) {
                            withAnimation { selectedMode = .training }
                        }
                        MenuButton(title: "STORY MODE", icon: "book.closed.fill", theme: currentTheme) {
                            withAnimation { selectedMode = .story }
                        }
                        MenuButton(title: "KOBLE TIL TASTATUR", icon: "cable.connector", theme: currentTheme) {
                            withAnimation { selectedMode = .help }
                        }
                    }
                    
                    Spacer()
                    
                    // Tema-velger i bunnen
                    Button(action: toggleTheme) {
                        HStack {
                            Image(systemName: "paintpalette.fill")
                            Text("TEMA: \(currentTheme.id.uppercased())")
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .foregroundColor(currentTheme.activeColor)
                        .background(
                            ZStack {
                                currentTheme.background
                                currentTheme.activeColor.opacity(0.1)
                            }
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(currentTheme.activeColor, lineWidth: 1)
                        )
                        .shadow(color: currentTheme.activeColor.opacity(0.3), radius: 5)
                    }
                    .padding(.bottom, 10)
                    
                    Text("© 2026 Frode Halrynjo")
                                            .font(.caption) // Liten skrift
                                            .foregroundColor(currentTheme.textColor.opacity(0.7)) // Diskret farge
                                            .padding(.bottom, 20) // Litt luft i bunnen av skjermen
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
