import Foundation

// Vi flytter Level-strukturen hit, så den er ryddig plassert
struct Level {
    let id: Int
    let title: String
    let text: String
}

import Foundation

struct StoryData {
    
    // --- HISTORIE 1: CYBER (Hacker / Sci-Fi) ---
    static let cyberLevels = [
        Level(id: 1, title: "System: BOOT", text: "init protocol zero"),
        Level(id: 2, title: "Firewall", text: "bryt gjennom muren"),
        Level(id: 3, title: "Access Granted", text: "last ned filene nå"),
        Level(id: 4, title: "System: EXIT", text: "sporløs utgang")
    ]
    
    // --- HISTORIE 2: CANDY (Neon / Arcade / Pop) ---
    static let candyLevels = [
        Level(id: 1, title: "Neon City", text: "rosa lys i tåken"),
        Level(id: 2, title: "Sukker-Rush", text: "løper fortere enn lyden"),
        Level(id: 3, title: "Glitch Mode", text: "himmelen smaker brus"),
        Level(id: 4, title: "High Score", text: "vi eier natten nå")
    ]
    
    // --- HISTORIE 3: MATRIX (Klassikeren) ---
    static let matrixLevels = [
        Level(id: 1, title: "The Wake", text: "våkn opp neo"),
        Level(id: 2, title: "White Rabbit", text: "følg den hvite kaninen"),
        Level(id: 3, title: "The Choice", text: "rød eller blå pille"),
        Level(id: 4, title: "The Code", text: "jeg kan kung fu nå")
    ]
    
    // --- HISTORIE 4: RAINBOW (Vær og skatter) ---
    static let rainbowLevels = [
        Level(id: 1, title: "Gråvær", text: "regnet faller tungt"),
        Level(id: 2, title: "Solgløtt", text: "lyset bryter frem"),
        Level(id: 3, title: "Prismet", text: "rød gul grønn blå"),
        Level(id: 4, title: "Skatten", text: "krukken med gull")
    ]
    
    // Hjelpefunksjon for å hente riktig historie
    static func getLevels(for themeId: String) -> [Level] {
        switch themeId {
        case "cyber": return cyberLevels
        case "candy": return candyLevels
        case "matrix": return matrixLevels
        case "rainbow": return rainbowLevels
        default: return cyberLevels
        }
    }
}
