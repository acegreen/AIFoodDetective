import Foundation
import Observation

@Observable
class ProductListManager {
    static let shared = ProductListManager()
    
    var productLists: [ProductList] = []
    var selectedProduct: Product?
    var selectedList: ProductList?

    var systemLists: [ProductList] {
        Array(productLists.prefix(1))
    }
    
    var customLists: [ProductList] {
        Array(productLists.dropFirst(1))
    }
    
    private init() {
        self.productLists = Self.loadProductLists()
    }
    
    private static func loadProductLists() -> [ProductList] {
        guard let data = UserDefaults.standard.data(forKey: "savedProductLists"),
              let decodedLists = try? JSONDecoder().decode([ProductList].self, from: data) else {
            // Return default lists if nothing is saved
            let defaultLists = [
                ProductList(name: .scanned)
            ]
            // Save default lists immediately
            if let encoded = try? JSONEncoder().encode(defaultLists) {
                UserDefaults.standard.set(encoded, forKey: "savedProductLists")
            }
            return defaultLists
        }
        return decodedLists
    }
    
    func saveProductLists() {
        if let encoded = try? JSONEncoder().encode(productLists) {
            UserDefaults.standard.set(encoded, forKey: "savedProductLists")
            // Force UserDefaults to save immediately
            UserDefaults.standard.synchronize()
        }
    }
    
    func addToList(_ product: Product, list: ProductList) -> Bool {
        // Check if product already exists
        if !list.products.contains(where: { $0.id == product.id }) {
            if let index = productLists.firstIndex(where: { $0.id == list.id }) {
                var updatedLists = productLists
                let updatedList = list
                updatedList.products.insert(product, at: 0)
                updatedLists[index] = updatedList
                productLists = updatedLists
                saveProductLists()
                return true
            }
        }
        return false
    }
    
    func removeFromList(_ product: Product, list: ProductList) -> Bool {
        if let index = productLists.firstIndex(where: { $0.id == list.id }) {
            var updatedLists = productLists
            let updatedList = list
            updatedList.products.removeAll { $0.id == product.id }
            updatedLists[index] = updatedList
            productLists = updatedLists
            saveProductLists()
            return true
        }
        return false
    }
    
    func moveList(from source: IndexSet, to destination: Int) {
        // Create mutable copies of the arrays
        var lists = productLists
        let systemLists = Array(lists.prefix(2))
        var mutableCustomLists = Array(lists.dropFirst(2))
        
        // Move items in the custom lists section
        mutableCustomLists.move(fromOffsets: source, toOffset: destination)
        
        // Recombine the arrays
        productLists = systemLists + mutableCustomLists
        saveProductLists()
    }
    
    func deleteList(at offsets: IndexSet) -> ProductList? {
        // Ensure we're only working with valid indices
        guard let firstOffset = offsets.first,
              firstOffset < productLists.count - 2 else {
            return nil
        }
        
        // Get the list that will be deleted
        let listToDelete = productLists[firstOffset + 2]
        
        // Remove from the main array
        productLists.remove(at: firstOffset + 2)
        saveProductLists()
        
        return listToDelete
    }
    
    // Sorting method
    func sortedProducts(from list: ProductList, by option: HistoryView.SortOption, direction: HistoryView.SortDirection) -> [Product] {
        let products: [Product]
        
        switch option {
        case .date:
            products = list.products.sorted {
                guard let date1 = $0.createdDate, let date2 = $1.createdDate else { return false }
                return direction == .ascending ? date1 < date2 : date1 > date2
            }
        case .name:
            products = list.products.sorted { 
                direction == .ascending ? $0.productName < $1.productName : $0.productName > $1.productName 
            }
        case .barcode:
            products = list.products.filter { $0.scanMode == .barcode }
        case .aiScan:
            products = list.products.filter { $0.scanMode == .aiScan }
        }
        
        return products
    }
} 
