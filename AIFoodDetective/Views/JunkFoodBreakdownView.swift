//
//  ContentView.swift
//  AIFoodDetective
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct JunkFoodBreakdownView: View {
    let product: Product

    var breakdown: [(label: String, value: Double, color: Color, icon: String)] {
        [
            ("Starch", product.nutriments?.starch ?? 0, .yellow, "leaf"),
            ("Seed Oils", product.nutriments?.seedOils ?? 0, .orange, "drop.fill"),
            ("Sugars", product.nutriments?.sugars ?? 0, .red, "cube.fill")
        ]
    }

    var total: Double {
        breakdown.map { $0.value }.reduce(0, +)
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "BREAKDOWN", systemImage: "fork.knife")

                VStack(alignment: .center, spacing: -32) {
                    JunkFoodMeterView(product: product)

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
                                            height: CGFloat(item.value / total) * 160,
                                            alignment: .bottom
                                        )
                                }
                            }
                            .frame(width: 100, height: 200, alignment: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }

                        // Legend (left-aligned, closer to cup)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Total: \(String(format: "%.1f", total)) g")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            ForEach(breakdown, id: \.label) { item in
                                HStack(spacing: 8) {
                                    Image(systemName: item.icon)
                                        .foregroundColor(item.color)
                                    Text("\(item.label): \(String(format: "%.1f", item.value)) g")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
