//
//  ViewController.swift
//  FritzStyleTransferDemo
//
//  Created by Christopher Kelly on 9/12/18.
//  Copyright © 2018 Fritz. All rights reserved.
//

import UIKit
import Photos
import Fritz


extension Double {
  func format(f: String) -> String {
    return String(format: "%\(f)f", self)
  }
}


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

  var previewView: UIImageView!
  @IBOutlet weak var fpsLabel: UILabel!
  @IBOutlet weak var modelIdLabel: UILabel!
  @IBOutlet weak var modelVersionLabel: UILabel!
  
  var lastExecution = Date()

  // Use a pre-trained human pose estimation model from Fritz AI.
  lazy var poseModel = FritzVisionHumanPoseModelFast()
  // To use your own pose estimation model, following instructions here:
  // https://docs.fritz.ai/develop/vision/pose-estimation/custom-pose-estimation/ios.html

  lazy var poseSmoother = PoseSmoother<OneEuroPointFilter, HumanSkeleton>()
  
  // Confidence thresholds define the minimum threshold required to show a pose (i.e. an entire skeleton)
  // as well as the minimum threshold to include a part (i.e. an arm) in a given pose.
  let minPoseThreshold = 0.4
  let minPartThreshold = 0.5

  private lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()

    guard
      let backCamera = AVCaptureDevice.default(
          .builtInWideAngleCamera,
        for: .video,
        position: .back),
      let input = try? AVCaptureDeviceInput(device: backCamera)
      else { return session }
    session.addInput(input)

    session.sessionPreset = .photo
    return session
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Add preview View as a subview
    previewView = UIImageView(frame: view.bounds)
    previewView.contentMode = .scaleAspectFill
    view.addSubview(previewView)
    view.bringSubviewToFront(fpsLabel)
    view.bringSubviewToFront(modelIdLabel)
    view.bringSubviewToFront(modelVersionLabel)
    fpsLabel.textAlignment = .center
    modelIdLabel.textAlignment = .center
    modelVersionLabel.textAlignment = .center

    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
    self.captureSession.addOutput(videoOutput)
    self.captureSession.startRunning()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    previewView.frame = view.bounds
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func displayInputImage(_ image: FritzVisionImage) {
    guard let rotated = image.rotate() else { return }

    let image = UIImage(pixelBuffer: rotated)
    DispatchQueue.main.async {
      self.previewView.image = image
    }
  }
  
  func updateLabels() {
    let thisExecution = Date()
    let executionTime = thisExecution.timeIntervalSince(self.lastExecution)
    let framesPerSecond: Double = 1 / executionTime
    self.lastExecution = thisExecution
    
    DispatchQueue.main.async {
      self.fpsLabel.text = "FPS: \(framesPerSecond.format(f: ".3"))"
      self.modelIdLabel.text = "Model ID: \(self.poseModel.managedModel.activeModelConfig.identifier)"
      self.modelVersionLabel.text = "Active Version: \(self.poseModel.managedModel.activeModelConfig.version)"
    }
  }

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    let image = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)
    let options = FritzVisionPoseModelOptions()
    options.minPoseThreshold = minPoseThreshold
    options.minPartThreshold = minPartThreshold

    guard let result = try? poseModel.predict(image, options: options) else {
      // If there was no pose, display original image
      displayInputImage(image)
      return
    }
    
    updateLabels()

    guard let pose = result.pose() else {
      displayInputImage(image)
      return
    }

    // Uncomment to use pose smoothing to smoothe output of model.
    // Will increase lag of pose a bit.
    // pose = poseSmoother.smoothe(pose)

    guard let poseResult = image.draw(pose: pose) else {
      displayInputImage(image)
      return
    }

    DispatchQueue.main.async {
      self.previewView.image = poseResult
    }
  }
}
