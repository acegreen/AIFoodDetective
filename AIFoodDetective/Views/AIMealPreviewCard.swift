import SwiftUI
import Observation
import UIKit


struct AIMealPreviewCard: View {
    @Binding var isPresented: Bool
    @State private var showingListPicker = false
    @State private var currentDetent: PresentationDetent = .medium
    let product: Product

    var imageHeight: CGFloat {
        switch currentDetent {
        case .medium:
            return 100
        case .large:
            return 200
        default:
            return 120
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Product Image
            if let imageData = product.imageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: imageHeight)
                    .cornerRadius(8)
            } else if let imageUrl = product.imageFrontURL {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: imageHeight)
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: imageHeight)
                        .cornerRadius(8)
                        .overlay(
                            ProgressView()
                        )
                }
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
        .presentationDetents([.medium, .large], selection: $currentDetent)
    }
}

#Preview {
    AIMealPreviewCard(
        isPresented: .constant(true),
        product: Product.placeholder
    )
}

