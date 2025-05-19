import Foundation
import UIKit

@Observable
class AINetworkService {
    static let shared = AINetworkService()
    private let apiKey = "YOUR-API-KEY" // Replace with your actual API key
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    func analyzeMealImage(_ image: UIImage) async throws -> String {
        // Check if API key is set
        guard !apiKey.isEmpty else {
            print("❌ OpenAI API key not set. Please set your API key in AINetworkService.swift")
            throw AIError.apiError("OpenAI API key not configured")
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIError.invalidImage
        }

        let base64Image = imageData.base64EncodedString()
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare the request body for GPT-4 Vision
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this food image and provide a detailed breakdown in the following format:\n\nMain Dish: [Name of the main dish]\n\nIngredients: [List of visible ingredients]\n\nNutritional Information (per 100g):\n   - Carbohydrates: [X.X]g\n   - Starch: [X.X]g\n   - Proteins: [X.X]g\n   - Fats: [X.X]g\n   - Seed Oils: [X.X]g\n   - Sugars: [X.X]g\n   - Fiber: [X.X]g\n   - Energy (kcal): [X.X]kcal\n   - Saturated Fat: [X.X]g\n   - Sodium: [X.X]g\n\nPortion Size: [Estimated portion size]\n\nHealth Metrics:\n   - Junk Score: [X] (0-10, where 0 is healthiest)\n   - Added Sugars: [X.X]g\n   - Refined Carbs: [X.X]g\n   - Processed Ingredients: [List of processed ingredients]\n\nAdditional Notes: [Any other relevant information]\n\nPlease provide numerical values for all nutritional information. If exact values cannot be determined, provide reasonable estimates based on typical values for similar foods. The response should be structured to easily create an OpenFoodFacts Product object while maintaining important health metrics."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Failed to serialize request body: \(error)")
            throw AIError.apiError("Failed to prepare request")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.apiError("Invalid response")
            }
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("❌ API Error: \(message)")
                    throw AIError.apiError(message)
                }
                print("❌ API request failed with status code: \(httpResponse.statusCode)")
                throw AIError.apiError("API request failed with status code: \(httpResponse.statusCode)")
            }

            // Parse the response
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("❌ Failed to parse API response")
                throw AIError.apiError("Failed to parse API response")
            }

            #if DEBUG
            await APIResponseLogger.shared.saveResponse(content, prefix: "ai_meal_analysis")
            #endif
            return content
        } catch {
            print("❌ Network error: \(error)")
            throw AIError.apiError(error.localizedDescription)
        }
    }
}

enum AIError: Error {
    case invalidImage
    case apiError(String)
}

struct AIResponse: Decodable {
    let resultText: String
}