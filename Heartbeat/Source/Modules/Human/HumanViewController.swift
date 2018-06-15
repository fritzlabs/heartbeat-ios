//
//  HumanViewController.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/6/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import Vision

class HumanViewController: UIViewController {

    @IBOutlet weak var resultView: UIView! {
        didSet { resultView.layer.cornerRadius = 4 }
    }

    @IBOutlet weak var genderLabel: UILabel! {
        didSet { genderLabel.text = "..." }
    }

    @IBOutlet weak var ageLabel: UILabel! {
        didSet { ageLabel.text = "..." }
    }

    private lazy var cameraSession = AVCaptureSession()

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: cameraSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()

    private let ageModel = AgeNet().fritz().model

    private let genderModel = GenderNet().fritz().model

    private lazy var ageRequest: VNCoreMLRequest = {
        let vnModel = try! VNCoreMLModel(for: ageModel)
        let request = VNCoreMLRequest(model: vnModel) { [unowned self] in
            self.handleAgeRequestUpdate(request: $0, error: $1)
        }
        request.imageCropAndScaleOption = .centerCrop
        return request
    }()

    private lazy var genderRequest: VNCoreMLRequest = {
        let vnModel = try! VNCoreMLModel(for: genderModel)
        let request = VNCoreMLRequest(model: vnModel) { [unowned self] in
            self.handleGenderRequestUpdate(request: $0, error: $1)
        }
        request.imageCropAndScaleOption = .centerCrop
        return request
    }()

    private lazy var faceRequest: VNDetectFaceLandmarksRequest = {
        let request = VNDetectFaceLandmarksRequest() { [unowned self] in
            self.handleFaceRequestUpdate(request: $0, error: $1)
        }
        return request
    }()

    private lazy var imageRequests: [VNImageBasedRequest] = [ageRequest, genderRequest, faceRequest]

    private let sessionQueue = DispatchQueue(label: "com.fritz.heartbeat.human.session", attributes: .concurrent)

    private let captureQueue = DispatchQueue(label: "com.fritz.heartbeat.human.capture", attributes: .concurrent)

    private var maskLayer: [CAShapeLayer] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), let input = try? AVCaptureDeviceInput(device: device) else { return }

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
            alongsideTransition: { _ in
                self.previewLayer.frame = CGRect(origin: .zero, size: size)
            },
            completion: nil
        )
    }
}

extension HumanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        connection.videoOrientation = .portrait
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        var options: [VNImageOption : Any] = [:]

        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            options = [.cameraIntrinsics : cameraIntrinsicData]
        }

        for request in imageRequests {
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: options)
            try? requestHandler.perform([request])
        }
    }

    private func handleAgeRequestUpdate(request: VNRequest, error: Error?) {
        guard let observation = request.results?.first as? VNClassificationObservation else { return }
        DispatchQueue.main.async {
            self.ageLabel.text = observation.identifier.capitalized
        }
    }

    private func handleGenderRequestUpdate(request: VNRequest, error: Error?) {
        guard let observation = request.results?.first as? VNClassificationObservation else { return }
        DispatchQueue.main.async {
            self.genderLabel.text = observation.identifier.capitalized
        }
    }

    private func handleFaceRequestUpdate(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNFaceObservation] else { return }
        DispatchQueue.main.async {
            self.removeMask()
            for face in results {
                self.drawFaceWithLandmarks(face: face)
            }
        }
    }
}

extension HumanViewController {

    // Create a new layer drawing the bounding box
    private func createLayer(in rect: CGRect) -> CAShapeLayer{

        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 0.75
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 2.0

        maskLayer.append(mask)
        previewLayer.insertSublayer(mask, at: 1)

        return mask
    }

    func drawFaceWithLandmarks(face: VNFaceObservation) {
        let frame = previewLayer.frame

        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)

        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)

        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        let facebounds = face.boundingBox.applying(translate).applying(transform)

        // Draw the bounding rect
        let faceLayer = createLayer(in: facebounds)

        // Draw the landmarks
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.nose)!, isClosed:false)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.noseCrest)!, isClosed:false)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.medianLine)!, isClosed:false)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftEye)!)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftPupil)!)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftEyebrow)!, isClosed:false)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEye)!)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightPupil)!)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEye)!)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEyebrow)!, isClosed:false)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.innerLips)!)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.outerLips)!)
        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.faceContour)!, isClosed: false)
    }



    func drawLandmarks(on targetLayer: CALayer, faceLandmarkRegion: VNFaceLandmarkRegion2D, isClosed: Bool = true) {
        let rect: CGRect = targetLayer.frame
        var points: [CGPoint] = []

        for i in 0..<faceLandmarkRegion.pointCount {
            let point = faceLandmarkRegion.normalizedPoints[i]
            points.append(point)
        }

        let landmarkLayer = drawPointsOnLayer(rect: rect, landmarkPoints: points, isClosed: isClosed)

        // Change scale, coordinate systems, and mirroring
        landmarkLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform.identity
                .scaledBy(x: rect.width, y: -rect.height)
                .translatedBy(x: 0, y: -1)
        )

        targetLayer.insertSublayer(landmarkLayer, at: 1)
    }

    func drawPointsOnLayer(rect:CGRect, landmarkPoints: [CGPoint], isClosed: Bool = true) -> CALayer {
        let linePath = UIBezierPath()
        linePath.move(to: landmarkPoints.first!)

        for point in landmarkPoints.dropFirst() {
            linePath.addLine(to: point)
        }

        if isClosed {
            linePath.addLine(to: landmarkPoints.first!)
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = nil
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = UIColor.green.cgColor
        lineLayer.lineWidth = 0.02

        return lineLayer
    }

    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
}
