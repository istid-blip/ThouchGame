import SwiftUI

struct ThemedKeyboard: View {
    var targetChar: String
    var isInteractive: Bool
    var theme: AppTheme
    var activeColor: Color // <--- NY: Vi får fargen fra ContentView
    var onKeyPress: (String) -> Void
    
    let rows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Å"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ø", "Æ"],
        ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "ENTER"],
        ["SPACE"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { key in
                        
                        let isActive = isKeyActive(key)
                        
                        ThemedKeyButton(
                            label: key,
                            actualChar: getActualChar(for: key),
                            isActive: isActive,
                            isInteractive: isInteractive,
                            theme: theme,
                            widthMultiplier: getWidth(for: key),
                            // HER ER MAGIEN: Vi bruker den oversendte fargen
                            activeColorOverride: isActive ? activeColor : nil,
                            action: {
                                if isInteractive {
                                    onKeyPress(getActualChar(for: key))
                                }
                            }
                        )
                    }
                }
                .padding(.leading, (row.first == "A") ? 20 : 0)
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.kbdBackground.opacity(isInteractive ? 1.0 : 0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            // Bruk aktiv farge på rammen også hvis interaktiv
                            isInteractive ? (theme.id == "rainbow" ? activeColor.opacity(0.5) : theme.kbdBorder.opacity(0.5)) : Color.gray.opacity(0.3),
                            lineWidth: isInteractive ? 3 : 2
                        )
                )
                .shadow(color: isInteractive ? (theme.id == "rainbow" ? activeColor.opacity(0.3) : theme.kbdBorder.opacity(0.3)) : .clear, radius: 15)
        )
    }
    
    // ... (Hjelpefunksjoner er uendret) ...
    func getActualChar(for key: String) -> String {
        switch key {
        case "SPACE": return " "
        case "ENTER": return "\n"
        case "SHIFT": return ""
        default: return key
        }
    }
    
    func getWidth(for key: String) -> CGFloat {
        switch key {
        case "SPACE": return 6.0
        case "ENTER": return 2.0
        case "SHIFT": return 2.0
        default: return 1.0
        }
    }
    
    func isKeyActive(_ key: String) -> Bool {
        let char = getActualChar(for: key)
        if targetChar == " " && key == "SPACE" { return true }
        if targetChar == "\n" && key == "ENTER" { return true }
        return char.uppercased() == targetChar.uppercased()
    }
}

struct ThemedKeyButton: View {
    var label: String
    var actualChar: String
    var isActive: Bool
    var isInteractive: Bool
    var theme: AppTheme
    var widthMultiplier: CGFloat
    var activeColorOverride: Color? // <--- Tar imot fargen her
    var action: () -> Void
    
    var body: some View {
        // Bruk overstyrt farge hvis vi har den, ellers tema-farge
        let finalColor = activeColorOverride ?? theme.activeColor
        
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? finalColor.opacity(0.3) : theme.kbdKeyFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isActive ? finalColor : theme.kbdBorder.opacity(0.3), lineWidth: isActive ? 3 : 1)
                    )
                    .shadow(color: isActive ? finalColor.opacity(0.6) : .clear, radius: 8)
                
                Group {
                    if label == "SHIFT" {
                        Image(systemName: "arrow.up")
                    } else if label == "ENTER" {
                        Image(systemName: "return")
                    } else if label == "SPACE" {
                        Rectangle().fill(theme.textColor.opacity(0.2)).frame(height: 2).frame(width: 50)
                    } else {
                        Text(label)
                    }
                }
                .font(.system(size: 18, weight: .bold, design: theme.fontDesign))
                .foregroundColor(isActive ? (theme.id == "cyber" || theme.id == "matrix" ? .white : finalColor) : .gray)
            }
            .frame(width: 44 * widthMultiplier + (6 * (widthMultiplier - 1)), height: 50)
        }
        .disabled(!isInteractive)
    }
}
