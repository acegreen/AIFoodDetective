//
//  ContentView.swift
//  NutritionScore
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI

struct ProductDetailsView: View {
    @Environment(ProductListManager.self) var productListManager
    @Environment(MessageHandler.self) var messageHandler
    let product: Product
    @State private var showingListPicker = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ProductBasicInfoView(product: product)
                QualityView(product: product)
                NutritionView(product: product)
                IngredientsSection(ingredients: product.ingredients ?? [])
                AllergenAndNovaView(product: product)
                ProductCertificationsView(product: product)
                ProductDetailsSection(product: product)
                DataQualitySection(product: product)
            }
            .padding()
        }
        .navigationTitle("Food Report")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingListPicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingListPicker) {
            ListPickerView(isPresented: $showingListPicker, product: product)
        }
        .toast()
    }
}

// MARK: - ProductBasicInfoView
struct ProductBasicInfoView: View {
    let product: Product
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("Barcode", value: product._id)
                
                if let imageUrl = product.imageFrontUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .cornerRadius(8)
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Text(product.productName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let quantity = product.quantity {
                    LabeledContent("Quantity", value: quantity)
                }
                
                if let servingSize = product.servingSize {
                    LabeledContent("Serving Size", value: servingSize.formatServingSize())
                }
                
                if let origins = product.origins {
                    LabeledContent("Origin", value: origins)
                }
            }
        }
    }
    
    private func LabeledContent(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

// MARK: - Score Section
struct QualityView: View {
    let product: Product
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Quality Score", systemImage: "chart.bar.fill")
                
                if let grade = product.nutriscoreGrade {
                    ScoreGradeView(grade: grade)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if let score = product.nutriscoreScore {
                    ScoreMeterView(score: Double(score))
                        .frame(height: 220)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // Quality Indicators
                QualityIndicatorsView(nutriments: product.nutriments)
            }
        }
    }
}

// MARK: - Nutrition Section
struct NutritionView: View {
    let product: Product
    @State private var isExpanded: Bool = true
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "Nutrition", systemImage: "heart.fill")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        MacroBreakdownView(nutriments: product.nutriments)
                        
                        Divider()
                        
                        // Micronutrients section
                        Text("Micros")
                            .font(.title3)
                            .fontWeight(.bold)
                        MicroNutrientsView(nutriments: product.nutriments)
                    }
                }
            }
        }
    }
}

struct MacroBreakdownView: View {
    let nutriments: Nutriments
    @State private var showMicros: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 16) {
                MacroPieChart(
                    carbsPercentage: nutriments.carbsPercentage,
                    proteinPercentage: nutriments.proteinPercentage,
                    fatsPercentage: nutriments.fatsPercentage
                )
                .frame(width: 125, height: 125)

                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    MacroLegendItem(
                        name: "Carbs",
                        value: nutriments.carbohydratesMeasurement.converted(to: .grams).value,
                        color: .green
                    )
                    MacroLegendItem(
                        name: "Protein", 
                        value: nutriments.proteinsMeasurement.converted(to: .grams).value,
                        color: .purple
                    )
                    MacroLegendItem(
                        name: "Fat", 
                        value: nutriments.fatMeasurement.converted(to: .grams).value,
                        color: .yellow
                    )
                    MacroLegendItem(
                        name: "Net Carbs", 
                        value: nutriments.netCarbs,
                        color: .black
                    )
                }
            }
        }
        .padding()
    }
    
    struct MacroPieChart: View {
        let carbsPercentage: Double
        let proteinPercentage: Double
        let fatsPercentage: Double
        
        private func safeAngle(_ percentage: Double) -> Angle {
            guard percentage.isFinite else { return .degrees(-90) }
            let safePercentage = max(0, min(100, percentage))
            return .degrees(-90 + (360 * safePercentage/100))
        }
        
        var body: some View {
            ZStack {
                Canvas { context, size in
                    let total = carbsPercentage + proteinPercentage + fatsPercentage
                    guard total > 0 else { return }
                    
                    let center = CGPoint(x: size.width/2, y: size.height/2)
                    let radius = min(size.width, size.height) * 0.48
                    
                    // Draw fats segment (yellow)
                    if fatsPercentage > 0 {
                        let fatsPath = Path { p in
                            p.move(to: center)
                            p.addArc(center: center, 
                                    radius: radius,
                                    startAngle: .degrees(-90),
                                    endAngle: safeAngle(fatsPercentage),
                                    clockwise: false)
                            p.closeSubpath()
                        }
                        context.fill(fatsPath, with: .color(.yellow))
                    }
                    
                    // Draw protein segment (purple)
                    if proteinPercentage > 0 {
                        let proteinPath = Path { p in
                            p.move(to: center)
                            p.addArc(center: center, 
                                    radius: radius,
                                    startAngle: safeAngle(fatsPercentage),
                                    endAngle: safeAngle(fatsPercentage + proteinPercentage),
                                    clockwise: false)
                            p.closeSubpath()
                        }
                        context.fill(proteinPath, with: .color(.purple))
                    }
                    
                    // Draw carbs segment (green)
                    if carbsPercentage > 0 {
                        let carbsPath = Path { p in
                            p.move(to: center)
                            p.addArc(center: center, 
                                    radius: radius,
                                    startAngle: safeAngle(fatsPercentage + proteinPercentage),
                                    endAngle: safeAngle(fatsPercentage + proteinPercentage + carbsPercentage),
                                    clockwise: false)
                            p.closeSubpath()
                        }
                        context.fill(carbsPath, with: .color(.green))
                    }
                }
                
                GeometryReader { geometry in
                    let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                    let radius = min(geometry.size.width, geometry.size.height) * 0.48
                    
                    // Position labels
                    if fatsPercentage > 0 {
                        PercentageLabel(safePercentage(fatsPercentage), color: .yellow)
                            .position(safePosition(
                                angle: .degrees(-90 + (fatsPercentage * 3.6/2)),
                                radius: radius + 20,
                                center: center
                            ))
                    }
                    
                    if proteinPercentage > 0 {
                        PercentageLabel(safePercentage(proteinPercentage), color: .purple)
                            .position(safePosition(
                                angle: .degrees(-90 + (fatsPercentage * 3.6) + (proteinPercentage * 3.6/2)),
                                radius: radius + 20,
                                center: center
                            ))
                    }
                    
                    if carbsPercentage > 0 {
                        PercentageLabel(safePercentage(carbsPercentage), color: .green)
                            .position(safePosition(
                                angle: .degrees(-90 + (fatsPercentage + proteinPercentage) * 3.6 + (carbsPercentage * 3.6/2)),
                                radius: radius + 20,
                                center: center
                            ))
                    }
                }
            }
        }
        
        private func safePosition(angle: Angle, radius: Double, center: CGPoint) -> CGPoint {
            let x = center.x + cos(angle.radians) * radius
            let y = center.y + sin(angle.radians) * radius
            
            guard x.isFinite && y.isFinite else {
                return center
            }
            
            return CGPoint(x: x, y: y)
        }
        
        private func safePercentage(_ value: Double) -> String {
            guard value.isFinite else { return "0%" }
            return "\(Int(max(0, min(100, value))))%"
        }
        
        struct PercentageLabel: View {
            let text: String
            let color: Color
            
            init(_ text: String, color: Color) {
                self.text = text
                self.color = color
            }
            
            var body: some View {
                Text(text)
                    .font(.caption)
                    .foregroundColor(color)
                    .padding(4)
                    .cornerRadius(4)
            }
        }
    }
    
    struct MacroLegendItem: View {
        let name: String
        let value: Double
        let color: Color
        
        var body: some View {
            HStack(spacing: 8) {
                Text(name)
                    .frame(width: 80, alignment: .leading)
                    .foregroundColor(color)
                Text("\(Int(value))g")
                    .frame(width: 40, alignment: .trailing)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
    }
}

struct MicroNutrientsView: View {
    let nutriments: Nutriments
    @State private var showPercentages: Bool = false
    @State private var selectedCategory: MicroCategory = .minerals
    
    enum MicroCategory: String, CaseIterable {
        case minerals = "Minerals"
        case vitamins = "Vitamins"
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // Daily Value Toggle
            Button(action: { showPercentages.toggle() }) {
                Text(showPercentages ? "Hide % Daily Value" : "Show % Daily Value")
                    .foregroundColor(.green)
            }
            
            // Category Picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(MicroCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            
            // Nutrient List based on selected category
            ScrollView {
                VStack(spacing: 12) {
                    switch selectedCategory {
                    case .minerals:
                        // Minerals content
                        Group {
                            nutrientRow(name: "Calcium", measurement: nutriments.calciumMeasurement)
                            nutrientRow(name: "Iron", measurement: nutriments.ironMeasurement)
                            nutrientRow(name: "Phosphorus", measurement: nutriments.phosphorusMeasurement)
                            nutrientRow(name: "Magnesium", measurement: nutriments.magnesiumMeasurement)
                            nutrientRow(name: "Sodium", measurement: nutriments.sodiumMeasurement)
                            nutrientRow(name: "Potassium", measurement: nutriments.potassiumMeasurement)
                            nutrientRow(name: "Zinc", measurement: nutriments.zincMeasurement)
                            nutrientRow(name: "Copper", measurement: nutriments.copperMeasurement)
                            nutrientRow(name: "Selenium", measurement: nutriments.seleniumMeasurement)
                            nutrientRow(name: "Manganese", measurement: nutriments.manganeseMeasurement)
                            nutrientRow(name: "Iodine", measurement: nutriments.iodineMeasurement)
                        }
                    case .vitamins:
                        // Vitamins content
                        Group {
                            nutrientRow(name: "Vitamin A", measurement: nutriments.vitaminAMeasurement)
                            nutrientRow(name: "Vitamin C", measurement: nutriments.vitaminCMeasurement)
                            nutrientRow(name: "Vitamin D", measurement: nutriments.vitaminDMeasurement)
                            nutrientRow(name: "Vitamin E", measurement: nutriments.vitaminEMeasurement)
                            nutrientRow(name: "Vitamin K", measurement: nutriments.vitaminKMeasurement)
                            nutrientRow(name: "Vitamin B1", measurement: nutriments.vitaminB1Measurement)
                            nutrientRow(name: "Vitamin B2", measurement: nutriments.vitaminB2Measurement)
                            nutrientRow(name: "Vitamin B3", measurement: nutriments.vitaminB3Measurement)
                            nutrientRow(name: "Vitamin B5", measurement: nutriments.vitaminB5Measurement)
                            nutrientRow(name: "Vitamin B6", measurement: nutriments.vitaminB6Measurement)
                            nutrientRow(name: "Vitamin B7", measurement: Measurement(value: 0, unit: .micrograms))
                            nutrientRow(name: "Vitamin B9", measurement: nutriments.vitaminB9Measurement)
                            nutrientRow(name: "Vitamin B12", measurement: nutriments.vitaminB12Measurement)
                        }
                    }
                }
            }
        }
    }
    
    private func nutrientRow(name: String, measurement: Measurement<UnitMass>) -> some View {
        let value = measurement.converted(to: .milligrams).value
        let unit = measurement.unit.symbol
        return NutrientRow(
            name: name,
            value: "\(String(format: "%.1f", value))\(unit)",
            percentage: showPercentages ? "\(Int(value))%" : nil
        )
    }
}

struct NutrientRow: View {
    let name: String
    let value: String
    var percentage: String? = nil
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
            if let percentage = percentage {
                Text(percentage)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .font(.subheadline)
    }
}

struct QualityIndicatorsView: View {
    let nutriments: Nutriments
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Quality Indicators", systemImage: "star.circle")
            
            FlowLayout(spacing: 8) {
                QualityBadge(title: "High Protein", isActive: nutriments.proteinsMeasurement.converted(to: .grams).value > 20)
                QualityBadge(title: "Low Sugar", isActive: nutriments.sugarsMeasurement.converted(to: .grams).value < 15)
                QualityBadge(title: "High Fiber", isActive: nutriments.fiberMeasurement.converted(to: .grams).value > 5)
                QualityBadge(title: "Balanced Fats", isActive: nutriments.fatMeasurement.converted(to: .grams).value < 35)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct QualityBadge: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        Text(title)
            .font(.footnote)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? Color.green : Color.gray.opacity(0.3))
            .foregroundColor(isActive ? .white : .secondary)
            .cornerRadius(20)
    }
}

// Add these unit extensions if not already present
extension UnitMass {
    static let internationalUnits = UnitMass(symbol: "IU", converter: UnitConverterLinear(coefficient: 1))
    static let micrograms = UnitMass(symbol: "mcg", converter: UnitConverterLinear(coefficient: 0.000001))
}

struct IngredientsSection: View {
    let ingredients: [ProductIngredient]
    @State private var isExpanded: Bool = true
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "Ingredients", systemImage: "list.bullet.clipboard")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients listed by weight (first = most)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(ingredients, id: \.text) { ingredient in
                            HStack(spacing: 8) {
                                if ingredient.isSuspicious {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                }
                                
                                Text(ingredient.text)
                                    .foregroundColor(ingredient.isSuspicious ? .orange : .primary)
                                
                                if let percent = ingredient.percentEstimate {
                                    Text("(\(Int(percent))%)")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - AllergenAndNovaView
struct AllergenAndNovaView: View {
    let product: Product
    @State private var isExpanded: Bool = true
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "Allergens & Processing", systemImage: "exclamationmark.triangle")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        // Main Allergens
                        if let allergens = product.allergens?.cleanAllergenText() {
                            VStack(alignment: .leading) {
                                Text("Contains:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(allergens)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Additional Allergens
                        if let allergensFromIngredients = product.allergensFromIngredients?.cleanAllergenText(),
                           let mainAllergens = product.allergens?.cleanAllergenText(),
                           Set(allergensFromIngredients.components(separatedBy: ", ")) != Set(mainAllergens.components(separatedBy: ", ")) {
                            VStack(alignment: .leading) {
                                Text("Additional Allergens Found:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(allergensFromIngredients)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Traces
                        if let traces = product.traces?.cleanAllergenText(),
                           let mainAllergens = product.allergens?.cleanAllergenText(),
                           !traces.isEmpty && !mainAllergens.contains(traces) {
                            VStack(alignment: .leading) {
                                Text("May Also Contain:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(traces)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // NOVA Group
                        if let novaGroup = product.novaGroup {
                            VStack(alignment: .leading) {
                                Text("Food Processing (NOVA)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                HStack {
                                    Text("Group \(novaGroup)")
                                        .font(.body)
                                    Text(novaGroupExplanation(group: novaGroup))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private func novaGroupExplanation(group: Int) -> String {
        switch group {
        case 1: return "Unprocessed or minimally processed foods"
        case 2: return "Processed culinary ingredients"
        case 3: return "Processed foods"
        case 4: return "Ultra-processed foods"
        default: return ""
        }
    }
}

// MARK: - ProductCertificationsView
struct ProductCertificationsView: View {
    let product: Product
    @State private var isExpanded: Bool = true
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "Certifications & Impact", systemImage: "checkmark.seal")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        // Eco-score
                        if let ecoscore = product.ecoscore?.uppercased() {
                            HStack {
                                Text("Environmental Impact:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Eco-score \(ecoscore)")
                                    .font(.body)
                                
                                Image(systemName: ecoscoreIcon(grade: ecoscore))
                                    .foregroundColor(ecoscoreColor(grade: ecoscore))
                            }
                        }
                        
                        // Categories
                        if let categories = product.categories {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Categories:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(categories)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Labels & Certifications
                        if let labels = product.labels {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Labels & Certifications:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(labels.components(separatedBy: ","), id: \.self) { label in
                                        Text(label.trimmingCharacters(in: .whitespaces))
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private func ecoscoreIcon(grade: String) -> String {
        switch grade {
        case "A": return "leaf.fill"
        case "B": return "leaf"
        case "C": return "exclamationmark.triangle"
        case "D", "E": return "xmark.circle"
        default: return "questionmark.circle"
        }
    }
    
    private func ecoscoreColor(grade: String) -> Color {
        switch grade {
        case "A": return .green
        case "B": return .mint
        case "C": return .yellow
        case "D": return .orange
        case "E": return .red
        default: return .gray
        }
    }
}

// MARK: - ProductDetailsSection
struct ProductDetailsSection: View {
    let product: Product
    @State private var isExpanded: Bool = true
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "Product Details", systemImage: "info.circle")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        // Brand Information
                        if let brandOwner = product.brandOwner {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Manufacturer:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(brandOwner)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Brands
                        let brands = product.brands.components(separatedBy: ",")
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Brands:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(brands, id: \.self) { brand in
                                    Text(brand.trimmingCharacters(in: .whitespaces))
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Packaging
                        if let packaging = product.packaging {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Packaging:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(packaging)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Stores
                        if let stores = product.stores {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Available at:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(stores)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Created Date
                        if let createdT = product.createdT {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Added:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(Date(timeIntervalSince1970: TimeInterval(createdT)).formatted(date: .abbreviated, time: .omitted))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - DataQualitySection
struct DataQualitySection: View {
    let product: Product
    @State private var isExpanded: Bool = true
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { withAnimation { isExpanded.toggle() }}) {
                    HStack {
                        SectionHeader(title: "Data Quality", systemImage: "chart.bar")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        // Completeness Score
                        if let completeness = product.completeness {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Data Completeness:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Text("\(Int(completeness * 100))%")
                                        .font(.body)
                                    
                                    ProgressView(value: completeness)
                                        .tint(completenessColor(completeness))
                                }
                            }
                        }
                        
                        // Popularity (Scan Count)
                        if let scans = product.uniqueScansN {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Times Scanned:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(scans) scans")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Data Sources
                        if let sources = product.sources {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Data Sources:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                ForEach(sources, id: \.id) { source in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(source.name ?? "unknown")
                                                .font(.caption)
                                            if let importTime = source.importT {
                                                Text("Imported: \(Date(timeIntervalSince1970: TimeInterval(importTime)).formatted(date: .abbreviated, time: .omitted))")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private func completenessColor(_ score: Double) -> Color {
        switch score {
        case 0.8...: return .green
        case 0.6...: return .yellow
        case 0.4...: return .orange
        default: return .red
        }
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "sampleProduct", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
    return ProductDetailsView(product: welcome.product)
}
