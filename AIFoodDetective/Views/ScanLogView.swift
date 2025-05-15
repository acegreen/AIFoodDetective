import SwiftUI
//import Inject
import Observation

struct ScanLogView: View {
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

    enum Tab: String, CaseIterable, Identifiable {
        case scanned = "Scanned"
        case viewed = "Viewed"
        case submitted = "Submitted"
        var id: String { rawValue }
    }

    var filteredProducts: [Product] {
        switch selectedTab {
        case .viewed:
            return productListManager.systemLists.first(where: { $0.name == .allViewedProducts })?.products ?? []
        case .scanned:
            return productListManager.systemLists.first(where: { $0.name == .scanHistory })?.products ?? []
        case .submitted:
            return productListManager.systemLists.first(where: { $0.name == .submitted })?.products ?? []
        }
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Scans")
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
                    ListPickerView(isPresented: $showingListPicker, product: selectedProduct)
                }
            }
            .overlay(MessageView())
            .environment(messageHandler)
            .alert("Delete List", isPresented: $showingDeleteAlert) {
                if let list = productListManager.selectedList {
                    Button("Delete", role: .destructive) {
                        if let index = productListManager.productLists.firstIndex(where: { $0.id == list.id }) {
                            productListManager.productLists.remove(at: index)
                            productListManager.saveProductLists()
                            messageHandler.show("Deleted list '\(list.name.rawValue)'")
                        }
                        productListManager.selectedList = nil
                    }
                    Button("Cancel", role: .cancel) {
                        productListManager.selectedList = nil
                    }
                }
            } message: {
                if let list = productListManager.selectedList {
                    Text("Are you sure you want to delete '\(list.name.rawValue)'? This action cannot be undone.")
                }
            }
            .toast()
        }
    }

    private var listSection: some View {
        List {
            ForEach(filteredProducts, id: \.id) { product in
                NavigationLink(destination: ProductDetailsView(product: product)) {
                    ProductCellView(product: product)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
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
                        if let list = productListManager.systemLists.first(where: { $0.name == selectedTabListName }) {
                            _ = productListManager.addToList(product, list: list)
                        }
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

    private var selectedTabListName: ProductListName {
        switch selectedTab {
        case .scanned: return .scanHistory
        case .viewed: return .allViewedProducts
        case .submitted: return .submitted // If you have this case
        }
    }
}

#Preview {
    ScanLogView(scannedCode: .constant(""))
        .environment(MessageHandler.shared)
}

