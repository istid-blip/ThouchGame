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
