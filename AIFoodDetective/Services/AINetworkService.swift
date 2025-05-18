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
                            "text": "Analyze this food image and provide a detailed breakdown in the following format:\n\nMain Dish: [Name of the main dish]\n\nIngredients: [List of visible ingredients]\n\nNutritional Information (per 100g):\n   - Carbohydrates: [X]g\n   - Starch: [X]g\n   - Proteins: [X]g\n   - Fats: [X]g\n   - Seed Oils: [X]g\n   - Sugars: [X]g\n   - Fiber: [X]g\n\nPortion Size: [Estimated portion size]\n\nJunk Score: [X.XX] (where X.XX is a number between 0.00 and 1.00)\n   Calculate this score based on:\n   - High sugar content (increases score)\n   - High refined carbohydrates (increases score)\n   - High saturated fat (increases score)\n   - Low fiber (increases score)\n   - Low protein (increases score)\n   A score of 0.00 means very healthy, 1.00 means very unhealthy\n\nAdditional Notes: [Any other relevant information]\n\nPlease provide numerical values for all nutritional information to enable accurate junk score calculation. If exact values cannot be determined, provide reasonable estimates based on typical values for similar foods. The junk score must be a decimal number between 0.00 and 1.00."
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