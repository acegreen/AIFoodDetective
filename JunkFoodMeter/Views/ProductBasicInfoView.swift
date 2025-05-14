//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct ProductBasicInfoView: View {
    let product: Product
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("Barcode", value: product._id)
                
                if let imageUrl = product.imageFrontUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .cornerRadius(8)
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Text(product.productName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let quantity = product.quantity {
                    LabeledContent("Quantity", value: quantity)
                }
                
                if let servingSize = product.servingSize {
                    LabeledContent("Serving Size", value: servingSize.formatServingSize())
                }
                
                if let origins = product.origins {
                    LabeledContent("Origin", value: origins)
                }
            }
        }
    }
    
    private func LabeledContent(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}
