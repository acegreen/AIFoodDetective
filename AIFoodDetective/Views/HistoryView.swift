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
    @State private var selectedTab: Tab = .scanned
    @State private var products: [Product] = []
    @State private var navigationPath = NavigationPath()

    enum Tab: String, CaseIterable, Identifiable {
        case scanned = "Scanned"
        case viewed = "Viewed"
        case submitted = "Submitted"

        var id: String { rawValue }

        var toProductListName: ProductListName {
            switch self {
            case .scanned: return .scanned
            case .viewed: return .viewed
            case .submitted: return .submitted
            }
        }
    }

    var filteredProducts: [Product] {
        switch selectedTab {
        case .scanned:
            return productListManager.systemLists.first(where: { $0.name == .scanned })?.products ?? []
        case .viewed:
            return productListManager.systemLists.first(where: { $0.name == .viewed })?.products ?? []
        case .submitted:
            return productListManager.systemLists.first(where: { $0.name == .submitted })?.products ?? []
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                Picker("History", selection: $selectedTab) {
                    ForEach(Tab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                listSection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemBackground)
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
            .alert("Delete Product", isPresented: $showingDeleteAlert) {
                if let product = productListManager.selectedProduct {
                    Button("Delete", role: .destructive) {
                        if let list = productListManager.systemLists.first(where: { $0.name == selectedTab.toProductListName }) {
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
}

#Preview {
    HistoryView(scannedCode: .constant(""))
        .environment(MessageHandler.shared)
}

