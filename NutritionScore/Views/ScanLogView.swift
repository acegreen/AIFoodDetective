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
    @State private var showingCreateList: Bool = false
    @State private var showingPreview = false
    @State private var showingDeleteAlert = false
    @State private var showingEditAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SearchView(
                    searchText: $scannedCode,
                    onProductFound: { product, method in
                        productListManager.selectedProduct = product
                        let listType: ProductListName = method == .scan ? .scanHistory : .allViewedProducts
                        if let list = productListManager.systemLists.first(where: { $0.name == listType }) {
                            if productListManager.addToList(product, list: list) {
                                withAnimation {
                                    showingPreview = true
                                }
                            }
                        }
                    }
                )
                .padding(.horizontal)

                listSection
            }
            .navigationTitle("Dashboard")
            .background(
                Group {
                    NavigationLink(destination: scanHistoryDestination) {
                        EmptyView()
                    }
                    .isDetailLink(false)

                    NavigationLink(destination: allViewedDestination) {
                        EmptyView()
                    }
                    .isDetailLink(false)
                }
            )
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
            .sheet(isPresented: $showingCreateList) {
                CreateListView { listName in
                    let newList = ProductList(name: .custom(listName))
                    productListManager.productLists.append(newList)
                    productListManager.saveProductLists()
                    messageHandler.show("Created list '\(listName)'")
                }
            }
            .onChange(of: scannedCode) { newValue in
                if !newValue.isEmpty {
                    showingPreview = true
                }
            }
            .popup(isPresented: $showingPreview) {
                if let product = productListManager.selectedProduct {
                    ProductPreviewCard(isPresented: $showingPreview, product: product)
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
        }
        .toast()
    }

    private var listSection: some View {
        List {
            Section {
                // System Lists
                ForEach(productListManager.systemLists) { list in
                    NavigationLink(
                        destination: ProductListView(list: list)
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(list.name.rawValue)
                                .font(.headline)
                                .foregroundColor(.green)
                            Text(list.products.isEmpty ? "Empty list" : "\(list.products.count) products")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }

            // Custom Lists Section
            Section {
                ForEach(productListManager.customLists) { list in
                    NavigationLink(
                        destination: ProductListView(list: list)
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(list.name.rawValue)
                                .font(.headline)
                                .foregroundColor(.green)
                            Text(list.products.isEmpty ? "Empty list" : "\(list.products.count) products")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .leading) {
                        Button {
                            productListManager.selectedList = list
                            showingEditAlert = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        withAnimation(nil) {
                            Button(role: .destructive) {
                                productListManager.selectedList = list
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("CUSTOM LISTS")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        showingCreateList = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.green)
                    }
                }
                .padding(16)
            }
        }
        .listStyle(PlainListStyle())
    }

    private var scanHistoryDestination: some View {
        if let scanHistory = productListManager.systemLists.first(where: { $0.name == .scanHistory }) {
            return AnyView(
                ProductListView(list: scanHistory)
            )
        }
        return AnyView(EmptyView())
    }

    private var allViewedDestination: some View {
        if let allViewed = productListManager.systemLists.first(where: { $0.name == .allViewedProducts }) {
            return AnyView(
                ProductListView(list: allViewed)
            )
        }
        return AnyView(EmptyView())
    }

    private func addToList(_ product: Product, list: ProductList) {
        if productListManager.addToList(product, list: list) {
            messageHandler.show("Added '\(product.productName)' to \(list.name.rawValue)")
            
            // Handle navigation based on list type
            switch list.name {
            case .scanHistory:
                navigateToScanHistory = true
            case .allViewedProducts:
                navigateToAllViewed = true
            default:
                break
            }
        }
    }
}

#Preview {
    ScanLogView(scannedCode: .constant(""))
        .environment(MessageHandler.shared)
}

