//
//  AIAnalysis.swift
//  AIFoodDetective
//
//  Created by AceGreen on 2025-05-21.
//

import Foundation

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

