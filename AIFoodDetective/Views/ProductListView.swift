import SwiftUI
// import Inject
import Observation

struct ProductListView: View {
    // @ObserveInjection var inject
    @Environment(ProductListManager.self) var productListManager
    @Environment(MessageHandler.self) var messageHandler
    let list: ProductList
    @State private var showingAlert = false
    @State private var showingListPicker = false
    @State private var selectedProduct: Product?  // Unified state variable
    @State private var sortOption: ProductListView.SortOption = .newest  // Default sort option

    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case name = "Name"
        case barcode = "Barcode"
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            let sortedProducts = productListManager.sortedProducts(from: list, by: sortOption)

            if sortedProducts.isEmpty {
                Text("No products yet")
                    .foregroundColor(.systemBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sortedProducts) { product in
                        NavigationLink(destination: ProductDetailsView(product: product)) {
                            ProductCellView(product: product, compact: true)
                        }
                        .contextMenu {
                            Button {
                                selectedProduct = product
                                showingListPicker = true
                            } label: {
                                Label("Add to List", systemImage: "plus")
                            }

                            Button(role: .destructive) {
                                selectedProduct = product
                                showingAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.systemBackground)
        .navigationTitle(list.name.rawValue)
        .whiteNavigationTitle()
        .navigationBarItems(trailing: sortButton)
        .alert("Delete Product", isPresented: $showingAlert, presenting: selectedProduct) { product in
            Button("Delete", role: .destructive) {
                if let index = list.products.firstIndex(where: { $0.id == product.id }) {
                    list.products.remove(at: index)
                    productListManager.saveProductLists()
                    messageHandler.show("Removed '\(product.productName)' from list")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { product in
            Text("Are you sure you want to remove '\(product.productName)' from this list?")
        }
        .onChange(of: productListManager.selectedProduct) { product in
            guard let selectedProduct = product else {
                return
            }

            Task {
                do {
                    let fullProduct = try await NetworkService.shared.fetchProduct(barcode: selectedProduct._id)
                    // Update the product in the list with full details
                    if let listIndex = productListManager.productLists.firstIndex(where: { $0.id == list.id }),
                       let productIndex = productListManager.productLists[listIndex].products.firstIndex(where: { $0.id == selectedProduct.id }) {
                        productListManager.productLists[listIndex].products[productIndex] = fullProduct
                        productListManager.saveProductLists()
                    }
                } catch {
                    print("Error fetching product: \(error)")
                }
            }
        }
        .sheet(isPresented: $showingListPicker) {
            AddToListView(isPresented: $showingListPicker, product: selectedProduct!)
        }
    }

    private var sortButton: some View {
        Menu {
            Button(action: {
                sortOption = sortOption == .newest ? .oldest : .newest
            }) {
                Label("Order: \(sortOption == .newest ? "Newest" : "Oldest")", systemImage: sortOption == .newest ? "arrow.up" : "arrow.down")
            }
            ForEach(SortOption.allCases.filter { $0 != .newest && $0 != .oldest }, id: \.self) { option in
                Button(action: {
                    sortOption = option
                }) {
                    Text(option.rawValue)
                }
            }
        } label: {
            Label("Order", systemImage: "arrow.up.arrow.down")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ProductListView(list: ProductList(name: .custom("Test List")))
        .environment(MessageHandler.shared)
        .environment(ProductListManager.shared)
        .environment(NetworkService.shared)  // Added because of network calls in onChange
}
