import SwiftUI
import AVFoundation
// import Inject

struct BarcodeScannerView: UIViewControllerRepresentable {
    // @ObserveInjection var inject
    @Binding var isScanning: Bool
    @Binding var scannedCode: String?

    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.isScanning = isScanning
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        let parent: BarcodeScannerView

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        func didFind(code: String) {
            parent.scannedCode = code
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(code: String)
}

class ScannerViewController: UIViewController {
    weak var delegate: ScannerViewControllerDelegate?
    private var isStartingScanning = false
    private var hasInitializedCamera = false

    var isScanning: Bool = true {
        didSet {
            print("🔄 Scanning state changed to: \(isScanning)")
            guard oldValue != isScanning else { return }

            if isScanning {
                startScanning()
            } else {
                stopScanning()
            }
        }
    }

    private let captureSession = AVCaptureSession()
    private let previewLayer = AVCaptureVideoPreviewLayer()

    private let scannerOverlay = UIView()
    private let instructionLabel = UILabel()
    private let controlsStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("👀 View did appear")
        if !hasInitializedCamera {
            hasInitializedCamera = true
            isScanning = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("👋 View will disappear")
        stopScanning()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds // Updated to use view.bounds
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("📸 Camera access already authorized")
            setupCamera()
        case .notDetermined:
            print("🔐 Requesting camera access")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        print("✅ Camera access granted")
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            print("❌ Camera access denied or restricted")
            // Optionally show an alert to direct user to Settings
        @unknown default:
            print("❓ Unknown camera authorization status")
        }
    }

    private func setupCamera() {
        print("🎥 Setting up camera...")
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ No video capture device found")
            return
        }

        // Configure preview layer first
        previewLayer.session = captureSession
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                print("✅ Video input added successfully")
            } else {
                print("❌ Could not add video input")
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                print("✅ Metadata output added successfully")

                // Configure scanning area AFTER adding output
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13]

                // Configure the scanning area to match the overlay
                DispatchQueue.main.async { [self] in
                    let scanRect = self.previewLayer.metadataOutputRectConverted(
                        fromLayerRect: CGRect(
                            x: self.view.bounds.width * 0.1,
                            y: self.view.bounds.height * 0.3,
                            width: self.view.bounds.width * 0.8,
                            height: self.view.bounds.height * 0.4
                        )
                    )
                    metadataOutput.rectOfInterest = scanRect
                    setupOverlay()
                    print("📐 Scan rect set to: \(scanRect)")
                }

                print("✅ Metadata delegate and types configured")
            } else {
                print("❌ Could not add metadata output")
            }

            print("🎥 Starting capture session...")
            startScanning()

        } catch {
            print("❌ Camera setup error: \(error.localizedDescription)")
        }
    }

    private func startScanning() {
        guard !captureSession.isRunning && !isStartingScanning else {
            print("⚠️ Scanning already in progress")
            return
        }

        isStartingScanning = true
        print("▶️ Starting scanning session")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isStartingScanning = false
                print("✅ Scanning session started")
            }
        }
    }

    private func stopScanning() {
        guard captureSession.isRunning else {
            print("⚠️ Scanner already stopped")
            return
        }
        print("⏹️ Stopping scanning session")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
            DispatchQueue.main.async {
                self?.isStartingScanning = false
            }
        }
    }

    private func setupOverlay() {
        // Get the camera preview frame
        let previewFrame = previewLayer.frame
        
        // Calculate frame dimensions
        let frameWidth = previewFrame.width * 0.8
        let frameHeight = previewFrame.height * 0.7

        // Create the frame first
        scannerOverlay.frame = CGRect(
            origin: .zero,
            size: CGSize(width: frameWidth, height: frameHeight)
        )
        // Position it within the preview area
        scannerOverlay.center = CGPoint(
            x: previewFrame.midX,
            y: previewFrame.midY
        )
        
        // Ensure overlay is added to view
        if scannerOverlay.superview == nil {
            view.addSubview(scannerOverlay)
            
            // Create corner views
            let corners = [
                createCorner(position: .topLeft),
                createCorner(position: .topRight),
                createCorner(position: .bottomLeft),
                createCorner(position: .bottomRight)
            ]
            
            corners.forEach { scannerOverlay.addSubview($0) }
            
            // Add scan line
            let scanLine = UIView()
            scanLine.backgroundColor = UIColor.red
            let lineInset: CGFloat = 30
            scanLine.frame = CGRect(
                x: lineInset,
                y: frameHeight / 2,
                width: frameWidth - (lineInset * 2),
                height: 2
            )
            scannerOverlay.addSubview(scanLine)
        }
        
        // Update the scanning area
        if let metadataOutput = captureSession.outputs.first as? AVCaptureMetadataOutput {
            let scanRect = previewLayer.metadataOutputRectConverted(fromLayerRect: scannerOverlay.frame)
            metadataOutput.rectOfInterest = scanRect
        }
    }

    private func createCorner(position: CornerPosition) -> UIView {
        let corner = UIView()
        let size: CGFloat = 40
        let thickness: CGFloat = 3

        corner.frame = CGRect(x: 0, y: 0, width: size, height: size)
        corner.backgroundColor = .clear

        // Create the lines for each corner
        let vertical = UIView()
        vertical.backgroundColor = .white
        vertical.frame = CGRect(x: 0, y: 0, width: thickness, height: size)

        let horizontal = UIView()
        horizontal.backgroundColor = .white
        horizontal.frame = CGRect(x: 0, y: 0, width: size, height: thickness)

        switch position {
        case .topLeft:
            corner.frame.origin = CGPoint(x: 0, y: 0)
            // Position lines to create an L-shape pointing right and down
            vertical.frame.origin = CGPoint(x: 0, y: 0)
            horizontal.frame.origin = CGPoint(x: 0, y: 0)
            corner.addSubview(vertical)
            corner.addSubview(horizontal)

        case .topRight:
            corner.frame.origin = CGPoint(x: scannerOverlay.bounds.width - size, y: 0)
            // Position lines to create an L-shape pointing left and down
            vertical.frame.origin = CGPoint(x: size - thickness, y: 0)
            horizontal.frame.origin = CGPoint(x: 0, y: 0)
            corner.addSubview(vertical)
            corner.addSubview(horizontal)

        case .bottomLeft:
            corner.frame.origin = CGPoint(x: 0, y: scannerOverlay.bounds.height - size)
            // Position lines to create an L-shape pointing right and up
            vertical.frame.origin = CGPoint(x: 0, y: 0)
            horizontal.frame.origin = CGPoint(x: 0, y: size - thickness)
            corner.addSubview(vertical)
            corner.addSubview(horizontal)

        case .bottomRight:
            corner.frame.origin = CGPoint(x: scannerOverlay.bounds.width - size, y: scannerOverlay.bounds.height - size)
            // Position lines to create an L-shape pointing left and up
            vertical.frame.origin = CGPoint(x: size - thickness, y: 0)
            horizontal.frame.origin = CGPoint(x: 0, y: size - thickness)
            corner.addSubview(vertical)
            corner.addSubview(horizontal)
        }

        return corner
    }

    private enum CornerPosition {
        case topLeft, topRight, bottomLeft, bottomRight
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("🔍 Received metadata objects: \(metadataObjects.count)")

        guard isScanning else {
            print("❌ Scanner is not in scanning mode")
            return
        }

        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }

        print("✅ Found barcode: \(stringValue)")
        isScanning = false  // Stop scanning after finding a code
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        delegate?.didFind(code: stringValue)
    }
}
