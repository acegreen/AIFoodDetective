//
//  ContentView.swift
//  AIFoodDetective
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
// import Inject

enum JunkBreakdownType: String, CaseIterable {
    case starch = "Starch"
    case seedOil = "Seed Oil"
    case sugar = "Added Sugar"

    var icon: String {
        switch self {
        case .starch: return "leaf"
        case .seedOil: return "drop.fill"
        case .sugar: return "cube.fill"
        }
    }

    var defaultColor: Color {
        switch self {
        case .starch: return .yellow
        case .seedOil: return .orange
        case .sugar: return .gray.opacity(0.25)
        }
    }
}

struct JunkFoodBreakdownView: View {
    //    @ObserveInjection var inject
    let product: Product

    var breakdown: [TaperedCupView.CupLayer] {
        [
            .init(type: .starch, color: JunkBreakdownType.starch.defaultColor, value: product.nutriments?.starch ?? 0),
            .init(type: .seedOil, color: JunkBreakdownType.seedOil.defaultColor, value: product.nutriments?.seedOils ?? 0),
            .init(type: .sugar, color: JunkBreakdownType.sugar.defaultColor, value: product.nutriments?.addedSugars ?? 0)
        ]
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Junk Breakdown", systemImage: "fork.knife")

                VStack(alignment: .center, spacing: -8) {
                    JunkFoodMeterView(product: product)

                    HStack(alignment: .center, spacing: 16) {
                        TaperedCupView(
                            layers: breakdown,
                            total: product.nutriments?.total ?? 0,
                            cupWidth: 140,
                            cupHeight: 140
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Macros: \(String(format: "%.1f", product.nutriments?.total ?? 0)) g")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.primary)
                                Text("(Carbs, Protein & Fats)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            ForEach(breakdown, id: \.label) { item in
                                HStack(alignment: .center, spacing: 8) {
                                    Image(systemName: item.icon)
                                        .foregroundColor(item.color)
                                        .frame(width: 24, alignment: .center)
                                    Text("\(item.label):")
                                        .font(.subheadline)
                                        .bold()
                                        .frame(width: 70, alignment: .leading)
                                    Text("\(String(format: "%.1f", item.value)) g")
                                        .font(.subheadline)
                                        .frame(alignment: .trailing)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
        }
    }
}

struct TaperedCupView: View {

    struct CupLayer {
        let type: JunkBreakdownType
        let color: Color
        let value: Double

        var label: String { type.rawValue }
        var icon: String { type.icon }
    }

    //    @ObserveInjection var inject
    let layers: [CupLayer]
    let total: Double
    let cupWidth: CGFloat
    let cupHeight: CGFloat
    let headspaceRatio: CGFloat = 0.15 // 15% empty at the top

    var headspace: CGFloat { cupHeight * headspaceRatio }
    var usableHeight: CGFloat { cupHeight - headspace }

    var topWidth: CGFloat { cupWidth * 0.95 }
    var bottomWidth: CGFloat { cupWidth * 0.80 }
    let outlineWidth: CGFloat = 4
    let lidHeight: CGFloat = 12
    let cupCornerRadius: CGFloat = 12
    let minLayerHeight: CGFloat = 12

    var layerFrames: [(layer: CupLayer, startY: CGFloat, height: CGFloat)] {
        let validLayers = (total > 0) ? layers.filter { $0.value > 0 } : []
        guard !validLayers.isEmpty else { return [] }

        // 1. Calculate proportional heights
        var heights = validLayers.map { CGFloat($0.value / total) * usableHeight }

        // 2. Enforce minimum height
        for i in heights.indices {
            if heights[i] > 0 && heights[i] < minLayerHeight {
                heights[i] = minLayerHeight
            }
        }

        // 3. If sum exceeds usableHeight, scale down proportionally
        let totalHeight = heights.reduce(0, +)
        if totalHeight > usableHeight {
            let scale = usableHeight / totalHeight
            heights = heights.map { $0 * scale }
        }

        // 4. Stack from the bottom
        var frames: [(CupLayer, CGFloat, CGFloat)] = []
        var currentY = cupHeight - outlineWidth / 2 // Start just above the bottom border
        for (idx, layer) in validLayers.enumerated().reversed() {
            let height = heights[idx]
            let startY = currentY - height
            frames.insert((layer, startY, height), at: 0)
            currentY = startY
        }
        return frames
    }

    func cupWidthAtY(_ y: CGFloat) -> CGFloat {
        topWidth - (topWidth - bottomWidth) * (y / cupHeight)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Cup Body Layers
            ForEach(layerFrames.indices, id: \.self) { idx in
                let (layer, startY, height) = layerFrames[idx]
                let endY = startY + height
                let topW = cupWidthAtY(startY)
                let bottomW = cupWidthAtY(endY)
                TaperedLayerShape(
                    topWidth: topW,
                    bottomWidth: bottomW,
                    startY: startY,
                    endY: endY,
                    totalHeight: cupHeight,
                    inset: outlineWidth / 2,
                    cornerRadius: cupCornerRadius
                )
                .fill(layer.color)
                .overlay(
                    GeometryReader { geo in
                        LayerOverlay(
                            type: layer.type,
                            width: geo.size.width,
                            height: geo.size.height,
                            color: .white
                        )
                        .clipShape(
                            TaperedLayerShape(
                                topWidth: geo.size.width,
                                bottomWidth: geo.size.width,
                                startY: 0,
                                endY: geo.size.height,
                                totalHeight: geo.size.height,
                                inset: 0,
                                cornerRadius: cupCornerRadius
                            )
                        )
                    }
                )
            }

            // Cup Outline
            TaperedLayerShape(
                topWidth: topWidth,
                bottomWidth: bottomWidth,
                startY: 0,
                endY: cupHeight,
                totalHeight: cupHeight,
                inset: outlineWidth / 2,
                cornerRadius: cupCornerRadius
            )
            .stroke(Color.secondary, lineWidth: outlineWidth)

            // Lid
            Capsule()
                .fill(Color.brown.opacity(0.8))
                .frame(width: topWidth, height: lidHeight)
                .offset(y: -cupHeight - 4)
                .overlay(
                    Capsule()
                        .stroke(Color.secondary, lineWidth: outlineWidth)
                        .frame(width: topWidth + outlineWidth, height: lidHeight)
                        .offset(y: -cupHeight - 4)
                )
        }
        .frame(width: topWidth + outlineWidth, height: cupHeight + 18)
        // .enableInjection()
    }
}

// MARK: - Tapered Layer Shape

struct TaperedLayerShape: Shape {
    let topWidth: CGFloat
    let bottomWidth: CGFloat
    let startY: CGFloat
    let endY: CGFloat
    let totalHeight: CGFloat
    var inset: CGFloat = 0
    var cornerRadius: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        let topY = rect.maxY - totalHeight + startY + inset
        let bottomY = rect.maxY - totalHeight + endY - inset
        let xCenter = rect.midX
        let topW = max(0, topWidth - 2 * inset)
        let bottomW = max(0, bottomWidth - 2 * inset)
        let radius = min(cornerRadius, (bottomW / 2) - 1, (topW / 2) - 1, (bottomY - topY) / 2)

        return Path { path in
            // Start at top left, below the top left corner
            path.move(to: CGPoint(x: xCenter - topW / 2 + radius, y: topY))
            // Top-left curve
            path.addQuadCurve(
                to: CGPoint(x: xCenter - topW / 2, y: topY + radius),
                control: CGPoint(x: xCenter - topW / 2, y: topY)
            )
            // Left side
            path.addLine(to: CGPoint(x: xCenter - bottomW / 2, y: bottomY - radius))
            // Bottom-left curve
            path.addQuadCurve(
                to: CGPoint(x: xCenter - bottomW / 2 + radius, y: bottomY),
                control: CGPoint(x: xCenter - bottomW / 2, y: bottomY)
            )
            // Bottom edge
            path.addLine(to: CGPoint(x: xCenter + bottomW / 2 - radius, y: bottomY))
            // Bottom-right curve
            path.addQuadCurve(
                to: CGPoint(x: xCenter + bottomW / 2, y: bottomY - radius),
                control: CGPoint(x: xCenter + bottomW / 2, y: bottomY)
            )
            // Right side
            path.addLine(to: CGPoint(x: xCenter + topW / 2, y: topY + radius))
            // Top-right curve
            path.addQuadCurve(
                to: CGPoint(x: xCenter + topW / 2 - radius, y: topY),
                control: CGPoint(x: xCenter + topW / 2, y: topY)
            )
            // Close path
            path.addLine(to: CGPoint(x: xCenter - topW / 2 + radius, y: topY))
            path.closeSubpath()
        }
    }
}

// MARK: - Layer Overlay

struct LayerOverlay: View {
    let type: JunkBreakdownType
    let width: CGFloat
    let height: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            switch type {
            case .sugar:
                // Sugar cubes
                ForEach(0..<max(2, Int(height / 18)), id: \.self) { _ in
                    Image(systemName: "cube.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: CGFloat.random(in: 10...16), height: CGFloat.random(in: 10...16))
                        .foregroundColor(color.opacity(0.25))
                        .position(
                            x: CGFloat.random(in: (width * 0.15)...(width * 0.85)),
                            y: CGFloat.random(in: (height * 0.15)...(height * 0.85))
                        )
                }
            case .seedOil:
                // Bubbles
                ForEach(0..<max(3, Int(height / 10)), id: \.self) { _ in
                    Circle()
                        .fill(color.opacity(0.35))
                        .frame(width: CGFloat.random(in: 8...18), height: CGFloat.random(in: 8...18))
                        .position(
                            x: CGFloat.random(in: (width * 0.1)...(width * 0.9)),
                            y: CGFloat.random(in: (height * 0.1)...(height * 0.9))
                        )
                }
            case .starch:
                // Fiber strands (lines)
                ForEach(0..<max(2, Int(width / 30)), id: \.self) { _ in
                    Path { path in
                        let startX = CGFloat.random(in: (width * 0.1)...(width * 0.9))
                        let startY = CGFloat.random(in: (height * 0.1)...(height * 0.9))
                        let endX = startX + CGFloat.random(in: -10...10)
                        let endY = startY + CGFloat.random(in: 18...28)
                        path.move(to: CGPoint(x: startX, y: startY))
                        path.addQuadCurve(
                            to: CGPoint(x: endX, y: endY),
                            control: CGPoint(x: (startX + endX) / 2 + CGFloat.random(in: -8...8), y: (startY + endY) / 2)
                        )
                    }
                    .stroke(color.opacity(0.25), lineWidth: 2)
                }
            }
        }
        .clipped()
    }
}
