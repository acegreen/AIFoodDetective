import SwiftUI

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
    let outlineWidth: CGFloat = 4
    var outlineInset: CGFloat { outlineWidth / 2 }
    var usableHeight: CGFloat { cupHeight - outlineWidth }

    var topWidth: CGFloat { cupWidth * 0.95 }
    var bottomWidth: CGFloat { cupWidth * 0.80 }
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
        var currentY = cupHeight - outlineInset // Start at bottom inside the outline
        for (idx, layer) in validLayers.enumerated().reversed() {
            let height = heights[idx]
            let startY = currentY - height
            frames.insert((layer, startY, height), at: 0)
            currentY = startY
        }
        // The topmost layer should end at outlineInset
        return frames
    }

    func cupWidthAtY(_ y: CGFloat) -> CGFloat {
        topWidth - (topWidth - bottomWidth) * (y / cupHeight)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                // Water background when no layers
                if layerFrames.isEmpty {
                    TaperedLayerShape(
                        topWidth: topWidth,
                        bottomWidth: bottomWidth,
                        startY: cupHeight * 0.5, // Start at middle
                        endY: cupHeight,
                        totalHeight: cupHeight,
                        inset: 0,
                        cornerRadius: cupCornerRadius
                    )
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        // Water ripples
                        ForEach(0..<3, id: \.self) { _ in
                            Path { path in
                                let y = CGFloat.random(in: (cupHeight * 0.6)...(cupHeight * 0.9))
                                let startX = CGFloat.random(in: (topWidth * 0.2)...(topWidth * 0.7))
                                let endX = startX + CGFloat.random(in: 20...40)
                                let controlY = y + CGFloat.random(in: -2...2)
                                path.move(to: CGPoint(x: startX, y: y))
                                path.addQuadCurve(
                                    to: CGPoint(x: endX, y: y),
                                    control: CGPoint(x: (startX + endX) / 2, y: controlY)
                                )
                            }
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                        }
                    )
                }

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
                        inset: 0,
                        cornerRadius: cupCornerRadius
                    )
                    .fill(layer.color)
                    .overlay(
                        LayerOverlay(
                            type: layer.type,
                            width: bottomW,
                            height: height,
                            color: .white
                        )
                        .frame(width: bottomW, height: height)
                    )
                }

                // Cup Outline
                TaperedLayerShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    startY: 0,
                    endY: cupHeight,
                    totalHeight: cupHeight,
                    inset: outlineInset,
                    cornerRadius: cupCornerRadius
                )
                .stroke(Color.secondary, lineWidth: outlineWidth)
            }
            .clipShape(
                TaperedLayerShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    startY: 0,
                    endY: cupHeight,
                    totalHeight: cupHeight,
                    inset: outlineInset,
                    cornerRadius: cupCornerRadius
                )
            )

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

    // Store random positions for overlays
    let fiberPaths: [Path]
    let sugarCubes: [(CGRect, CGPoint)]
    let oilBubbles: [(CGRect, CGPoint)]

    init(type: JunkBreakdownType, width: CGFloat, height: CGFloat, color: Color) {
        self.type = type
        self.width = width
        self.height = height
        self.color = color

        // Starch fibers
        if type == .starch {
            self.fiberPaths = (0..<max(2, Int(width / 30))).map { _ in
                var path = Path()
                let y = CGFloat.random(in: (height * 0.2)...(height * 0.8))
                let startX = CGFloat.random(in: (width * 0.1)...(width * 0.7))
                let endX = startX + CGFloat.random(in: 0.2*width...0.5*width)
                let controlY = y + CGFloat.random(in: -0.05*height...0.05*height)
                path.move(to: CGPoint(x: startX, y: y))
                path.addQuadCurve(
                    to: CGPoint(x: endX, y: y),
                    control: CGPoint(x: (startX + endX) / 2, y: controlY)
                )
                return path
            }
        } else {
            self.fiberPaths = []
        }

        // Sugar cubes
        if type == .sugar {
            self.sugarCubes = (0..<max(2, Int(height / 18))).map { _ in
                let size = CGFloat.random(in: 0.15*height...0.35*height)
                let frame = CGRect(x: 0, y: 0, width: size, height: size)
                let position = CGPoint(
                    x: CGFloat.random(in: (width * 0.15)...(width * 0.85)),
                    y: CGFloat.random(in: (height * 0.15)...(height * 0.85))
                )
                return (frame, position)
            }
        } else {
            self.sugarCubes = []
        }

        // Seed oil bubbles
        if type == .seedOil {
            self.oilBubbles = (0..<max(3, Int(height / 10))).map { _ in
                let size = CGFloat.random(in: 0.1*height...0.3*height)
                let frame = CGRect(x: 0, y: 0, width: size, height: size)
                let position = CGPoint(
                    x: CGFloat.random(in: (width * 0.1)...(width * 0.9)),
                    y: CGFloat.random(in: (height * 0.1)...(height * 0.9))
                )
                return (frame, position)
            }
        } else {
            self.oilBubbles = []
        }
    }

    var body: some View {
        switch type {
        case .sugar:
            ForEach(0..<sugarCubes.count, id: \.self) { idx in
                let (frame, position) = sugarCubes[idx]
                Image(systemName: "cube.fill")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: frame.width, height: frame.height)
                    .foregroundColor(color.opacity(0.25))
                    .position(position)
            }
        case .seedOil:
            ForEach(0..<oilBubbles.count, id: \.self) { idx in
                let (frame, position) = oilBubbles[idx]
                Circle()
                    .fill(color.opacity(0.35))
                    .frame(width: frame.width, height: frame.height)
                    .position(position)
            }
        case .starch:
            ForEach(0..<fiberPaths.count, id: \.self) { idx in
                fiberPaths[idx]
                    .stroke(color.opacity(0.25), lineWidth: 2)
            }
        }
    }
}
