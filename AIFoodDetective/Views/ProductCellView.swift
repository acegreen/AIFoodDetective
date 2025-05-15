import SwiftUI
// import Inject

struct ProductCellView: View {
    // @ObserveInjection var inject
    
    let product: Product
    
    var body: some View {
        HStack(alignment: .top) {
            // Product Image
            
            VStack {
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
                    .frame(maxWidth: .infinity)
                }
                Button("SHOP") {}
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(product.productName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    // Score badge
                    Text("\(product.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(product.scoreColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                //                // Ratings, stats, etc.
                //                if let rating = product.rating {
                //                    HStack(spacing: 4) {
                //                        ForEach(0..<5) { i in
                //                            Image(systemName: i < rating ? "star.fill" : "star")
                //                                .foregroundColor(.green)
                //                                .font(.caption)
                //                        }
                //                        Text(String(format: "%.1f", product.ratingValue))
                //                            .font(.caption)
                //                            .foregroundColor(.white)
                //                        Text("(\(product.ratingCount))")
                //                            .font(.caption2)
                //                            .foregroundColor(.gray)
                //                    }
                //                }
                
                //                if let subtitle = product.subtitle {
                //                    Text(subtitle)
                //                        .font(.caption)
                //                        .foregroundColor(.white)
                //                }
                
                // Ingredient Alerts
                //                HStack {
                //                    Image(systemName: "flask")
                //                    Text("Ingredient Alerts (\(product.ingredientAlerts))")
                //                    Image(systemName: "lock.fill")
                //                }
                //                .font(.caption2)
                //                .foregroundColor(.white.opacity(0.7))
                //                .padding(.vertical, 2)
                //                .background(Color.black.opacity(0.2))
                //                .cornerRadius(6)

                Spacer()
                
                // Stats row
                HStack(spacing: 24) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup.fill")
                        Text("1")
                    }
                    .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "text.bubble.fill")
                        Text("1")
                    }
                    .foregroundColor(.primary)
                    
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
                .padding(.bottom)
                .font(.body)
                .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        // .enableInjection()
    }
}
