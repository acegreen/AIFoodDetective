//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct AIAnalysisView: View {
    let aiResult: String
    @State private var isExpanded: Bool = true

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "AI Analysis", systemImage: "lasso.badge.sparkles")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                    }
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(aiResult)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}
