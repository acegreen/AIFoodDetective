//
//  ScoreGradeView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-15.
//

import SwiftUI
//import Inject

struct ScoreGradeView: View {
//    @ObserveInjection var inject
    let grade: String
    
    private let grades = ["A", "B", "C", "D", "E"]
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(grades, id: \.self) { letterGrade in
                Text(letterGrade)
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 40, height: 32)
                    .background(
                        Rectangle()
                            .fill(nutriscoreColor(grade: letterGrade))
                    )
                    .foregroundColor(.white)
                    .overlay(
                        letterGrade == grade.uppercased() ?
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white, lineWidth: 2)
                            .padding(2) : nil
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
//        .enableInjection()
    }
    
    private func nutriscoreColor(grade: String) -> Color {
        switch grade.lowercased() {
        case "a": return Color(red: 0/255, green: 140/255, blue: 70/255)  // Dark green
        case "b": return Color(red: 150/255, green: 200/255, blue: 50/255) // Light green
        case "c": return Color(red: 255/255, green: 200/255, blue: 0/255)  // Yellow
        case "d": return Color(red: 255/255, green: 140/255, blue: 0/255)  // Orange
        case "e": return Color(red: 230/255, green: 0/255, blue: 0/255)    // Red
        default: return .gray
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        VStack(spacing: 20) {
            ScoreGradeView(grade: "A")
            ScoreGradeView(grade: "B")
            ScoreGradeView(grade: "C")
            ScoreGradeView(grade: "D")
            ScoreGradeView(grade: "E")
        }
    }
}
