//
//  ContentView.swift
//  AIFoodDetective
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
// import Inject

enum JunkBreakdownType: String, CaseIterable {
    case starch = "Starch"
    case seedOil = "Seed Oil"
    case sugar = "Added Sugar"

    var icon: String {
        switch self {
        case .starch: return "leaf"
        case .seedOil: return "drop.fill"
        case .sugar: return "cube.fill"
        }
    }

    var defaultColor: Color {
        switch self {
        case .starch: return .yellow
        case .seedOil: return .orange
        case .sugar: return .gray.opacity(0.25)
        }
    }
}

struct JunkFoodBreakdownView: View {
    //    @ObserveInjection var inject
    let product: Product

    var breakdown: [TaperedCupView.CupLayer] {
        [
            .init(type: .starch, color: JunkBreakdownType.starch.defaultColor, value: product.nutriments?.starch ?? 0),
            .init(type: .seedOil, color: JunkBreakdownType.seedOil.defaultColor, value: product.nutriments?.seedOils ?? 0),
            .init(type: .sugar, color: JunkBreakdownType.sugar.defaultColor, value: product.nutriments?.addedSugars ?? 0)
        ]
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Junk Breakdown", systemImage: "fork.knife")

                VStack(alignment: .center, spacing: -8) {
                    JunkFoodMeterView(product: product)

                    HStack(alignment: .center, spacing: 16) {
                        TaperedCupView(
                            layers: breakdown,
                            total: product.nutriments?.total ?? 0,
                            cupWidth: 140,
                            cupHeight: 140
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Macros: \(String(format: "%.1f", product.nutriments?.total ?? 0)) g")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.primary)
                                Text("(Carbs, Protein & Fats)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            ForEach(breakdown, id: \.label) { item in
                                HStack(alignment: .center, spacing: 8) {
                                    Image(systemName: item.icon)
                                        .foregroundColor(item.color)
                                        .frame(width: 24, alignment: .center)
                                    Text("\(item.label):")
                                        .font(.subheadline)
                                        .bold()
                                        .frame(width: 70, alignment: .leading)
                                    Text("\(String(format: "%.1f", item.value)) g")
                                        .font(.subheadline)
                                        .frame(alignment: .trailing)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
        }
    }
}
