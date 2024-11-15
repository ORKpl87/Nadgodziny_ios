import SwiftUI

enum Theme {
    static let primaryColor = Color("AccentColor")
    static let secondaryColor = Color("SecondaryColor")
    static let backgroundColor = Color("BackgroundColor")
    static let surfaceColor = Color("SurfaceColor")
    static let textColor = Color("TextColor")
    
    static let gradientColors = [
        Color("GradientStart"),
        Color("GradientEnd")
    ]
    
    static let shadowColor = Color.black.opacity(0.1)
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 16
    
    struct Typography {
        static let title = Font.system(size: 28, weight: .bold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 15)
        static let caption = Font.system(size: 13)
    }
}

struct GlassmorphicBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Theme.surfaceColor.opacity(0.8))
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Theme.shadowColor, radius: 10, x: 0, y: 5)
    }
}

struct ModernCardStyle: ViewModifier {
    var hasGradient: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(Theme.padding)
            .background(
                Group {
                    if hasGradient {
                        LinearGradient(
                            colors: Theme.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Theme.surfaceColor
                    }
                }
            )
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Theme.shadowColor, radius: 8, x: 0, y: 4)
    }
}

extension View {
    func modernCard(hasGradient: Bool = false) -> some View {
        modifier(ModernCardStyle(hasGradient: hasGradient))
    }
    
    func glassmorphic() -> some View {
        modifier(GlassmorphicBackground())
    }
} 