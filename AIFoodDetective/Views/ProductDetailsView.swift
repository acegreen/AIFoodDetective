//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct ProductDetailsView: View {
    @Environment(MessageHandler.self) var messageHandler
    let product: Product
    @State private var showingListPicker = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Product Info Section
                ProductCellView(product: product, compact: false)

                // Junk Food Breakdown Section
                JunkFoodBreakdownView(product: product)
                
                // Contained Ingredients Section
                ContainedIngredientsView(ingredients: product.ingredients ?? [])

                AIAnalysisView(aiResult: product.aiAnalysis ?? "")
            }
            .padding()
        }
        .background(Color.systemBackground)
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
        .whiteNavigationTitle()
        .sheet(isPresented: $showingListPicker) {
            AddToListView(isPresented: $showingListPicker, product: product)
        }
        .navigationBarItems(trailing: plusButton)
    }

    private var plusButton: some View {
        Button {
            showingListPicker = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "sampleProduct", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
    return ProductDetailsView(product: welcome.product)
}
