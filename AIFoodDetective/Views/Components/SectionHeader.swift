import SwiftUI

struct SectionHeader: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundColor(.primary)
            Text(title)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
        }
    }
}