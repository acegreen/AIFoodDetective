//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
// import Inject

struct ContainedIngredientsView: View {
    // @ObserveInjection var inject
    let ingredients: [ProductIngredient]
    @State private var isExpanded: Bool = true
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "Contained Ingredients", systemImage: "list.bullet.clipboard.fill")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients listed by weight (first = most)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if ingredients.isEmpty {
                            Text("No ingredients information available")
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(ingredients.indices, id: \.self) { index in
                                let ingredient = ingredients[index]
                                HStack(spacing: 8) {
                                    if ingredient.isSuspicious {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Text(ingredient.text)
                                        .foregroundColor(ingredient.isSuspicious ? .orange : .primary)
                                    
                                    if let percent = ingredient.percentEstimate {
                                        Text("(\(Int(percent))%)")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        // .enableInjection()
    }
} 
