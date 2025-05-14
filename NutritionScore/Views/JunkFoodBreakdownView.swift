//
//  ContentView.swift
//  NutritionScore
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct JunkFoodBreakdownView: View {
    let product: Product

    // Placeholder: Replace with your actual breakdown logic
    var breakdown: [(label: String, value: Double, color: Color, icon: String)] {
        [
            ("Starch", 10, .yellow, "leaf"),
            ("Seed Oil", 3, .orange, "drop.fill"),
            ("Sugar", 11, .red, "cube.fill")
        ]
    }

    var total: Double {
        breakdown.map { $0.value }.reduce(0, +)
    }

    var body: some View {
        CardView {
            HStack(alignment: .center, spacing: 32) {
                // Larger Cup Container
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.8), Color.gray.opacity(0.18)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.gray.opacity(0.35), lineWidth: 4)
                        )
                        .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
                        .frame(width: 80, height: 160)
                    VStack(spacing: 0) {
                        ForEach(breakdown.indices.reversed(), id: \.self) { idx in
                            let item = breakdown[idx]
                            Rectangle()
                                .fill(item.color)
                                .frame(
                                    height: CGFloat(item.value / total) * 140,
                                    alignment: .bottom
                                )
                        }
                    }
                    .frame(width: 68, height: 140, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.vertical, 8)

                // Legend (left-aligned, closer to cup)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Total Macros: \(String(format: "%.1f", total)) g")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ForEach(breakdown, id: \.label) { item in
                        HStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                            Text("\(item.label): \(Int(item.value)) g")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}
