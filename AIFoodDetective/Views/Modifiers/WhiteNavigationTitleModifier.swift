//
//  WhiteNavigationTitleModifier.swift
//  AIFoodDetective
//
//  Created by AceGreen on 2025-05-15.
//

import SwiftUI

struct WhiteNavigationTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(uiColor: .systemGreen), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func whiteNavigationTitle() -> some View {
        modifier(WhiteNavigationTitleModifier())
    }
}
