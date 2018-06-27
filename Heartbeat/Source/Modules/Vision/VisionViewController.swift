//
//  VisionViewController.swift
//  Heartbeat
//
//  Created by Andrew Barba on 6/26/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import Fritz
import Vision

class VisionViewController: UIViewController {

    @IBOutlet weak var resultView: UIView! {
        didSet { resultView.layer.cornerRadius = 4 }
    }

    @IBOutlet weak var predictionLabel: UILabel! {
        didSet { predictionLabel.text = "Loading... 🚀" }
    }

    @IBOutlet weak var confidenceLabel: UILabel! {
        didSet { confidenceLabel.text = nil }
    }

    private lazy var cameraSession = AVCaptureSession()

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: cameraSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()

    private let model = FritzVisionLabelModel()

    private let sessionQueue = DispatchQueue(label: "com.fritz.heartbeat.mobilenet.session")

    private let captureQueue = DispatchQueue(label: "com.fritz.heartbeat.mobilenet.capture")

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device) else { return }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: captureQueue)

        sessionQueue.async {
            self.cameraSession.beginConfiguration()
            self.cameraSession.addInput(input)
            self.cameraSession.addOutput(output)
            self.cameraSession.commitConfiguration()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        previewLayer.frame = view.layer.bounds
        view.layer.insertSublayer(previewLayer, at: 0)

        sessionQueue.async {
            self.cameraSession.startRunning()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        previewLayer.frame = view.layer.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in self.previewLayer.frame = CGRect(origin: .zero, size: size) },
            completion: nil
        )
    }
}

extension VisionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        connection.videoOrientation = .portrait

        guard
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let results = try? model.predict(image: .init(imageBuffer: imageBuffer)),
            let result = results.first
            else { return }

        setResult(text: result.label, confidence: Int(result.confidence))
    }

    private func setResult(text: String, confidence: Int) {
        DispatchQueue.main.async {
            self.predictionLabel.text = text.capitalized
            self.confidenceLabel.text = self.confidenceString(confidence)
            self.confidenceLabel.textColor = self.confidenceColor(confidence)
        }
    }

    private func confidenceString(_ value: Int) -> String {
        return "\(value)%"
    }

    private func confidenceColor(_ value: Int) -> UIColor {
        switch value {
        case ...33: return .red
        case 34...66: return .orange
        default: return .green
        }
    }
}
