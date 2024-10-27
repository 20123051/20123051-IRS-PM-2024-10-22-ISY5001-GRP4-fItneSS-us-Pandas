//
//  CameraView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//


import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @EnvironmentObject var appState: AppState
    class Coordinator: NSObject {
        var parent: CameraView
        var captureSession: AVCaptureSession?

        init(parent: CameraView) {
            self.parent = parent
            super.init()
            setupCaptureSession()  // Set up the capture session in the initializer
        }

        func setupCaptureSession() {
            captureSession = AVCaptureSession()

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("Failed to get the camera device")
                return
            }

            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

                if captureSession?.canAddInput(videoDeviceInput) == true {
                    captureSession?.addInput(videoDeviceInput)
                }

                let videoOutput = AVCaptureVideoDataOutput()
                if captureSession?.canAddOutput(videoOutput) == true {
                    captureSession?.addOutput(videoOutput)
                }

                captureSession?.startRunning()

            } catch {
                print("Error setting up the camera: \(error.localizedDescription)")
            }
        }
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        if let captureSession = context.coordinator.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates required for the camera view in this example
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
