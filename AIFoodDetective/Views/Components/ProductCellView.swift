import SwiftUI
// import Inject

struct ProductCellView: View {
    // @ObserveInjection var inject

    let product: Product
    let showDetails: Bool

    var body: some View {
        CardView {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(product.productName)
                        .font(.title2)
                        .fontWeight(.bold)

                    if showDetails {
                        Group {
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
                        }
                    }

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

                VStack(alignment: .center) {
                    if let imageData = product.imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(8)
                    } else if let imageUrl = product.imageFrontURL {
                        AsyncImage(url: imageUrl) { image in
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
                    }
                    Button("SHOP") {}
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
