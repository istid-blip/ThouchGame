import SwiftUI

struct ConnectionHelpView: View {
    var theme: AppTheme
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            // Bakgrunn
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // --- TOPP MENY ---
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("BACK")
                        }
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.activeColor)
                    }
                    Spacer()
                }
                .padding()
                
                // --- TITTEL ---
                VStack(spacing: 10) {
                    Image(systemName: "keyboard.badge.ellipsis")
                        .font(.system(size: 60))
                        .foregroundColor(theme.activeColor)
                        .padding(.bottom, 10)
                    
                    Text("KOBLE TASTATUR")
                        .font(.system(size: 30, weight: .heavy, design: theme.fontDesign))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                }
                
                // --- INSTRUKSJONER ---
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Steg 1: Bluetooth
                        InfoCard(
                            icon: "antenna.radiowaves.left.and.right",
                            title: "Bluetooth",
                            text: "1. Slå på tastaturet ditt.\n2. Sett det i 'Pairing Mode'.\n3. Gå til Innstillinger > Bluetooth.",
                            theme: theme
                        )
                        
                        // Steg 2: Kabel
                        InfoCard(
                            icon: "cable.connector",
                            title: "Kabel / USB-C",
                            text: "Koble USB-C kabelen rett i iPaden. Hvis du har gammel USB, bruk en adapter.",
                            theme: theme
                        )
                        
                        // Steg 3: Smart Connector
                        InfoCard(
                            icon: "ipad.and.iphone",
                            title: "Smart Case",
                            text: "Bare klikk iPaden på plass i Magic Keyboard eller Smart Folio.",
                            theme: theme
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // --- KNAPP TIL INNSTILLINGER ---
                Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                    HStack {
                        Image(systemName: "gear")
                        Text("ÅPNE INNSTILLINGER")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.activeColor)
                    // Sikrer at teksten på knappen alltid er lesbar mot den aktive fargen
                    .foregroundColor(theme.id == "cyber" || theme.id == "matrix" ? .black : .white)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
    }
}

// Hjelpe-view for boksene med tekst
struct InfoCard: View {
    let icon: String
    let title: String
    let text: String
    let theme: AppTheme
    
    // Sjekk om temaet er lyst eller mørkt
    var isLightTheme: Bool {
        ["candy", "rainbow"].contains(theme.id)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(theme.activeColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title.uppercased())
                    .font(.headline)
                    // FIX: Tvinger sort tekst på lyse temaer, hvit på mørke
                    .foregroundColor(isLightTheme ? .black.opacity(0.9) : .white.opacity(0.9))
                
                Text(text)
                    .font(.body)
                    // FIX: Samme her, sikrer høy kontrast
                    .foregroundColor(isLightTheme ? .black.opacity(0.7) : .white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding()
        // FIX: Bakgrunnen til boksen tilpasser seg nå for å gi kontrast
        .background(
            isLightTheme
            ? Color.white.opacity(0.85) // Lyst tema = nesten hvit boks
            : Color.black.opacity(0.5)  // Mørkt tema = mørk boks
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.activeColor.opacity(0.5), lineWidth: 1)
        )
    }
}
