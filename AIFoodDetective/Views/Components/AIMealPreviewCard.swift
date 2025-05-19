import SwiftUI
import Observation
import UIKit


struct AIMealPreviewCard: View {
    @Binding var isPresented: Bool
    @State private var showingListPicker = false
    let product: Product

    var body: some View {
        VStack(spacing: 24) {
            // Product Image
            if let imageData = product.imageData,
                let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 120)
                    .cornerRadius(8)
                    .overlay(
                        ProgressView()
                    )
            }

            if let aiAnalysis = product.aiAnalysis {
                // Analysis Result
                ScrollView {
                    Text(aiAnalysis)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                }
            }

            Spacer()

            // Add to List Button
            HStack(spacing: 12) {
                Button {
                    showingListPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to List")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .foregroundColor(.green)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .greenBackground()
        .sheet(isPresented: $showingListPicker) {
            AddToListView(isPresented: $showingListPicker, product: product)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    AIMealPreviewCard(
        isPresented: .constant(true),
        product: Product.placeholder
    )
}

