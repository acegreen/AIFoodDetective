import SwiftUI
import Observation

struct BarcodePreviewCard: View {
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
            } else if let imageUrl = product.imageFrontURL {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                        .cornerRadius(8)
                        .overlay(
                            ProgressView()
                        )
                }
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
            
            Spacer()
            
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
        .presentationDetents([.medium])
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "sampleProduct", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
    return BarcodePreviewCard(isPresented: .constant(true), product: welcome.product)
} 
