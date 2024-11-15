import SwiftUI

struct IconGenerator: View {
    var body: some View {
        ZStack {
            // Tło
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.9),
                    Color(red: 0.4, green: 0.3, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Efekt szkła
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 600, height: 600)
                .blur(radius: 50)
                .offset(x: -100, y: -100)
            
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 400, height: 400)
                .blur(radius: 40)
                .offset(x: 150, y: 150)
            
            // Logo
            VStack(spacing: 0) {
                // Zegar
                Circle()
                    .stroke(.white, lineWidth: 40)
                    .frame(width: 400, height: 400)
                    .overlay(
                        ZStack {
                            // Wskazówka godzinowa
                            Rectangle()
                                .fill(.white)
                                .frame(width: 20, height: 120)
                                .offset(y: -30)
                                .rotationEffect(.degrees(45))
                            
                            // Wskazówka minutowa
                            Rectangle()
                                .fill(.white)
                                .frame(width: 20, height: 160)
                                .offset(y: -40)
                                .rotationEffect(.degrees(-60))
                        }
                    )
                    .overlay(
                        // Środek zegara
                        Circle()
                            .fill(.white)
                            .frame(width: 40, height: 40)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            }
        }
        .frame(width: 1024, height: 1024)
        .ignoresSafeArea()
    }
}

// Logo do użycia w aplikacji
struct AppLogo: View {
    var size: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Tło
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.5, blue: 0.9),
                            Color(red: 0.4, green: 0.3, blue: 0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Zegar
            Circle()
                .stroke(.white, lineWidth: size * 0.1)
                .frame(width: size * 0.8, height: size * 0.8)
                .overlay(
                    ZStack {
                        // Wskazówka godzinowa
                        Rectangle()
                            .fill(.white)
                            .frame(width: size * 0.05, height: size * 0.3)
                            .offset(y: -size * 0.075)
                            .rotationEffect(.degrees(45))
                        
                        // Wskazówka minutowa
                        Rectangle()
                            .fill(.white)
                            .frame(width: size * 0.05, height: size * 0.4)
                            .offset(y: -size * 0.1)
                            .rotationEffect(.degrees(-60))
                    }
                )
                .overlay(
                    // Środek zegara
                    Circle()
                        .fill(.white)
                        .frame(width: size * 0.1, height: size * 0.1)
                )
        }
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    VStack(spacing: 50) {
        // Podgląd ikony
        IconGenerator()
            .frame(width: 200, height: 200)
            .cornerRadius(40)
        
        // Podgląd logo w różnych rozmiarach
        HStack(spacing: 20) {
            AppLogo(size: 40)
            AppLogo(size: 60)
            AppLogo(size: 80)
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 