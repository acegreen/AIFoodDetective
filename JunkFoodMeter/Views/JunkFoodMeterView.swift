//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
// import Inject

struct JunkFoodMeterView: View {
    // @ObserveInjection var inject
    let product: Product

    // Placeholder: Replace with your actual scoring logic
    var junkScore: Double {
        // 0 = healthy, 1 = junk
        product.junkScore ?? 0.7
    }

    var needleRotation: Double {
        -90.0 + (180.0 * junkScore)
    }

    var junkLevel: String {
        switch junkScore {
        case 0.8...: return "Very High"
        case 0.6..<0.8: return "High"
        case 0.4..<0.6: return "Moderate"
        case 0.2..<0.4: return "Low"
        default: return "Very Low"
        }
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
                                    gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)

                        // Needle
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 4, height: 90)
                            .offset(y: -45)
                            .rotationEffect(.degrees(needleRotation))
                            .animation(.easeInOut, value: junkScore)

                        // Center circle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .shadow(radius: 2)

                        // Level indicator
                        Text(junkLevel.uppercased())
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .shadow(radius: 2)
                            .offset(y: 40)
                    }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
        // .enableInjection()
    }
}
