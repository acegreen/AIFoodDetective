import SwiftUI
import AVFoundation
//import Inject

struct ScanView: View {
    //    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = false
    @State private var scannedCode: String?
    @State private var showAlert = false
    @State private var showManualEntry = false
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined

    let onScan: (String) -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if cameraPermission == .authorized {
                    // Scanner area - exactly 40% of screen height
                    ZStack {
                        BarcodeScannerView(
                            isScanning: $isScanning,
                            scannedCode: $scannedCode
                        )
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: geometry.size.height * 0.4
                    )
                    .ignoresSafeArea(.all, edges: .top)
                    
                    // Informational area - exactly 60% of screen height
                    VStack(spacing: 24) {
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
                        
                        Spacer()
                    }
                    .padding(48)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: geometry.size.height * 0.6
                    )
                    .background(Color(uiColor: .systemBackground))
                } else {
                    CameraPermissionView(status: cameraPermission)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .task {
            cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
            if cameraPermission == .notDetermined {
                let status = await AVCaptureDevice.requestAccess(for: .video)
                cameraPermission = status ? .authorized : .denied
            }
            if cameraPermission == .authorized {
                isScanning = true
            }
        }
        .onAppear {
            // Reset state when view appears
            scannedCode = nil
            if cameraPermission == .authorized {
                isScanning = false  // First set to false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isScanning = true   // Then set to true to trigger refresh
                }
            }
        }
        .onChange(of: cameraPermission) { newValue in
            if newValue == .authorized {
                isScanning = true
            }
        }
        .sheet(isPresented: $showManualEntry) {
            ManualBarcodeEntryView { code in
                onScan(code)
                dismiss()
            }
        }
        .onChange(of: scannedCode) { newValue in
            if let code = newValue {
                onScan(code)
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
    ScanView(onScan: { _ in })
}
