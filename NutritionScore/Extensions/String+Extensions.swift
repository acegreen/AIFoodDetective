//
//  String+Extensions.swift
//  NutritionScore
//
//  Created by AceGreen on 2025-02-15.
//

import Foundation

extension String {
    func cleanAllergenText() -> String {
        self.replacingOccurrences(of: "en:", with: "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).capitalized }
            .joined(separator: ", ")
    }
    
    func formatServingSize() -> String {
        let components = self.components(separatedBy: " ")
        return components.map { str -> String in
            if let number = Double(str) {
                if number.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(Int(number))
                }
                
                // Common fractions using regular strings
                switch number {
                case 0.5: return "1/2"
                case 0.333, 0.334: return "1/3"
                case 0.666, 0.667: return "2/3"
                case 0.25: return "1/4"
                case 0.75: return "3/4"
                case 0.2: return "1/5"
                case 0.4: return "2/5"
                case 0.6: return "3/5"
                case 0.8: return "4/5"
                default: return String(format: "%.2f", number)
                }
            }
            return str
        }.joined(separator: " ")
    }
}
