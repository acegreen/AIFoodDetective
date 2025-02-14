import SwiftUI
import Observation

struct ProductPreviewCard: View {
    @Binding var isPresented: Bool
    let product: Product
    @State private var showingListPicker = false
    @State private var productImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray3))
                        .font(.title3)
                }
            }
            
            // Product Image
            if let image = productImage {
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
            
            // Product Info
            VStack(spacing: 8) {
                Text(product.productName)
                    .font(.title)
                    .fontWeight(.medium)
                
                Text(product._id)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 12)
            
            // Add to List Button
            HStack(spacing: 12) {
                // Add to Custom List Button
                Button {
                    showingListPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to List")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
        .padding(.horizontal, 40)
        .sheet(isPresented: $showingListPicker) {
            ListPickerView(isPresented: $showingListPicker, product: product)
        }
        .task {
            await loadProductImage()
        }
        .toast()
    }
    
    private func loadProductImage() async {
        guard let imageUrl = product.imageFrontUrl,
              let url = URL(string: imageUrl) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    productImage = image
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "sampleProduct", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
    return ProductPreviewCard(isPresented: .constant(true), product: welcome.product)
        .environment(ProductListManager.shared)
        .environment(MessageHandler.shared)
} 