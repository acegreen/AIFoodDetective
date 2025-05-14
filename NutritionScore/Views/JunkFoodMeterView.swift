//
//  ContentView.swift
//  NutritionScore
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct JunkFoodMeterView: View {
    let product: Product

    // Placeholder: Replace with your actual scoring logic
    var junkScore: Double {
        // 0 = healthy, 1 = junk
        product.junkScore ?? 0.7
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

    var junkColor: Color {
        switch junkScore {
        case 0.8...: return .red
        case 0.6..<0.8: return .orange
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .green
        default: return .mint
        }
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Junk Food Meter", systemImage: "chart.bar.fill")
                VStack(alignment: .center, spacing: 12) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 28)
                        Capsule()
                            .fill(junkColor)
                            .frame(width: CGFloat(junkScore) * 260, height: 28)
                            .animation(.easeInOut, value: junkScore)
                        HStack {
                            Spacer()
                            Text(junkLevel)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(junkColor)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                            Spacer()
                        }
                    }
                    .frame(height: 28)
                    .padding(.vertical, 8)
                    Text("Junk Score: \(Int(junkScore * 100)) / 100")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
} 
