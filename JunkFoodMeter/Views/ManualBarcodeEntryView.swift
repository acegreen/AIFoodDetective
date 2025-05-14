import SwiftUI
// import Inject

struct ManualBarcodeEntryView: View {
//    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    @State private var barcodeText = ""
    var onBarcodeEntered: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Example")
                            .foregroundColor(.secondary)
                        
                        // Example barcode with green background
                        Image(systemName: "barcode")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .padding()
                            .background(Color.mint.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // Text input with underline
                    VStack(spacing: 4) {
                        TextField("Enter the barcode number", text: $barcodeText)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Custom Numeric Keypad
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(1...9, id: \.self) { number in
                            KeypadButton(text: "\(number)", subText: getLetters(for: number)) {
                                barcodeText += "\(number)"
                            }
                        }
                        KeypadButton(text: ".", subText: "") {
                            if !barcodeText.contains(".") {
                                barcodeText += "."
                            }
                        }
                        KeypadButton(text: "0", subText: "") {
                            barcodeText += "0"
                        }
                        KeypadButton(text: "⌫", subText: "") {
                            if !barcodeText.isEmpty {
                                barcodeText.removeLast()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Barcode Scan")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !barcodeText.isEmpty {
                            onBarcodeEntered(barcodeText)
                            dismiss()
                        }
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.green, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
//        .enableInjection()
    }
    
    private func getLetters(for number: Int) -> String {
        switch number {
        case 2: return "ABC"
        case 3: return "DEF"
        case 4: return "GHI"
        case 5: return "JKL"
        case 6: return "MNO"
        case 7: return "PQRS"
        case 8: return "TUV"
        case 9: return "WXYZ"
        default: return ""
        }
    }
}

struct KeypadButton: View {
    let text: String
    let subText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(text)
                    .font(.title2)
                    .bold()
                Text(subText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
    }
} 
