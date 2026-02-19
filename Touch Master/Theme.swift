import SwiftUI

struct AppTheme: Identifiable {
    let id: String
    let background: Color
    let fadedColor: Color
    let textColor: Color
    let activeColor: Color
    let completedColor: Color
    let fontDesign: Font.Design
    
    let kbdBackground: Color
    let kbdKeyFill: Color
    let kbdBorder: Color
    
    // --- STATISKE TEMAER (Flyttet inn her) ---
    
    static let cyber = AppTheme(
        id: "cyber",
        background: Color(red: 0.05, green: 0.05, blue: 0.1),
        fadedColor: .white.opacity(0.1),
        textColor: .white.opacity(0.5),
        activeColor: .cyan,
        completedColor: .gray.opacity(0.3),
        fontDesign: .monospaced,
        kbdBackground: Color.black.opacity(0.4),
        kbdKeyFill: Color.black.opacity(0.5),
        kbdBorder: .cyan
    )
    
    static let candy = AppTheme(
        id: "candy",
        background: Color(red: 1.0, green: 0.95, blue: 0.98),
        fadedColor: .purple.opacity(0.2),
        textColor: .purple.opacity(0.5),
        activeColor: .pink,
        completedColor: .purple.opacity(0.4),
        fontDesign: .rounded,
        kbdBackground: Color.white.opacity(0.6),
        kbdKeyFill: Color.white,
        kbdBorder: .pink
    )
    
    static let matrix = AppTheme(
        id: "matrix",
        background: Color.black,
        fadedColor: Color(red: 0.0, green: 0.2, blue: 0.0),
        textColor: Color(red: 0.4, green: 0.6, blue: 0.4),
        activeColor: Color(red: 0.0, green: 1.0, blue: 0.0),
        completedColor: Color(red: 0.0, green: 0.5, blue: 0.0),
        fontDesign: .monospaced,
        kbdBackground: Color.black,
        kbdKeyFill: Color(red: 0.0, green: 0.1, blue: 0.0),
        kbdBorder: .green
    )
    
    static let rainbow = AppTheme(
        id: "rainbow",
        background: Color.white,
        fadedColor: .gray.opacity(0.2),
        textColor: .gray.opacity(0.5),
        activeColor: .blue,
        completedColor: .gray,
        fontDesign: .rounded,
        kbdBackground: .white.opacity(0.8),
        kbdKeyFill: .white,
        kbdBorder: .gray.opacity(0.3)
    )
    
    // Listen som ContentView ser etter:
    static let allThemes = [cyber, candy, matrix, rainbow]
}
