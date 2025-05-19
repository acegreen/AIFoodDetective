//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
//import Inject

struct JunkFoodMeterView: View {
    //    @ObserveInjection var inject
    let product: Product

    private let junkScoreColors: [Color] = [.green, .yellow, .orange, .red]
    private let junkScoreRanges: [ClosedRange<Double>] = [0...0.25, 0.25...0.5, 0.5...0.75, 0.75...1.0]

    var needleRotation: Double {
        -90.0 + (180.0 * Double(product.junkScore / 10))
    }

    var scoreValue: String {
        String(format: "%.0f", round(product.junkScore))
    }

    private func colorForScore(_ score: Double) -> Color {
        for (index, range) in junkScoreRanges.enumerated() {
            if range.contains(score) {
                return junkScoreColors[index]
            }
        }
        return .red // Fallback color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Gauge View
            ZStack {
                // Background semi-circle
                Circle()
                    .trim(from: 0.5, to: 1.0)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: junkScoreColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)

                // Needle
                Rectangle()
                    .fill(colorForScore(product.junkScore))
                    .frame(width: 4, height: 90)
                    .offset(y: -45)
                    .rotationEffect(.degrees(needleRotation))
                    .animation(.easeInOut, value: product.junkScore)

                // Center circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)

                // Level indicator
                Text(scoreValue)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .shadow(radius: 2)
                    .offset(y: 40)

                Text("Junk Score")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .offset(y: 60)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        //        .enableInjection()
    }
}
