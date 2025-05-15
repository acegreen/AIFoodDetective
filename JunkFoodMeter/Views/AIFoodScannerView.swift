import SwiftUI
import AVFoundation
import UIKit

struct AIFoodScannerView: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    @Binding var detectedFood: String?
    var onPhotoCaptured: ((UIImage) -> Void)? = nil
    @Binding var triggerPhotoCapture: Bool
    @Binding var isCameraReady: Bool
    @Binding var scanMode: ScanView.ScanMode
    
    func makeUIViewController(context: Context) -> AIFoodScannerViewController {
        let viewController = AIFoodScannerViewController()
        viewController.delegate = context.coordinator
        viewController.onPhotoCaptured = onPhotoCaptured
        viewController.onCameraReady = { isCameraReady = true }
        viewController.scanMode = scanMode
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: AIFoodScannerViewController, context: Context) {
        uiViewController.isScanning = isScanning
        uiViewController.onPhotoCaptured = onPhotoCaptured
        uiViewController.scanMode = scanMode
        if triggerPhotoCapture {
            uiViewController.triggerPhotoCapture()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AIFoodScannerViewControllerDelegate {
        let parent: AIFoodScannerView
        
        init(_ parent: AIFoodScannerView) {
            self.parent = parent
        }
        
        func didDetectFood(_ food: String) {
            parent.detectedFood = food
        }
    }
}

protocol AIFoodScannerViewControllerDelegate: AnyObject {
    func didDetectFood(_ food: String)
}

class AIFoodScannerViewController: UIViewController {
    weak var delegate: AIFoodScannerViewControllerDelegate?
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onCameraReady: (() -> Void)?
    var scanMode: ScanView.ScanMode = .aiScan
    private var isStartingScanning = false
    private var hasInitializedCamera = false
    private var isProcessingFrame = false
    
    var isScanning: Bool = true {
        didSet {
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
    private let photoOutput = AVCapturePhotoOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasInitializedCamera {
            checkCameraPermissions()
        } else if !captureSession.isRunning {
            startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            stopScanning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        setupOverlay()
        updateScanRect()
        if previewLayer.superlayer !== view.layer {
            print("Re-inserting preview layer")
            view.layer.insertSublayer(previewLayer, at: 0)
        }
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
        guard !hasInitializedCamera else { return }
        hasInitializedCamera = true
        print("🎥 Setting up camera...")
        let devices = AVCaptureDevice.devices(for: .video)
        print("Available video devices: \(devices)")
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ No video capture device found")
            return
        }

        previewLayer.session = captureSession
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        do {
            captureSession.beginConfiguration()
            
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                print("✅ Video input added successfully")
            } else {
                print("❌ Could not add video input")
            }

            let videoOutput = AVCaptureVideoDataOutput()
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                print("✅ Video output added successfully")
                
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                videoOutput.alwaysDiscardsLateVideoFrames = true
                
                print("✅ Video delegate configured")
            } else {
                print("❌ Could not add video output")
            }

            // Add photo output for still image capture (only if not already added)
            if !captureSession.outputs.contains(where: { $0 === photoOutput }) {
                if captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                    print("✅ Photo output added successfully")
                }
            }
            
            captureSession.commitConfiguration()
            print("🎥 Starting capture session...")
            startScanning()

        } catch {
            print("❌ Camera setup error: \(error.localizedDescription)")
        }
    }
    
    private func startScanning() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.onCameraReady?()
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
                print("✅ Scanning session stopped")
            }
        }
    }
    
    private func setupOverlay() {
        let previewFrame = previewLayer.frame
        let overlayHeight = previewFrame.height / 3
        let overlayWidth = previewFrame.width * 0.8
        
        let verticalOffset: CGFloat = 140
        
        scannerOverlay.frame = CGRect(
            x: (previewFrame.width - overlayWidth) / 2,
            y: (previewFrame.height - overlayHeight) / 2 - verticalOffset,
            width: overlayWidth,
            height: overlayHeight
        )
        
        if scannerOverlay.superview == nil {
            view.addSubview(scannerOverlay)
            scannerOverlay.layer.borderColor = UIColor.white.cgColor
            scannerOverlay.layer.borderWidth = 2
            scannerOverlay.layer.cornerRadius = 12
        }
    }
    
    private func updateScanRect() {
        // If you want to define a region of interest for AI, do it here.
        // For now, you can log the overlay frame for debugging:
        print("AI overlay frame: \(scannerOverlay.frame)")
        guard scannerOverlay.frame.width > 0 && scannerOverlay.frame.height > 0 else {
            print("⚠️ Invalid scan rect dimensions: \(scannerOverlay.frame)")
            return
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func triggerPhotoCapture() {
        if captureSession.isRunning {
            capturePhoto()
        } else {
            print("⚠️ Tried to capture photo but session is not running")
        }
    }
}

extension AIFoodScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // ... code that calls AINetworkService.shared.analyzeMealImage(image)
    }
}

extension AIFoodScannerViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Photo capture error: \(error.localizedDescription)")
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ Could not get image data from photo")
            return
        }
        print("📸 Photo captured successfully")
        DispatchQueue.main.async { [weak self] in
            self?.onPhotoCaptured?(image)
        }
    }
} 
