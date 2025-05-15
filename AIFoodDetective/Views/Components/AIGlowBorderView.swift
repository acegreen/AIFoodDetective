import SwiftUI

struct AIGlowBorder: ViewModifier {
    @State private var animate = false

    func body(content: Content) -> some View {
        ZStack {
            content
            RoundedRectangle(cornerRadius: 48)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .purple, .blue, .cyan, .green, .yellow, .orange, .red, .purple
                        ]),
                        center: .center,
                        angle: .degrees(animate ? 360 : 0)
                    ),
                    lineWidth: 12
                )
                .blur(radius: 8)
                .ignoresSafeArea(edges: [.top, .leading, .trailing])
                .allowsHitTesting(false)
                .animation(
                    .linear(duration: 3).repeatForever(autoreverses: false),
                    value: animate
                )
        }
        .onAppear { animate = true }
    }
}

extension View {
    @ViewBuilder
    func aiGlowBorder(enabled: Bool) -> some View {
        if enabled {
            self.modifier(AIGlowBorder())
        } else {
            self
        }
    }
}

// Helper for conditional modifier
struct IdentityModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}

