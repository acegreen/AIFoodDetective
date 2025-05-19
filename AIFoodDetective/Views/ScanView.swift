import SwiftUI
import AVFoundation
import UIKit

struct ScanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MessageHandler.self) var messageHandler
    @Environment(ProductListManager.self) var productListManager
    @State private var isScanning = false
    @Binding var selectedTab: Int
    @Binding var scannedCode: String
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    @State private var scanMode: ScanMode = .aiScan
    @State private var detectedFood: String?
    @State private var triggerPhotoCapture = false
    @State private var isCameraReady = false
    @State private var aiLoading = false
    @State private var showPhotoCapture = false
    @State private var showingAIProductPreview = false
    @State private var showingBarcodeProductPreview = false
    @State private var showAlert = false
    @State private var showManualEntry = false
    @State private var previewProduct: Product? = nil
    @State private var capturedImage: UIImage? = nil
    var onScan: ((String) -> Void)? = nil

    enum ScanMode: String, CaseIterable, Identifiable {
        case aiScan = "AI Scan"
        case barcode = "Barcode"

        var id: String { rawValue }
        var title: String { rawValue }
    }

    var body: some View {
        ZStack {
            // Scanner view based on selected mode
            if scanMode == .barcode {
                BarcodeScannerView(
                    isScanning: $isScanning,
                    scannedCode: $scannedCode,
                    onScan: { code in
                        Task {
                            do {
                                let product = try await NetworkService.shared.fetchProduct(barcode: code)
                                previewProduct = product
                                showingBarcodeProductPreview = true
                                // Add to scan history
                                if let scannedList = productListManager.systemLists.first(where: { $0.name == .scanned }) {
                                    addToList(product, list: scannedList)
                                }
                            } catch {
                                // TODO:  Handle error (e.g., show an alert)
                            }
                        }
                    }
                )
                .ignoresSafeArea()
            } else {
                AIFoodScannerView(
                    isScanning: $isScanning,
                    detectedFood: $detectedFood,
                    onPhotoCaptured: { image in
                        capturedImage = image
                        aiLoading = true
                        Task {
                            do {
                                let result = try await AINetworkService.shared.analyzeMealImage(image)
                                let product = Product.createFromAIAnalysis(result: result, image: capturedImage)
                                previewProduct = product
                                showingAIProductPreview = true

                                // Add to scan history
                                if let scannedList = productListManager.systemLists.first(where: { $0.name == .scanned }) {
                                    addToList(product, list: scannedList)
                                }
                            } catch {
                                // TODO:  Handle error (e.g., show an alert)
                            }
                            aiLoading = false
                        }
                    },
                    triggerPhotoCapture: $triggerPhotoCapture,
                    isCameraReady: $isCameraReady,
                    scanMode: $scanMode
                )
                .ignoresSafeArea()
            }

            // Overlay: Informational area
            VStack(spacing: 24) {
                // Scan mode selector
                Picker("Scan Mode", selection: $scanMode) {
                    ForEach(ScanMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                VStack(spacing: 16) {
                    Text(scanMode == .barcode ? "Scan a Barcode" : "AI Meal Scan")
                        .font(.title)
                        .fontWeight(.semibold)

                    Text(scanMode == .barcode ?
                         "Position the barcode within the frame above" :
                            "Snap a photo, AI Meal Scan will log your whole meal in seconds")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                    if scanMode == .barcode {
                        Button("Enter Barcode Manually") {
                            showManualEntry = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    } else if scanMode == .aiScan {
                        Button(action: {
                            triggerPhotoCapture = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                triggerPhotoCapture = false
                            }
                        }) {
                            Image(systemName: "viewfinder.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 72, height: 72)
                                .foregroundColor(.purple)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 8)
                        }
                        .disabled(!isCameraReady)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }

            if aiLoading {
                // Full-screen blur overlay
                Rectangle()
                    .fill(.ultraThinMaterial) // or .regularMaterial for more blur
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(100)

                VStack {
                    ProgressView("Analyzing meal...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .font(.title2)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(101)
            }
        }
        .onAppear {
            if !scannedCode.isEmpty {
                scannedCode = ""
            }
            if let _ = detectedFood {
                detectedFood = nil
            }
            isScanning = true
        }
        .onDisappear {
            isScanning = false
        }
        .onChange(of: scanMode) { _ in
            isScanning = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isScanning = true
            }
        }
        .onChange(of: scannedCode) { newValue in
            if !newValue.isEmpty && scanMode == .barcode {
                isScanning = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isScanning = true
                }
                dismiss()
            }
        }
        .onChange(of: detectedFood) { newValue in
            if let food = newValue, scanMode == .aiScan {
                onScan?(food)
                isScanning = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isScanning = true
                }
                dismiss()
            }
        }
        .sheet(isPresented: $showManualEntry) {
            ManualBarcodeEntryView { code in
                scannedCode = code
                selectedTab = 1
                onScan?(code)
                dismiss()
            }
        }
        .sheet(isPresented: $showingAIProductPreview) {
            if let product = previewProduct {
                AIMealPreviewCard(isPresented: .constant(true), product: product)
            }
        }
        .sheet(isPresented: $showingBarcodeProductPreview) {
            if let product = previewProduct {
                BarcodePreviewCard(isPresented: $showingBarcodeProductPreview, product: product)
            }
        }
        .aiGlowBorder(enabled: scanMode == .aiScan)
    }

    private func addToList(_ product: Product, list: ProductList) {
        _ = productListManager.addToList(product, list: list)
    }
}

struct CameraPermissionView: View {
    let status: AVAuthorizationStatus

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.slash.fill")
                .font(.largeTitle)
            Text("Camera Access Required")
                .font(.title2)
            Text("Please enable camera access in Settings to scan barcodes")
                .multilineTextAlignment(.center)
            if status == .denied {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(48)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScanView(selectedTab: .constant(0), scannedCode: .constant(""), onScan: { _ in })
}
