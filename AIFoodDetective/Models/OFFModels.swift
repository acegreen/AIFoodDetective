// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation
import SwiftUI
import UIKit

// MARK: - Welcome
struct Welcome: Codable {
    let code: String
    let product: Product
    let status: Int
    let statusVerbose: String
    let errors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case code, product, status
        case statusVerbose = "status_verbose"
        case errors
    }
}

// MARK: - Product
struct Product: Codable, Identifiable, Hashable, Equatable {
    var id: String { _id }
    let _id: String
    let productName: String
    let brands: String
    let nutriments: Nutriments?
    let ingredients: [ProductIngredient]?
    let ingredientsText: String?
    let nutriscoreGrade: String?
    let nutriscoreScore: Double?
    let origins: String?
    let traces: String?
    let packaging: String?
    let quantity: String?
    let servingSize: String?
    
    // New fields
    let categories: String?
    let allergens: String?
    let allergensFromIngredients: String?
    let brandOwner: String?
    let stores: String?
    let novaGroup: Int?
    let ecoscore: String?
    
    // New image URLs
    let imageFrontSmallUrl: String?
    let imageFrontThumbUrl: String?
    let imageFrontUrl: String?
    
    // New properties
    let createdT: Int?
    let completeness: Double?
    let uniqueScansN: Int?
    let sources: [Source]?
    
    // New labels
    let labels: String?
    
    // Image data
    let imageData: Data?
    
    // AI Analysis result
    let aiAnalysis: String?
    
    // Computed property for image URL
    var imageFrontURL: URL? {
        guard let urlString = imageFrontUrl else {
            print("DEBUG: imageFrontUrl is nil")
            return nil
        }
        let url = URL(string: urlString)
        return url
    }
    
    var scanMode: ScanView.ScanMode?
    
    enum CodingKeys: String, CodingKey {
        case _id
        case productName = "product_name"
        case brands
        case nutriments
        case ingredients
        case ingredientsText = "ingredients_text"
        case nutriscoreGrade = "nutriscore_grade"
        case nutriscoreScore = "nutriscore_score"
        case origins
        case traces
        case packaging
        case quantity
        case servingSize = "serving_size"
        case categories
        case allergens
        case allergensFromIngredients = "allergens_from_ingredients"
        case brandOwner = "brand_owner"
        case stores
        case novaGroup = "nova_group"
        case ecoscore = "ecoscore_grade"
        case imageFrontSmallUrl = "image_front_small_url"
        case imageFrontThumbUrl = "image_front_thumb_url"
        case imageFrontUrl = "image_front_url"
        case imageData
        case aiAnalysis
        
        // New coding keys
        case createdT = "created_t"
        case completeness
        case uniqueScansN = "unique_scans_n"
        case sources
        case labels
        case scanMode
    }
    
    // Computed properties
    var createdDate: Date? {
        guard let timestamp = createdT else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    var scansCount: Int? {
        uniqueScansN
    }
    
    // Equatable and Hashable conformance
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs._id == rhs._id // Compare based on unique identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id) // Hash based on unique identifier
    }

    /// Junk score from AI analysis or calculated value
    var junkScore: Double {
        // First try to get the score from AI analysis
        if let aiAnalysis, let parsedAnalysis = AIAnalysis.parse(from: aiAnalysis) {
            return parsedAnalysis.healthMetrics.junkScore
        }
        
        // Fallback to calculated score
        let sugar = nutriments?.sugars ?? 0
        let starch = nutriments?.carbohydrates ?? 0
        let score = min(1.0, (sugar + starch) / 100.0)
        return score
    }

    static var placeholder: Product {
        Product(
            _id: "1",
            productName: "The Soap Works Pure Glycerine Soap",
            brands: "The Soap Works",
            nutriments: nil,
            ingredients: nil,
            ingredientsText: nil,
            nutriscoreGrade: "a",
            nutriscoreScore: 2,
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
            imageFrontSmallUrl: nil,
            imageFrontThumbUrl: nil,
            imageFrontUrl: nil,
            createdT: nil,
            completeness: nil,
            uniqueScansN: nil,
            sources: nil,
            labels: nil,
            imageData: nil,
            aiAnalysis: nil,
            scanMode: nil
        )
    }

    static func createFromAIAnalysis(result: String, image: UIImage?) -> Product {
        // Create a unique ID for the AI-analyzed meal
        let uniqueId = "AI_\(UUID().uuidString)"
        
        // Convert image to data
        let imageData = image?.jpegData(compressionQuality: 0.8)
        
        // Parse the AI response using AIAnalysis
        guard let analysis = AIAnalysis.parse(from: result) else {
            // Fallback to basic product if parsing fails
            return Product(
                _id: uniqueId,
                productName: "AI Analyzed Meal",
                brands: "AI Analysis",
                nutriments: nil,
                ingredients: nil,
                ingredientsText: nil,
                nutriscoreGrade: nil,
                nutriscoreScore: nil,
                origins: nil,
                traces: nil,
                packaging: nil,
                quantity: nil,
                servingSize: "100g",
                categories: nil,
                allergens: nil,
                allergensFromIngredients: nil,
                brandOwner: nil,
                stores: nil,
                novaGroup: nil,
                ecoscore: nil,
                imageFrontSmallUrl: nil,
                imageFrontThumbUrl: nil,
                imageFrontUrl: nil,
                createdT: Int(Date().timeIntervalSince1970),
                completeness: nil,
                uniqueScansN: nil,
                sources: nil,
                labels: nil,
                imageData: imageData,
                aiAnalysis: result,
                scanMode: nil
            )
        }
        
        // Create Nutriments object from the analysis
        let nutriments = Nutriments.fromAI(
            proteins: analysis.nutritionalInfo.proteins,
            carbs: analysis.nutritionalInfo.carbohydrates,
            fats: analysis.nutritionalInfo.fats,
            sugars: analysis.nutritionalInfo.sugars,
            fiber: analysis.nutritionalInfo.fiber,
            starch: analysis.nutritionalInfo.starch,
            seedOils: analysis.nutritionalInfo.seedOils,
            energyKcal: analysis.nutritionalInfo.energyKcal,
            saturatedFat: analysis.nutritionalInfo.saturatedFat,
            sodium: analysis.nutritionalInfo.sodium
        )
        
        // Convert ingredients to ProductIngredient objects
        let ingredients = analysis.ingredients.map { ingredient in
            ProductIngredient(
                id: UUID().uuidString,
                text: ingredient,
                vegan: nil,
                vegetarian: nil,
                percentEstimate: nil
            )
        }
        
        // Create a Product from the analysis
        return Product(
            _id: uniqueId,
            productName: analysis.mainDish,
            brands: "AI Analysis",
            nutriments: nutriments,
            ingredients: ingredients,
            ingredientsText: analysis.ingredients.joined(separator: ", "),
            nutriscoreGrade: nil,
            nutriscoreScore: nil,
            origins: nil,
            traces: nil,
            packaging: nil,
            quantity: analysis.portionSize,
            servingSize: "100g",
            categories: nil,
            allergens: nil,
            allergensFromIngredients: nil,
            brandOwner: nil,
            stores: nil,
            novaGroup: nil,
            ecoscore: nil,
            imageFrontSmallUrl: nil,
            imageFrontThumbUrl: nil,
            imageFrontUrl: nil,
            createdT: Int(Date().timeIntervalSince1970),
            completeness: nil,
            uniqueScansN: nil,
            sources: nil,
            labels: nil,
            imageData: imageData,
            aiAnalysis: result,
            scanMode: nil
        )
    }
}

// MARK: - ProductIngredient
struct ProductIngredient: Codable {
    let id: String?
    let text: String
    let vegan: String?
    let vegetarian: String?
    let percentEstimate: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case vegan
        case vegetarian
        case percentEstimate = "percent_estimate"
    }

    var isSuspicious: Bool {
        vegan != "yes" || vegetarian != "yes"
    }
}

// MARK: - Nutriments
struct Nutriments: Codable {
    // Original properties as computed properties
    var proteins: Double? { proteins_value }
    var carbohydrates: Double? { carbohydrates_value }
    var fat: Double? { fat_value }
    var saturatedFat: Double? { saturatedFat_value }
    var transFat: Double? { transFat_value }
    var sugars: Double? { sugars_value }
    var fiber: Double? { fiber_value }
    var starch: Double? { starch_value }
    var seedOils: Double? { seedOils_value }
    var cholesterol: Double? { cholesterol_value }
    var sodium: Double? { sodium_value }
    var calcium: Double? { calcium_value }
    var phosphorus: Double? { phosphorus_value }
    var magnesium: Double? { magnesium_value }
    var potassium: Double? { potassium_value }
    var iron: Double? { iron_value }
    var zinc: Double? { zinc_value }
    var copper: Double? { copper_value }
    var selenium: Double? { selenium_value }
    var manganese: Double? { manganese_value }
    var iodine: Double? { iodine_value }
    var vitaminA: Double? { vitaminA_value }
    var vitaminC: Double? { vitaminC_value }
    var vitaminD: Double? { vitaminD_value }
    var vitaminE: Double? { vitaminE_value }
    var vitaminK: Double? { vitaminK_value }
    var vitaminB1: Double? { vitaminB1_value }
    var vitaminB2: Double? { vitaminB2_value }
    var vitaminB3: Double? { vitaminB3_value }
    var vitaminB5: Double? { vitaminB5_value }
    var vitaminB6: Double? { vitaminB6_value }
    var vitaminB9: Double? { vitaminB9_value }
    var vitaminB12: Double? { vitaminB12_value }
    var netCarbs: Double {
        guard let totalCarbs = carbohydrates else { return 0 }
        let fiberAmount = fiber ?? 0
        return max(0, totalCarbs - fiberAmount)
    }
    
    // Raw values from JSON
    private let proteins_value: Double?
    private let proteins_unit: String?
    private let carbohydrates_value: Double?
    private let carbohydrates_unit: String?
    private let fat_value: Double?
    private let fat_unit: String?
    private let saturatedFat_value: Double?
    private let saturatedFat_unit: String?
    private let transFat_value: Double?
    private let transFat_unit: String?
    private let sugars_value: Double?
    private let sugars_unit: String?
    private let fiber_value: Double?
    private let fiber_unit: String?
    private let starch_value: Double?
    private let starch_unit: String?
    private let seedOils_value: Double?
    private let seedOils_unit: String?
    private let cholesterol_value: Double?
    private let cholesterol_unit: String?
    private let sodium_value: Double?
    private let sodium_unit: String?
    private let calcium_value: Double?
    private let calcium_unit: String?
    private let phosphorus_value: Double?
    private let phosphorus_unit: String?
    private let magnesium_value: Double?
    private let magnesium_unit: String?
    private let potassium_value: Double?
    private let potassium_unit: String?
    private let iron_value: Double?
    private let iron_unit: String?
    private let zinc_value: Double?
    private let zinc_unit: String?
    private let copper_value: Double?
    private let copper_unit: String?
    private let selenium_value: Double?
    private let selenium_unit: String?
    private let manganese_value: Double?
    private let manganese_unit: String?
    private let iodine_value: Double?
    private let iodine_unit: String?
    private let vitaminA_value: Double?
    private let vitaminA_unit: String?
    private let vitaminC_value: Double?
    private let vitaminC_unit: String?
    private let vitaminD_value: Double?
    private let vitaminD_unit: String?
    private let vitaminE_value: Double?
    private let vitaminE_unit: String?
    private let vitaminK_value: Double?
    private let vitaminK_unit: String?
    private let vitaminB1_value: Double?
    private let vitaminB1_unit: String?
    private let vitaminB2_value: Double?
    private let vitaminB2_unit: String?
    private let vitaminB3_value: Double?
    private let vitaminB3_unit: String?
    private let vitaminB5_value: Double?
    private let vitaminB5_unit: String?
    private let vitaminB6_value: Double?
    private let vitaminB6_unit: String?
    private let vitaminB9_value: Double?
    private let vitaminB9_unit: String?
    private let vitaminB12_value: Double?
    private let vitaminB12_unit: String?
    private let energyKcal_value: Double?
    private let energyKj_value: Double?
    private let energyKcal_unit: String?
    private let energyKj_unit: String?
    
    private enum CodingKeys: String, CodingKey {
        case proteins_value = "proteins_value"
        case proteins_unit = "proteins_unit"
        case carbohydrates_value = "carbohydrates_value"
        case carbohydrates_unit = "carbohydrates_unit"
        case fat_value = "fat_value"
        case fat_unit = "fat_unit"
        case saturatedFat_value = "saturated-fat_value"
        case saturatedFat_unit = "saturated-fat_unit"
        case transFat_value = "trans-fat_value"
        case transFat_unit = "trans-fat_unit"
        case sugars_value = "sugars_value"
        case sugars_unit = "sugars_unit"
        case fiber_value = "fiber_value"
        case fiber_unit = "fiber_unit"
        case starch_value = "starch_value"
        case starch_unit = "starch_unit"
        case seedOils_value = "seed_oils_value"
        case seedOils_unit = "seed_oils_unit"
        case cholesterol_value = "cholesterol_value"
        case cholesterol_unit = "cholesterol_unit"
        case sodium_value = "sodium_value"
        case sodium_unit = "sodium_unit"
        case calcium_value = "calcium_value"
        case calcium_unit = "calcium_unit"
        case phosphorus_value = "phosphorus_value"
        case phosphorus_unit = "phosphorus_unit"
        case magnesium_value = "magnesium_value"
        case magnesium_unit = "magnesium_unit"
        case potassium_value = "potassium_value"
        case potassium_unit = "potassium_unit"
        case iron_value = "iron_value"
        case iron_unit = "iron_unit"
        case zinc_value = "zinc_value"
        case zinc_unit = "zinc_unit"
        case copper_value = "copper_value"
        case copper_unit = "copper_unit"
        case selenium_value = "selenium_value"
        case selenium_unit = "selenium_unit"
        case manganese_value = "manganese_value"
        case manganese_unit = "manganese_unit"
        case iodine_value = "iodine_value"
        case iodine_unit = "iodine_unit"
        case vitaminA_value = "vitamin-a_value"
        case vitaminA_unit = "vitamin-a_unit"
        case vitaminC_value = "vitamin-c_value"
        case vitaminC_unit = "vitamin-c_unit"
        case vitaminD_value = "vitamin-d_value"
        case vitaminD_unit = "vitamin-d_unit"
        case vitaminE_value = "vitamin-e_value"
        case vitaminE_unit = "vitamin-e_unit"
        case vitaminK_value = "vitamin-k_value"
        case vitaminK_unit = "vitamin-k_unit"
        case vitaminB1_value = "vitamin-b1_value"
        case vitaminB1_unit = "vitamin-b1_unit"
        case vitaminB2_value = "vitamin-b2_value"
        case vitaminB2_unit = "vitamin-b2_unit"
        case vitaminB3_value = "vitamin-b3_value"
        case vitaminB3_unit = "vitamin-b3_unit"
        case vitaminB5_value = "vitamin-b5_value"
        case vitaminB5_unit = "vitamin-b5_unit"
        case vitaminB6_value = "vitamin-b6_value"
        case vitaminB6_unit = "vitamin-b6_unit"
        case vitaminB9_value = "vitamin-b9_value"
        case vitaminB9_unit = "vitamin-b9_unit"
        case vitaminB12_value = "vitamin-b12_value"
        case vitaminB12_unit = "vitamin-b12_unit"
        case energyKcal_value = "energy-kcal_value"
        case energyKcal_unit = "energy-kcal_unit"
        case energyKj_value = "energy-kj_value"
        case energyKj_unit = "energy-kj_unit"
    }

    // Measurement computed properties
    var proteinsMeasurement: Measurement<UnitMass> { createMeasurement(proteins_value, unit: proteins_unit) }
    var carbohydratesMeasurement: Measurement<UnitMass> { createMeasurement(carbohydrates_value, unit: carbohydrates_unit) }
    var fatMeasurement: Measurement<UnitMass> { createMeasurement(fat_value, unit: fat_unit) }
    var saturatedFatMeasurement: Measurement<UnitMass> { createMeasurement(saturatedFat_value, unit: saturatedFat_unit) }
    var transFatMeasurement: Measurement<UnitMass> { createMeasurement(transFat_value, unit: transFat_unit) }
    var sugarsMeasurement: Measurement<UnitMass> { createMeasurement(sugars_value, unit: sugars_unit) }
    var fiberMeasurement: Measurement<UnitMass> { createMeasurement(fiber_value, unit: fiber_unit) }
    var cholesterolMeasurement: Measurement<UnitMass> { createMeasurement(cholesterol_value, unit: cholesterol_unit) }
    var sodiumMeasurement: Measurement<UnitMass> { createMeasurement(sodium_value, unit: sodium_unit) }
    var calciumMeasurement: Measurement<UnitMass> { createMeasurement(calcium_value, unit: calcium_unit) }
    var phosphorusMeasurement: Measurement<UnitMass> { createMeasurement(phosphorus_value, unit: phosphorus_unit) }
    var magnesiumMeasurement: Measurement<UnitMass> { createMeasurement(magnesium_value, unit: magnesium_unit) }
    var potassiumMeasurement: Measurement<UnitMass> { createMeasurement(potassium_value, unit: potassium_unit) }
    var ironMeasurement: Measurement<UnitMass> { createMeasurement(iron_value, unit: iron_unit) }
    var zincMeasurement: Measurement<UnitMass> { createMeasurement(zinc_value, unit: zinc_unit) }
    var copperMeasurement: Measurement<UnitMass> { createMeasurement(copper_value, unit: copper_unit) }
    var seleniumMeasurement: Measurement<UnitMass> { createMeasurement(selenium_value, unit: selenium_unit) }
    var manganeseMeasurement: Measurement<UnitMass> { createMeasurement(manganese_value, unit: manganese_unit) }
    var iodineMeasurement: Measurement<UnitMass> { createMeasurement(iodine_value, unit: iodine_unit) }
    var vitaminAMeasurement: Measurement<UnitMass> { createMeasurement(vitaminA_value, unit: vitaminA_unit) }
    var vitaminCMeasurement: Measurement<UnitMass> { createMeasurement(vitaminC_value, unit: vitaminC_unit) }
    var vitaminDMeasurement: Measurement<UnitMass> { createMeasurement(vitaminD_value, unit: vitaminD_unit) }
    var vitaminEMeasurement: Measurement<UnitMass> { createMeasurement(vitaminE_value, unit: vitaminE_unit) }
    var vitaminKMeasurement: Measurement<UnitMass> { createMeasurement(vitaminK_value, unit: vitaminK_unit) }
    var vitaminB1Measurement: Measurement<UnitMass> { createMeasurement(vitaminB1_value, unit: vitaminB1_unit) }
    var vitaminB2Measurement: Measurement<UnitMass> { createMeasurement(vitaminB2_value, unit: vitaminB2_unit) }
    var vitaminB3Measurement: Measurement<UnitMass> { createMeasurement(vitaminB3_value, unit: vitaminB3_unit) }
    var vitaminB5Measurement: Measurement<UnitMass> { createMeasurement(vitaminB5_value, unit: vitaminB5_unit) }
    var vitaminB6Measurement: Measurement<UnitMass> { createMeasurement(vitaminB6_value, unit: vitaminB6_unit) }
    var vitaminB9Measurement: Measurement<UnitMass> { createMeasurement(vitaminB9_value, unit: vitaminB9_unit) }
    var vitaminB12Measurement: Measurement<UnitMass> { createMeasurement(vitaminB12_value, unit: vitaminB12_unit) }
    var netCarbsMeasurement: Measurement<UnitMass> {
        let netCarbsValue = netCarbs
        return Measurement(value: netCarbsValue, unit: .grams)
    }
    var energyKcalMeasurement: Measurement<UnitMass> { createMeasurement(energyKcal_value, unit: energyKcal_unit) }
    
    // Add percentage calculations
    var carbsPercentage: Double {
        guard let carbs = carbohydrates else { return 0 }
        let total = (carbohydrates ?? 0) + (proteins ?? 0) + (fat ?? 0)
        guard total > 0 else { return 0 }
        return (carbs / total) * 100
    }
    
    var proteinPercentage: Double {
        guard let protein = proteins else { return 0 }
        let total = (carbohydrates ?? 0) + (proteins ?? 0) + (fat ?? 0)
        guard total > 0 else { return 0 }
        return (protein / total) * 100
    }
    
    var fatsPercentage: Double {
        guard let fats = fat else { return 0 }
        let total = (carbohydrates ?? 0) + (proteins ?? 0) + (fat ?? 0)
        guard total > 0 else { return 0 }
        return (fats / total) * 100
    }

    var netCarbsPercentage: Double {
        let total = (netCarbs) + (proteins ?? 0) + (fat ?? 0)
        guard total > 0 else { return 0 }
        return (netCarbs / total) * 100
    }

    // Helper function to create measurements
    private func createEnergyMeasurement(_ value: Double?, unit: String?) -> Measurement<UnitEnergy> {
        guard let value = value else { return Measurement(value: 0, unit: .kilocalories) }

        let unit = unit?.lowercased().trimmingCharacters(in: .whitespaces) ?? "kcal"
        let energyUnit = UnitEnergy.from(string: unit)
        return Measurement(value: value, unit: energyUnit)
    }

    private func createIUMeasurement(_ value: Double?, unit: String?) -> Measurement<UnitIU> {
        guard let value = value else { return Measurement(value: 0, unit: .internationalUnit) }
        return Measurement(value: value, unit: .internationalUnit)
    }

    private func createMeasurement(_ value: Double?, unit: String?) -> Measurement<UnitMass> {
        let unit = unit?.lowercased().trimmingCharacters(in: .whitespaces) ?? "mg"
        
        // If value is nil, return 0 in the specified unit
        guard let value = value else {
            if unit == "iu" {
                return Measurement(value: 0, unit: .micrograms)
            } else if unit == "kcal" || unit == "kj" {
                return Measurement(value: 0, unit: .grams)
            } else {
                let massUnit = UnitMass.from(string: unit)
                return Measurement(value: 0, unit: massUnit)
            }
        }
        
        // Handle special cases first
        if unit == "kcal" || unit == "kj" {
            let energyMeasurement = createEnergyMeasurement(value, unit: unit)
            return Measurement(value: energyMeasurement.value, unit: .grams)
        }
        
        if unit == "iu" {
            if value == vitaminA_value {
                return Measurement(value: value * 0.3, unit: .micrograms)
            } else if value == vitaminD_value {
                return Measurement(value: value * 0.025, unit: .micrograms)
            } else if value == vitaminE_value {
                return Measurement(value: value * 0.67, unit: .milligrams)
            } else {
                return Measurement(value: value, unit: .micrograms)
            }
        }
        
        let massUnit = UnitMass.from(string: unit)
        return Measurement(value: value, unit: massUnit)
    }

    var energyKcal: Double? { energyKcal_value }
    var energyKj: Double? { energyKj_value }
}

// Factory for AI analysis
extension Nutriments {
    static func fromAI(
        proteins: Double?,
        carbs: Double?,
        fats: Double?,
        sugars: Double?,
        fiber: Double?,
        starch: Double?,
        seedOils: Double?,
        energyKcal: Double?,
        saturatedFat: Double?,
        sodium: Double?
    ) -> Nutriments? {
        let dict: [String: Any?] = [
            "proteins_value": proteins,
            "proteins_unit": "g",
            "carbohydrates_value": carbs,
            "carbohydrates_unit": "g",
            "fat_value": fats,
            "fat_unit": "g",
            "sugars_value": sugars,
            "sugars_unit": "g",
            "fiber_value": fiber,
            "fiber_unit": "g",
            "starch_value": starch,
            "starch_unit": "g",
            "seed_oils_value": seedOils,
            "seed_oils_unit": "g",
            "energy-kcal_value": energyKcal,
            "energy-kcal_unit": "kcal",
            "saturated-fat_value": saturatedFat,
            "saturated-fat_unit": "g",
            "sodium_value": sodium,
            "sodium_unit": "g"
        ]
        let filtered = dict.compactMapValues { $0 }
        guard let data = try? JSONSerialization.data(withJSONObject: filtered, options: []) else { return nil }
        return try? JSONDecoder().decode(Nutriments.self, from: data)
    }
}

// MARK: - CategoriesProperties
struct CategoriesProperties: Codable { }

// MARK: - EcoscoreData
struct EcoscoreData: Codable {
    let adjustments: Adjustments
    let agribalyse: Agribalyse
    let missing: Missing
    let missingAgribalyseMatchWarning: Int
    let scores: CategoriesProperties
    let status: String

    enum CodingKeys: String, CodingKey {
        case adjustments, agribalyse, missing
        case missingAgribalyseMatchWarning = "missing_agribalyse_match_warning"
        case scores, status
    }
}

// MARK: - Adjustments
struct Adjustments: Codable {
    let originsOfIngredients: OriginsOfIngredients
    let packaging: AdjustmentsPackaging
    let productionSystem: ProductionSystem
    let threatenedSpecies: CategoriesProperties

    enum CodingKeys: String, CodingKey {
        case originsOfIngredients = "origins_of_ingredients"
        case packaging
        case productionSystem = "production_system"
        case threatenedSpecies = "threatened_species"
    }
}

// MARK: - OriginsOfIngredients
struct OriginsOfIngredients: Codable {
    let aggregatedOrigins: [AggregatedOrigin]
    let epiScore, epiValue: Int
    let originsFromCategories, originsFromOriginsField: [String]
    let transportationScore: Int
    let transportationScores: [String: Int]
    let transportationValue: Int
    let transportationValues: [String: Int]
    let value: Int
    let values: [String: Int]

    enum CodingKeys: String, CodingKey {
        case aggregatedOrigins = "aggregated_origins"
        case epiScore = "epi_score"
        case epiValue = "epi_value"
        case originsFromCategories = "origins_from_categories"
        case originsFromOriginsField = "origins_from_origins_field"
        case transportationScore = "transportation_score"
        case transportationScores = "transportation_scores"
        case transportationValue = "transportation_value"
        case transportationValues = "transportation_values"
        case value, values
    }
}

// MARK: - AggregatedOrigin
struct AggregatedOrigin: Codable {
    let epiScore, origin: String
    let percent, transportationScore: Int

    enum CodingKeys: String, CodingKey {
        case epiScore = "epi_score"
        case origin, percent
        case transportationScore = "transportation_score"
    }
}

// MARK: - AdjustmentsPackaging
struct AdjustmentsPackaging: Codable {
    let nonRecyclableAndNonBiodegradableMaterials: Int
    let packagings: [PackagingPackaging]
    let score, value: Int
    let warning: String

    enum CodingKeys: String, CodingKey {
        case nonRecyclableAndNonBiodegradableMaterials = "non_recyclable_and_non_biodegradable_materials"
        case packagings, score, value, warning
    }
}

// MARK: - PackagingPackaging
struct PackagingPackaging: Codable {
    let environmentalScoreMaterialScore, environmentalScoreShapeRatio: Int
    let material, shape: String

    enum CodingKeys: String, CodingKey {
        case environmentalScoreMaterialScore = "environmental_score_material_score"
        case environmentalScoreShapeRatio = "environmental_score_shape_ratio"
        case material, shape
    }
}

// MARK: - ProductionSystem
struct ProductionSystem: Codable {
    let labels: [String]
    let value: Int
    let warning: String
}

// MARK: - Agribalyse
struct Agribalyse: Codable {
    let warning: String
}

// MARK: - Missing
struct Missing: Codable {
    let agbCategory, labels, packagings: Int

    enum CodingKeys: String, CodingKey {
        case agbCategory = "agb_category"
        case labels, packagings
    }
}

// MARK: - Images
struct Images: Codable {
    let the1, the2, the3, the4: The1
    let the5: The1
    let front, frontEn, ingredients, ingredientsEn: FrontEnClass
    let nutrition, nutritionEn: FrontEnClass

    enum CodingKeys: String, CodingKey {
        case the1 = "1"
        case the2 = "2"
        case the3 = "3"
        case the4 = "4"
        case the5 = "5"
        case front
        case frontEn = "front_en"
        case ingredients
        case ingredientsEn = "ingredients_en"
        case nutrition
        case nutritionEn = "nutrition_en"
    }
}

// MARK: - FrontEnClass
struct FrontEnClass: Codable {
    let geometry, imgid: String
    let normalize: String?
    let rev: String
    let sizes: Sizes
    let whiteMagic: Bool?

    enum CodingKeys: String, CodingKey {
        case geometry, imgid, normalize, rev, sizes
        case whiteMagic = "white_magic"
    }
}

// MARK: - Sizes
struct Sizes: Codable {
    let the100, the400, full: The100
    let the200: The100?

    enum CodingKeys: String, CodingKey {
        case the100 = "100"
        case the400 = "400"
        case full
        case the200 = "200"
    }
}

// MARK: - The100
struct The100: Codable {
    let h, w: Int
}

// MARK: - The1
struct The1: Codable {
    let sizes: Sizes
    let uploadedT: Int
    let uploader: String

    enum CodingKeys: String, CodingKey {
        case sizes
        case uploadedT = "uploaded_t"
        case uploader
    }
}

// MARK: - IngredientsAnalysis
struct IngredientsAnalysis: Codable {
    let enPalmOilContentUnknown, enVeganStatusUnknown, enVegetarianStatusUnknown: [String]

    enum CodingKeys: String, CodingKey {
        case enPalmOilContentUnknown = "en:palm-oil-content-unknown"
        case enVeganStatusUnknown = "en:vegan-status-unknown"
        case enVegetarianStatusUnknown = "en:vegetarian-status-unknown"
    }
}

// MARK: - Languages
struct Languages: Codable {
    let enEnglish: Int

    enum CodingKeys: String, CodingKey {
        case enEnglish = "en:english"
    }
}

// MARK: - LanguagesCodes
struct LanguagesCodes: Codable {
    let en: Int
}

// MARK: - NutrientLevels
struct NutrientLevels: Codable {
    let fat, salt, saturatedFat, sugars: String

    enum CodingKeys: String, CodingKey {
        case fat, salt
        case saturatedFat = "saturated-fat"
        case sugars
    }
}

// MARK: - Nutriscore
struct Nutriscore: Codable {
    let categoryAvailable: Int
    let data: DataClass
    let grade: String
    let nutrientsAvailable, nutriscoreApplicable, nutriscoreComputed, score: Int

    enum CodingKeys: String, CodingKey {
        case categoryAvailable = "category_available"
        case data, grade
        case nutrientsAvailable = "nutrients_available"
        case nutriscoreApplicable = "nutriscore_applicable"
        case nutriscoreComputed = "nutriscore_computed"
        case score
    }
}

// MARK: - DataClass
struct DataClass: Codable {
    let energy, energyPoints, energyValue: Int?
    let fiber: Double?
    let fiberPoints: Int?
    let fiberValue, fruitsVegetablesNutsColzaWalnutOliveOils: Double?
    let fruitsVegetablesNutsColzaWalnutOliveOilsPoints, fruitsVegetablesNutsColzaWalnutOliveOilsValue: Int?
    let isBeverage, isCheese: Int
    let isFat: Int?
    let isWater, negativePoints, positivePoints: Int
    let proteins: Double?
    let proteinsPoints: Int?
    let proteinsValue, saturatedFat: Double?
    let saturatedFatPoints: Int?
    let saturatedFatValue: Double?
    let sodium, sodiumPoints, sodiumValue: Int?
    let sugars: Double?
    let sugarsPoints: Int?
    let sugarsValue: Double?
    let components: Components?
    let countProteins: Int?
    let countProteinsReason: String?
    let isFatOilNutsSeeds, isRedMeatProduct, negativePointsMax: Int?
    let positiveNutrients: [String]?
    let positivePointsMax: Int?
    let grade: String?
    let score: Int?

    enum CodingKeys: String, CodingKey {
        case energy
        case energyPoints = "energy_points"
        case energyValue = "energy_value"
        case fiber
        case fiberPoints = "fiber_points"
        case fiberValue = "fiber_value"
        case fruitsVegetablesNutsColzaWalnutOliveOils = "fruits_vegetables_nuts_colza_walnut_olive_oils"
        case fruitsVegetablesNutsColzaWalnutOliveOilsPoints = "fruits_vegetables_nuts_colza_walnut_olive_oils_points"
        case fruitsVegetablesNutsColzaWalnutOliveOilsValue = "fruits_vegetables_nuts_colza_walnut_olive_oils_value"
        case isBeverage = "is_beverage"
        case isCheese = "is_cheese"
        case isFat = "is_fat"
        case isWater = "is_water"
        case negativePoints = "negative_points"
        case positivePoints = "positive_points"
        case proteins
        case proteinsPoints = "proteins_points"
        case proteinsValue = "proteins_value"
        case saturatedFat = "saturated_fat"
        case saturatedFatPoints = "saturated_fat_points"
        case saturatedFatValue = "saturated_fat_value"
        case sodium
        case sodiumPoints = "sodium_points"
        case sodiumValue = "sodium_value"
        case sugars
        case sugarsPoints = "sugars_points"
        case sugarsValue = "sugars_value"
        case components
        case countProteins = "count_proteins"
        case countProteinsReason = "count_proteins_reason"
        case isFatOilNutsSeeds = "is_fat_oil_nuts_seeds"
        case isRedMeatProduct = "is_red_meat_product"
        case negativePointsMax = "negative_points_max"
        case positiveNutrients = "positive_nutrients"
        case positivePointsMax = "positive_points_max"
        case grade, score
    }
}

// MARK: - Components
struct Components: Codable {
    let negative, positive: [Tive]
}

// MARK: - Tive
struct Tive: Codable {
    let id: String
    let points: Int
    let pointsMax: Int
    let unit: String
    let value: Double

    enum CodingKeys: String, CodingKey {
        case id, points
        case pointsMax = "points_max"
        case unit, value
    }
}

// MARK: - NutriscoreData
struct NutriscoreData: Codable {
    let components: Components
    let countProteins: Int
    let countProteinsReason: String
    let isBeverage, isCheese, isFatOilNutsSeeds, isRedMeatProduct: Int
    let isWater, negativePoints, negativePointsMax: Int
    let positiveNutrients: [String]
    let positivePoints, positivePointsMax: Int
    let grade: String?
    let score: Int?

    enum CodingKeys: String, CodingKey {
        case components
        case countProteins = "count_proteins"
        case countProteinsReason = "count_proteins_reason"
        case isBeverage = "is_beverage"
        case isCheese = "is_cheese"
        case isFatOilNutsSeeds = "is_fat_oil_nuts_seeds"
        case isRedMeatProduct = "is_red_meat_product"
        case isWater = "is_water"
        case negativePoints = "negative_points"
        case negativePointsMax = "negative_points_max"
        case positiveNutrients = "positive_nutrients"
        case positivePoints = "positive_points"
        case positivePointsMax = "positive_points_max"
        case grade, score
    }
}

// MARK: - ProductPackaging
struct ProductPackaging: Codable {
    let shape: PackageShape
}

// MARK: - Shape
struct PackageShape: Codable {
    let id: String
}

// MARK: - PackagingsMaterials
struct PackagingsMaterials: Codable {
    let all, enUnknown: CategoriesProperties

    enum CodingKeys: String, CodingKey {
        case all
        case enUnknown = "en:unknown"
    }
}

// MARK: - SelectedImages
struct SelectedImages: Codable {
    let front, ingredients, nutrition: SelectedImagesFront
}

// MARK: - SelectedImagesFront
struct SelectedImagesFront: Codable {
    let display, small, thumb: Display
}

// MARK: - Display
struct Display: Codable {
    let en: String
}

// MARK: - Source
struct Source: Codable, Identifiable {
    let id: String
    let name: String?
    let importT: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case importT = "import_t"
    }
    
    var importDate: Date? {
        guard let timestamp = importT else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

// MARK: - SourcesFields
struct SourcesFields: Codable {
    let orgDatabaseUsda: OrgDatabaseUsda

    enum CodingKeys: String, CodingKey {
        case orgDatabaseUsda = "org-database-usda"
    }
}

// MARK: - OrgDatabaseUsda
struct OrgDatabaseUsda: Codable {
    let availableDate: Date
    let fdcCategory, fdcDataSource, fdcID: String
    let modifiedDate, publicationDate: Date

    enum CodingKeys: String, CodingKey {
        case availableDate = "available_date"
        case fdcCategory = "fdc_category"
        case fdcDataSource = "fdc_data_source"
        case fdcID = "fdc_id"
        case modifiedDate = "modified_date"
        case publicationDate = "publication_date"
    }
}

// MARK: - Result
struct Result: Codable {
    let id, lcName, name: String

    enum CodingKeys: String, CodingKey {
        case id
        case lcName = "lc_name"
        case name
    }
}

// MARK: - Warning
struct Warning: Codable {
    let field: Field
    let impact, message: Result
}

// MARK: - Field
struct Field: Codable {
    let id, value: String
}

// Add extensions for unit conversions
extension Double? {
    var converted: Measurement<UnitMass>? {
        guard let value = self else { return nil }
        return Measurement(value: value, unit: .grams)
    }
}

extension Measurement where UnitType == UnitMass {
    func converted(to unit: UnitMass) -> Double {
        converted(to: unit).value
    }
}

extension UnitMass {
    static func from(string: String) -> UnitMass {
        switch string {
        case "g", "gram", "grams":
            return .grams
        case "mg", "milligram", "milligrams":
            return .milligrams
        case "µg", "ug", "microgram", "micrograms":
            return .micrograms
        case "kg", "kilogram", "kilograms":
            return .kilograms
        case "oz", "ounce", "ounces":
            return .ounces
        case "lb", "lbs", "pound", "pounds":
            return .pounds
        default:
            // Default to grams if unit is unknown
            print("Warning: Unknown unit '\(string)' defaulting to grams")
            return .grams
        }
    }
}

extension UnitEnergy {
    static func from(string: String) -> UnitEnergy {
        switch string.lowercased() {
        case "kcal", "kilocalorie", "kilocalories":
            return .kilocalories
        case "kj", "kilojoule", "kilojoules":
            return .kilojoules
        default:
            print("Warning: Unknown energy unit '\(string)' defaulting to kilocalories")
            return .kilocalories
        }
    }
}

class UnitIU: Dimension {
    static let internationalUnit = UnitIU(symbol: "IU", converter: UnitConverterLinear(coefficient: 1.0))
    
    override class func baseUnit() -> Self {
        return internationalUnit as! Self
    }
}

struct AIAnalysis: Codable {
    let mainDish: String
    let ingredients: [String]
    let nutritionalInfo: NutritionalInfo
    let portionSize: String
    let healthMetrics: HealthMetrics
    let additionalNotes: String
    
    struct NutritionalInfo: Codable {
        let carbohydrates: Double
        let starch: Double
        let proteins: Double
        let fats: Double
        let seedOils: Double
        let sugars: Double
        let fiber: Double
        let energyKcal: Double
        let saturatedFat: Double
        let sodium: Double
    }
    
    struct HealthMetrics: Codable {
        let junkScore: Double
        let addedSugars: Double
        let refinedCarbs: Double
        let processedIngredients: [String]
    }
}

extension AIAnalysis {
    static func parse(from response: String) -> AIAnalysis? {
        let lines = response.components(separatedBy: .newlines)
        var currentSection = ""
        var mainDish = ""
        var ingredients: [String] = []
        var nutritionalInfo: NutritionalInfo?
        var portionSize = ""
        var healthMetrics: HealthMetrics?
        var additionalNotes = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.starts(with: "Main Dish:") {
                mainDish = trimmedLine.replacingOccurrences(of: "Main Dish:", with: "").trimmingCharacters(in: .whitespaces)
                currentSection = "mainDish"
            } else if trimmedLine.starts(with: "Ingredients:") {
                currentSection = "ingredients"
            } else if trimmedLine.starts(with: "Nutritional Information") {
                currentSection = "nutritional"
            } else if trimmedLine.starts(with: "Portion Size:") {
                portionSize = trimmedLine.replacingOccurrences(of: "Portion Size:", with: "").trimmingCharacters(in: .whitespaces)
                currentSection = "portion"
            } else if trimmedLine.starts(with: "Health Metrics:") {
                currentSection = "health"
            } else if trimmedLine.starts(with: "Additional Notes:") {
                currentSection = "notes"
            } else {
                switch currentSection {
                case "ingredients":
                    if trimmedLine.starts(with: "-") {
                        let ingredient = trimmedLine.dropFirst().trimmingCharacters(in: .whitespaces)
                        ingredients.append(ingredient)
                    }
                case "nutritional":
                    if nutritionalInfo == nil {
                        nutritionalInfo = parseNutritionalInfo(from: lines)
                    }
                case "health":
                    if healthMetrics == nil {
                        healthMetrics = parseHealthMetrics(from: lines)
                    }
                case "notes":
                    additionalNotes += trimmedLine + "\n"
                default:
                    break
                }
            }
        }
        
        guard let nutrition = nutritionalInfo,
              let metrics = healthMetrics else {
            return nil
        }
        
        return AIAnalysis(
            mainDish: mainDish,
            ingredients: ingredients,
            nutritionalInfo: nutrition,
            portionSize: portionSize,
            healthMetrics: metrics,
            additionalNotes: additionalNotes
        )
    }
    
    private static func parseNutritionalInfo(from lines: [String]) -> NutritionalInfo? {
        var inNutritionalSection = false
        var nutritionLines: [String] = []
        for line in lines {
            if line.contains("Nutritional Information") {
                inNutritionalSection = true
                continue
            }
            if inNutritionalSection {
                // Stop at the next section header
                if line.contains("Health Metrics:") || line.contains("Portion Size:") || line.contains("Additional Notes:") {
                    break
                }
                nutritionLines.append(line)
            }
        }

        // Now parse only nutritionLines
        var carbs: Double?
        var starch: Double?
        var proteins: Double?
        var fats: Double?
        var seedOils: Double?
        var sugars: Double?
        var fiber: Double?
        var energyKcal: Double?
        var saturatedFat: Double?
        var sodium: Double?

        for line in nutritionLines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let contentLine = trimmedLine.hasPrefix("- ") ? String(trimmedLine.dropFirst(2)) : trimmedLine

            if contentLine.contains("Carbohydrates:") {
                carbs = extractNumber(from: contentLine)
            } else if contentLine.contains("Starch:") {
                starch = extractNumber(from: contentLine)
            } else if contentLine.contains("Proteins:") {
                proteins = extractNumber(from: contentLine)
            } else if contentLine.contains("Fats:") {
                fats = extractNumber(from: contentLine)
            } else if contentLine.contains("Seed Oils:") {
                seedOils = extractNumber(from: contentLine)
            } else if contentLine.contains("Sugars:") {
                sugars = extractNumber(from: contentLine)
            } else if contentLine.contains("Fiber:") {
                fiber = extractNumber(from: contentLine)
            } else if contentLine.contains("Energy (kcal):") {
                energyKcal = extractNumber(from: contentLine)
            } else if contentLine.contains("Saturated Fat:") {
                saturatedFat = extractNumber(from: contentLine)
            } else if contentLine.contains("Sodium:") {
                sodium = extractNumber(from: contentLine)
            }
        }

        // Return the struct if all values are present
        if let carbs = carbs,
           let starch = starch,
           let proteins = proteins,
           let fats = fats,
           let seedOils = seedOils,
           let sugars = sugars,
           let fiber = fiber,
           let energyKcal = energyKcal,
           let saturatedFat = saturatedFat,
           let sodium = sodium {
            return NutritionalInfo(
                carbohydrates: carbs,
                starch: starch,
                proteins: proteins,
                fats: fats,
                seedOils: seedOils,
                sugars: sugars,
                fiber: fiber,
                energyKcal: energyKcal,
                saturatedFat: saturatedFat,
                sodium: sodium
            )
        } else {
            return nil
        }
    }
    
    private static func parseHealthMetrics(from lines: [String]) -> HealthMetrics? {
        var junkScore: Double?
        var addedSugars: Double?
        var refinedCarbs: Double?
        var processedIngredients: [String] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let contentLine = trimmedLine.hasPrefix("-") ? String(trimmedLine.dropFirst(2)) : trimmedLine
            
            if contentLine.contains("Junk Score:") {
                junkScore = extractNumber(from: contentLine)
            } else if contentLine.contains("Added Sugars:") {
                addedSugars = extractNumber(from: contentLine)
            } else if contentLine.contains("Refined Carbs:") {
                refinedCarbs = extractNumber(from: contentLine)
            } else if contentLine.contains("Processed Ingredients:") {
                processedIngredients = parseProcessedIngredients(from: lines)
            }
        }
        
        guard let junkScore = junkScore,
              let addedSugars = addedSugars,
              let refinedCarbs = refinedCarbs else {
            return nil
        }
        
        return HealthMetrics(
            junkScore: junkScore,
            addedSugars: addedSugars,
            refinedCarbs: refinedCarbs,
            processedIngredients: processedIngredients
        )
    }
    
    private static func parseProcessedIngredients(from lines: [String]) -> [String] {
        var ingredients: [String] = []
        var isProcessingIngredients = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let contentLine = trimmedLine.hasPrefix("-") ? String(trimmedLine.dropFirst(2)) : trimmedLine
            
            if contentLine.contains("Processed Ingredients:") {
                isProcessingIngredients = true
                continue
            }
            
            if isProcessingIngredients {
                if contentLine.isEmpty || contentLine.contains("Additional Notes:") {
                    break
                }
                if !contentLine.starts(with: "-") {
                    ingredients.append(contentLine)
                }
            }
        }
        
        return ingredients
    }
    
    private static func extractNumber(from string: String) -> Double? {
        let pattern = #"(\d+\.?\d*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
              let range = Range(match.range(at: 1), in: string) else {
            return nil
        }
        return Double(string[range])
    }
}
