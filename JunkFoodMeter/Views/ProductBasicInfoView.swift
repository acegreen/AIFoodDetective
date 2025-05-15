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
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(product.productName)
                        .font(.title2)
                        .fontWeight(.bold)

                    LabeledContent("Barcode", value: product._id)

                    if let quantity = product.quantity {
                        LabeledContent("Quantity", value: quantity)
                    }

                    if let servingSize = product.servingSize {
                        LabeledContent("Serving Size", value: servingSize.formatServingSize())
                    }

                    if let origins = product.origins {
                        LabeledContent("Origin", value: origins)
                    }

                    Spacer()
                }

                if let imageUrl = product.imageFrontUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .cornerRadius(8)
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
