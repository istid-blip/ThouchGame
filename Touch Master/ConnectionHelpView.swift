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
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // --- INSTRUKSJONER ---
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Steg 1: Bluetooth med integrert knapp
                        InfoCard(
                            icon: "antenna.radiowaves.left.and.right",
                            title: "Bluetooth",
                            text: "1. Slå på tastaturet ditt.\n2. Sett det i 'Pairing Mode'.\n3. Gå til Innstillinger > Bluetooth.",
                            theme: theme
                        ) {
                            Link(destination: URL(string: "App-Prefs:root=Bluetooth")!) {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("ÅPNE BLUETOOTH")
                                }
                                .font(.subheadline.bold())
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .frame(maxWidth: .infinity)
                                .background(theme.activeColor)
                                .foregroundColor(theme.id == "cyber" || theme.id == "matrix" ? .black : .white)
                                .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        
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
            }
        }
    }
}

// Hjelpe-view for boksene med tekst, oppdatert for å støtte valgfritt innhold
struct InfoCard<Content: View>: View {
    let icon: String
    let title: String
    let text: String
    let theme: AppTheme
    let extraContent: Content
    
    // Tillater kort med og uten ekstra innhold (knapper)
    init(
        icon: String,
        title: String,
        text: String,
        theme: AppTheme,
        @ViewBuilder extraContent: () -> Content = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.text = text
        self.theme = theme
        self.extraContent = extraContent()
    }
    
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
                    .foregroundColor(isLightTheme ? .black.opacity(0.9) : .white.opacity(0.9))
                
                Text(text)
                    .font(.body)
                    .foregroundColor(isLightTheme ? .black.opacity(0.7) : .white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                
                // Viser knappen hvis den er lagt til
                extraContent
            }
            Spacer()
        }
        .padding()
        .background(
            isLightTheme
            ? Color.white.opacity(0.85)
            : Color.black.opacity(0.5)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.activeColor.opacity(0.5), lineWidth: 1)
        )
    }
}
