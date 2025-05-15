import SwiftUI

extension Color {
    static let systemBackground = Color(.systemGreen)
    static let secondarySystemBackground = Color(.systemGreen).opacity(0.9)
    static let tertiarySystemBackground = Color(.systemGreen).opacity(0.8)
}

extension View {
    func greenBackground() -> some View {
        self.background(Color.systemBackground)
    }
} 
