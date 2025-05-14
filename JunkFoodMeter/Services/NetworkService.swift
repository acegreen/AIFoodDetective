import Foundation
import Observation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case apiError([String: Any])
    case productNotFound(barcode: String)
    case searchError(String)
    case noSearchResults
    
    var errorDescription: String? {
        switch self {
        case .productNotFound(let barcode):
            return "No product found with barcode: \(barcode)"
        case .searchError(let message):
            return "Search error: \(message)"
        case .noSearchResults:
            return "No products found matching your search"
        default:
            return "An error occurred"
        }
    }
}

@Observable
class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://world.openfoodfacts.org/api/v2"

    func fetchProduct(barcode: String) async throws -> Product {
        let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(Welcome.self, from: data)

        // print("Raw JSON response: \(String(data: data, encoding: .utf8) ?? "No data")")
        // Check if the product was found
        guard response.status == 1 else {
            throw NetworkError.productNotFound(barcode: barcode)
        }

        return response.product
    }
}
