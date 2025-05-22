import SwiftUI
//import Inject
import Observation

struct HistoryView: View {
    //    @ObserveInjection var inject
    @Environment(MessageHandler.self) var messageHandler
    @Environment(ProductListManager.self) var productListManager
    @Binding var scannedCode: String
    @State private var navigateToScanHistory = false
    @State private var navigateToAllViewed = false
    @State private var showingListPicker = false
    @State private var showingDeleteAlert = false
    @State private var showingEditAlert = false
    @State private var products: [Product] = []
    @State private var navigationPath = NavigationPath()
    @State private var sortOption: SortOption = .date  // Default sort option
    @State private var sortDirection: SortDirection = .descending  // Default sort direction

    enum SortDirection {
        case ascending
        case descending
    }

    enum SortOption: String, CaseIterable {
        case date = "Date"
        case name = "Name"
        case barcode = "Barcode"
        case aiScan = "AI Scan"
    }

    var scannedList: ProductList? {
        productListManager.systemLists.first
    }

    var filteredProducts: [Product] {
        guard let list = scannedList else { return [] }
        return productListManager.sortedProducts(from: list, by: sortOption, direction: sortDirection)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            listSection
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .greenBackground()
            .navigationTitle("History")
            .whiteNavigationTitle()
            .sheet(isPresented: $showingEditAlert) {
                if let list = productListManager.selectedList {
                    CreateListView(
                        initialName: list.name.rawValue,
                        isEditing: true
                    ) { newName in
                        if let index = productListManager.productLists.firstIndex(where: { $0.id == list.id }) {
                            let updatedList = list
                            updatedList.name = .custom(newName)
                            productListManager.productLists[index] = updatedList
                            productListManager.saveProductLists()
                            messageHandler.show("Renamed list to '\(newName)'")
                        }
                        productListManager.selectedList = nil
                    }
                }
            }
            .sheet(isPresented: $showingListPicker) {
                if let selectedProduct = productListManager.selectedProduct {
                    AddToListView(isPresented: $showingListPicker, product: selectedProduct)
                }
            }
            .overlay(MessageView())
            .environment(messageHandler)
            .navigationDestination(for: Product.self) { product in
                ProductDetailsView(product: product)
            }
            .navigationBarItems(trailing: sortButton)
            .alert("Delete Product", isPresented: $showingDeleteAlert) {
                if let product = productListManager.selectedProduct {
                    Button("Delete", role: .destructive) {
                        if let list = productListManager.systemLists.first(where: { $0.name == .scanned }) {
                            _ = productListManager.removeFromList(product, list: list)
                        }
                        productListManager.selectedProduct = nil
                    }
                    Button("Cancel", role: .cancel) {
                        productListManager.selectedProduct = nil
                    }
                }
            } message: {
                if let product = productListManager.selectedProduct {
                    Text("Are you sure you want to delete '\(product.productName)'? This action cannot be undone.")
                }
            }
        }
    }

    private var listSection: some View {
        List {
            ForEach(filteredProducts, id: \.id) { product in
                Button {
                    navigationPath.append(product)
                } label: {
                    ProductCellView(product: product, compact: true)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .swipeActions(edge: .leading) {
                    Button {
                        productListManager.selectedProduct = product
                        showingListPicker = true
                    } label: {
                        Label("Add to List", systemImage: "plus")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        productListManager.selectedProduct = product
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }

    private var sortButton: some View {
        Menu {
            Button(action: {
                sortDirection = sortDirection == .ascending ? .descending : .ascending
            }) {
                Label("Order: \(sortDirection == .ascending ? "Ascending" : "Descending")", 
                      systemImage: sortDirection == .ascending ? "arrow.up" : "arrow.down")
            }
            ForEach(SortOption.allCases, id: \.self) { option in
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
    HistoryView(scannedCode: .constant(""))
        .environment(MessageHandler.shared)
}

