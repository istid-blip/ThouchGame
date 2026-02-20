import SwiftUI
import UIKit

// MARK: - 1. Eksport-visningen (Bruk denne i App-filen din)
struct ExportView: View {
    @State private var generatedImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: 30) {
            Text("App Ikon Forhåndsvisning")
                .font(.headline)
            
            // Viser ikonet på skjermen
            FJIconView()
                .frame(width: 200, height: 200)
                .cornerRadius(40)
                .shadow(radius: 10)
            
            Text("Dette genererer et 1024x1024 PNG bilde klart for Xcode.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Eksportknappen
            Button(action: {
                // Her kaller vi den "gamle" metoden som fungerer overalt
                self.generatedImage = snapshot(view: FJIconView(), size: CGSize(width: 1024, height: 1024))
                self.showShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Eksporter Ikon")
                }
                // Endret for kompatibilitet:
                .font(.body.weight(.bold))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = generatedImage {
                ShareSheet(items: [image])
            }
        }
    }
}

// MARK: - 2. Funksjon for å gjøre SwiftUI om til Bilde (iOS 13+ kompatibel)
// Denne erstatter ImageRenderer
// Erstatt den gamle snapshot-funksjonen med denne:
func snapshot<T: View>(view: T, size: CGSize) -> UIImage {
    let controller = UIHostingController(rootView: view.frame(width: size.width, height: size.height))
    let view = controller.view
    
    let targetSize = size
    view?.bounds = CGRect(origin: .zero, size: targetSize)
    view?.backgroundColor = .clear
    
    // 1. Vi lager et format-objekt
    let format = UIGraphicsImageRendererFormat()
    
    // 2. VIKTIG: Vi tvinger skalaen til 1.0 (1 piksel = 1 punkt)
    // Dette hindrer at den blir 2048x2048 eller 3072x3072
    format.scale = 1
    
    // 3. Vi bruker formatet når vi lager rendereren
    let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
    
    return renderer.image { _ in
        view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
    }
}

// MARK: - 3. Hjelper for Delingsmenyen
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 4. Selve Ikonet (FJIconView)
struct FJIconView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.18, green: 0.18, blue: 0.27),
                    AppTheme.cyber.background                  // Cyber-temaets hovedbakgrunn (0.05, 0.05, 0.1) i bunn
                ]),
                startPoint: .topLeading,     // Starter oppe til venstre
                endPoint: .bottomTrailing    // Slutter nede til høyre
            )
            .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 30) {
                KeyboardKeyView(letter: "F", hasBump: true)
                KeyboardKeyView(letter: "J", hasBump: true)
            }
            .padding(40)
            .offset(y: -40)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - 5. Tastatur-knapp komponenten
struct KeyboardKeyView: View {
    let letter: String
    let hasBump: Bool
    
    // Henter farger fra cyber-temaet
    let keyTopColor = Color(red: 0.25, green: 0.26, blue: 0.32)
    let keyBottomColor = Color(red: 0.20, green: 0.21, blue: 0.27)
    let textColor = AppTheme.cyber.activeColor

    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cornerRadius = size * 0.2
            let fontSize = size * 0.5
            
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [keyTopColor, keyBottomColor]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                       
                            .stroke(Color.white.opacity(0.15), lineWidth: size * 0.02)
                            .padding(size * 0.01)
                            .mask(
                                LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: size * 0.05, x: 0, y: size * 0.08)
                
                Text(letter)
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor)
                    .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                
                if hasBump {
                    VStack {
                        Spacer()
                        Capsule()
                            .fill(textColor.opacity(0.6))
                            .frame(width: size * 0.3, height: size * 0.04)
                            .padding(.bottom, size * 0.15)
                    }
                }
            }
            // 1. Vi låser størrelsen på selve tasten til å være kvadratisk
            .frame(width: size, height: size)
                        
            // 2. Vi ber denne kvadratiske tasten om å midtstille seg i all tilgjengelig plass
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
