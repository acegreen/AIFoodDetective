import SwiftUI
import Observation
import UIKit


struct AIMealPreviewCard: View {
    @Binding var isPresented: Bool
    let analysisResult: String
    let capturedImage: UIImage
    @Environment(ProductListManager.self) var productListManager
    @Environment(MessageHandler.self) var messageHandler
    @State private var showingListPicker = false
    @State private var product: Product?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray3))
                        .font(.title3)
                }
            }
            
            // Captured Image
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .cornerRadius(8)
            
            // Analysis Result
            ScrollView {
                Text(analysisResult)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            // Add to List Button
            HStack(spacing: 12) {
                Button {
                    createProductFromAnalysis()
                    showingListPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to List")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
        .padding(.horizontal, 40)
        .sheet(isPresented: $showingListPicker) {
            if let product = product {
                ListPickerView(isPresented: $showingListPicker, product: product)
            }
        }
        .toast()
    }
    
    private func createProductFromAnalysis() {
        // Create a unique ID for the AI-analyzed meal
        let uniqueId = "AI_\(UUID().uuidString)"
        
        // Create a dictionary for nutriments that matches the Codable structure
        let nutrimentsDict: [String: Any] = [
            "proteins_value": 0.0,
            "proteins_unit": "g",
            "carbohydrates_value": 0.0,
            "carbohydrates_unit": "g",
            "fat_value": 0.0,
            "fat_unit": "g",
            "saturated-fat_value": 0.0,
            "saturated-fat_unit": "g",
            "trans-fat_value": 0.0,
            "trans-fat_unit": "g",
            "sugars_value": 0.0,
            "sugars_unit": "g",
            "fiber_value": 0.0,
            "fiber_unit": "g",
            "cholesterol_value": 0.0,
            "cholesterol_unit": "mg",
            "sodium_value": 0.0,
            "sodium_unit": "mg",
            "calcium_value": 0.0,
            "calcium_unit": "mg",
            "phosphorus_value": 0.0,
            "phosphorus_unit": "mg",
            "magnesium_value": 0.0,
            "magnesium_unit": "mg",
            "potassium_value": 0.0,
            "potassium_unit": "mg",
            "iron_value": 0.0,
            "iron_unit": "mg",
            "zinc_value": 0.0,
            "zinc_unit": "mg",
            "copper_value": 0.0,
            "copper_unit": "mg",
            "selenium_value": 0.0,
            "selenium_unit": "mg",
            "manganese_value": 0.0,
            "manganese_unit": "mg",
            "iodine_value": 0.0,
            "iodine_unit": "mg",
            "vitamin-a_value": 0.0,
            "vitamin-a_unit": "IU",
            "vitamin-c_value": 0.0,
            "vitamin-c_unit": "mg",
            "vitamin-d_value": 0.0,
            "vitamin-d_unit": "IU",
            "vitamin-e_value": 0.0,
            "vitamin-e_unit": "mg",
            "vitamin-k_value": 0.0,
            "vitamin-k_unit": "mg",
            "vitamin-b1_value": 0.0,
            "vitamin-b1_unit": "mg",
            "vitamin-b2_value": 0.0,
            "vitamin-b2_unit": "mg",
            "vitamin-b3_value": 0.0,
            "vitamin-b3_unit": "mg",
            "vitamin-b5_value": 0.0,
            "vitamin-b5_unit": "mg",
            "vitamin-b6_value": 0.0,
            "vitamin-b6_unit": "mg",
            "vitamin-b9_value": 0.0,
            "vitamin-b9_unit": "mg",
            "vitamin-b12_value": 0.0,
            "vitamin-b12_unit": "mg",
            "energy-kcal_value": 0.0,
            "energy-kcal_unit": "kcal"
        ]
        
        // Convert the dictionary to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: nutrimentsDict),
              let nutriments = try? JSONDecoder().decode(Nutriments.self, from: jsonData) else {
            print("Failed to create Nutriments instance")
            return
        }
        
        // Save the captured image to a temporary file
        let imageFileName = "\(uniqueId).jpg"
        let imagePath = FileManager.default.temporaryDirectory.appendingPathComponent(imageFileName)
        
        do {
            if let imageData = capturedImage.jpegData(compressionQuality: 0.8) {
                try imageData.write(to: imagePath)
            }
        } catch {
            print("Failed to save image: \(error)")
        }
        
        // Create a Product from the analysis
        product = Product(
            _id: uniqueId,
            productName: "AI Analyzed Meal",
            brands: "AI Analysis",
            nutriments: nutriments,
            ingredients: nil,
            ingredientsText: analysisResult,
            nutriscoreGrade: nil,
            nutriscoreScore: nil,
            origins: nil,
            traces: nil,
            packaging: nil,
            quantity: nil,
            servingSize: nil,
            categories: nil,
            allergens: nil,
            allergensFromIngredients: nil,
            brandOwner: nil,
            stores: nil,
            novaGroup: nil,
            ecoscore: nil,
            imageFrontSmallUrl: imagePath.absoluteString,
            imageFrontThumbUrl: imagePath.absoluteString,
            imageFrontUrl: imagePath.absoluteString,
            createdT: Int(Date().timeIntervalSince1970),
            completeness: nil,
            uniqueScansN: nil,
            sources: nil,
            labels: nil
        )
    }
}

#Preview {
    AIMealPreviewCard(
        isPresented: .constant(true),
        analysisResult: "This meal contains:\n- Grilled chicken breast\n- Steamed vegetables\n- Brown rice\n\nNutritional highlights:\n- High in protein\n- Low in fat\n- Good source of fiber",
        capturedImage: UIImage(systemName: "photo")!
    )
    .environment(ProductListManager.shared)
    .environment(MessageHandler.shared)
} 