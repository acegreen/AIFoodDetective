//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct ProductDetailsView: View {
    @Environment(ProductListManager.self) var productListManager
    @Environment(MessageHandler.self) var messageHandler
    let product: Product
    @State private var showingListPicker = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Product Info Section
                ProductBasicInfoView(product: product)
                
                // Junk Food Breakdown Section
                JunkFoodBreakdownView(product: product)
                
                // Contained Ingredients Section
                ContainedIngredientsView(ingredients: product.ingredients ?? [])
            }
            .padding()
        }
        .background(Color.systemBackground)
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
        .whiteNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingListPicker = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingListPicker) {
            ListPickerView(isPresented: $showingListPicker, product: product)
        }
        .toast()
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "sampleProduct", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
    return ProductDetailsView(product: welcome.product)
}
