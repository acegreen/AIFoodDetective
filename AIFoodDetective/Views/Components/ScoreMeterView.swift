import SwiftUI

struct ScoreMeterView: View {
    let score: Double

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 25)

            // Score circle
            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(
                    scoreColor,
                    style: StrokeStyle(
                        lineWidth: 25,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            // Score text
            VStack(spacing: 4) {
                Text("\(Int(score))")
                    .font(.system(size: 56, weight: .bold))
                Text("out of 100")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    var scoreColor: Color {
        switch score {
        case 0..<40: return .red
        case 40..<70: return .orange
        default: return .green
        }
    }
}