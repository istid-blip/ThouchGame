import SwiftUI

struct AppTheme {
    let id: String
    let background: Color
    let textColor: Color
    let activeColor: Color
    let completedColor: Color
    let fontDesign: Font.Design
    
    let kbdBackground: Color
    let kbdKeyFill: Color
    let kbdBorder: Color
}

// --- TEMA 1: CYBER ---
let cyberTheme = AppTheme(
    id: "cyber",
    background: Color(red: 0.05, green: 0.05, blue: 0.1),
    textColor: .white.opacity(0.1),
    activeColor: .cyan,
    completedColor: .gray.opacity(0.3),
    fontDesign: .monospaced,
    kbdBackground: Color.black.opacity(0.4),
    kbdKeyFill: Color.black.opacity(0.5),
    kbdBorder: .cyan
)

// --- TEMA 2: CANDY POP ---
let candyTheme = AppTheme(
    id: "candy",
    background: Color(red: 1.0, green: 0.95, blue: 0.98),
    textColor: .purple.opacity(0.2),
    activeColor: .pink,
    completedColor: .purple.opacity(0.4),
    fontDesign: .rounded,
    kbdBackground: Color.white.opacity(0.6),
    kbdKeyFill: Color.white,
    kbdBorder: .pink
)

// --- TEMA 3: MATRIX ---
let matrixTheme = AppTheme(
    id: "matrix",
    background: Color.black,
    textColor: Color(red: 0.0, green: 0.2, blue: 0.0),
    activeColor: Color(red: 0.0, green: 1.0, blue: 0.0),
    completedColor: Color(red: 0.0, green: 0.5, blue: 0.0),
    fontDesign: .monospaced,
    kbdBackground: Color.black,
    kbdKeyFill: Color(red: 0.0, green: 0.1, blue: 0.0),
    kbdBorder: .green
)

// --- TEMA 4: RAINBOW (OPPDATERT) ---
let rainbowTheme = AppTheme(
    id: "rainbow",
    background: Color.white, // Helt hvit bakgrunn for best kontrast
    textColor: .gray.opacity(0.2),
    activeColor: .blue, // Denne blir overstyrt av regnbue-logikken vår
    completedColor: .gray,
    fontDesign: .rounded,
    kbdBackground: .white.opacity(0.8),
    kbdKeyFill: .white,
    kbdBorder: .gray.opacity(0.3)
)

let allThemes = [cyberTheme, candyTheme, matrixTheme, rainbowTheme]
