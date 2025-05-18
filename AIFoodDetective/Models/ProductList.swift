import Foundation
import Observation

enum ProductListName: Codable, Equatable {
    case scanned
    case viewed
    case submitted
    case custom(String)  // Custom case now takes a String associated value

    var rawValue: String {
        switch self {
        case .scanned:
            return "Scanned"
        case .viewed:
            return "Viewed"
        case .submitted:
            return "Submitted"
        case .custom(let name):
            return name  // Return the associated value
        }
    }
}

@Observable
class ProductList: Identifiable, Codable, Equatable {
    let id: UUID
    var name: ProductListName
    var products: [Product]  // No longer needs @Published

    enum CodingKeys: CodingKey {
        case id
        case name
        case products
    }
    
    init(id: UUID = UUID(), name: ProductListName, products: [Product] = []) {
        self.id = id
        self.name = name
        self.products = products
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(ProductListName.self, forKey: .name)
        products = try container.decode([Product].self, forKey: .products)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(products, forKey: .products)
    }
    
    /// Adds a product if it doesn't exist already
    /// Returns true if the product was newly added, false if it already existed
    func addUniqueProduct(_ product: Product) -> Bool {
        if !products.contains(where: { $0.id == product.id }) {
            products.insert(product, at: 0)  // Add at the beginning
            return true
        }
        return false
    }

    static func == (lhs: ProductList, rhs: ProductList) -> Bool {
        lhs.id == rhs.id
    }
}
