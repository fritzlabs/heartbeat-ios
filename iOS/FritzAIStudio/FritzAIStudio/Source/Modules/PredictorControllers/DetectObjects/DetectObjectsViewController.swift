//
//  DetectObjectsViewController.swift
//

import UIKit
import CoreML
import Vision
import AVFoundation
import Accelerate
import Fritz

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

class DetectObjectsViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var frameLabel: UILabel!
    var lastExecution = Date()
    var screenHeight: Double?
    var screenWidth: Double?

    let visionModel = FritzVisionObjectModel()

    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()

        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        return session
    }()

    let numBoxes = 100
    var boundingBoxes: [BoundingBoxOutline] = []
    let multiClass = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        self.cameraView?.bringSubviewToFront(self.frameLabel)
        self.frameLabel.textAlignment = .left
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        setupBoxes()
        screenWidth = Double(view.frame.width)
        screenHeight = Double(view.frame.height)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraLayer.frame = cameraView.layer.bounds
    }

    func setupBoxes() {
        // Create shape layers for the bounding boxes.
        for _ in 0..<numBoxes {
            let box = BoundingBoxOutline()
            box.addToLayer(cameraView.layer)
            self.boundingBoxes.append(box)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func drawBoxes(predictions: [FritzVisionObject], framesPerSecond: Double) {
        self.frameLabel.text = "FPS: \(framesPerSecond.format(f: ".3"))"

        for (index, prediction) in predictions.enumerated() {
            let textLabel = String(format: "%.2f - %@", prediction.confidence, prediction.label)

            // Effectively center cropping the bounding box frame.
            let height = Double(cameraView.frame.height)
            let width = Double(cameraView.frame.width)
            let yOffset = (height - width) / 2

            let box = prediction.boundingBox
            let rect = box.toCGRect(imgHeight: width, imgWidth: width, xOffset: 0.0, yOffset: yOffset)
            self.boundingBoxes[index].show(frame: rect,
                                           label: textLabel,
                                           color: UIColor.red, textColor: UIColor.black)
        }

        for index in predictions.count..<self.numBoxes {
            self.boundingBoxes[index].hide()
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let options = FritzVisionObjectModelOptions()
        options.imageCropAndScaleOption = .centerCrop
        options.threshold = 0.5

        let image = FritzVisionImage(buffer: sampleBuffer)
        image.metadata = FritzVisionImageMetadata()
        image.metadata?.orientation = FritzImageOrientation(from: connection)

        visionModel.predict(image, options: options) { objects, error in
            if let objects = objects, objects.count > 0 {
                let thisExecution = Date()
                let executionTime = thisExecution.timeIntervalSince(self.lastExecution)
                let framesPerSecond:Double = 1/executionTime
                self.lastExecution = thisExecution

                DispatchQueue.main.async {
                    self.drawBoxes(predictions: objects, framesPerSecond: framesPerSecond)

                }
            }
        }
    }
}

