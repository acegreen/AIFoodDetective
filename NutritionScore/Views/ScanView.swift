import SwiftUI
import AVFoundation
//import Inject

struct ScanView: View {
    //    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = false
    @Binding var selectedTab: Int
    @Binding var scannedCode: String
    @State private var showAlert = false
    @State private var showManualEntry = false
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    var onScan: ((String) -> Void)? = nil

    var body: some View {
        ZStack {
            // Barcode scanner takes the whole screen
            BarcodeScannerView(
                isScanning: $isScanning,
                scannedCode: $scannedCode
            )
            .ignoresSafeArea()

            // Overlay: Informational area
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 16) {
                    Text("Scan a Barcode")
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("Position the barcode within the frame above")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Enter Barcode Manually") {
                        showManualEntry = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            if !scannedCode.isEmpty {
                scannedCode = ""
            }
        }
        .onChange(of: scannedCode) { newValue in
            if !newValue.isEmpty {
                selectedTab = 1
                onScan?(newValue)
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
        .toast()
        //        .enableInjection()
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
