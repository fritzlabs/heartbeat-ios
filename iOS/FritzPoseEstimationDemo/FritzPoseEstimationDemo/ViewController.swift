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

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

  var previewView: UIImageView!

  lazy var poseModel = FritzVisionHumanPoseModel()

  lazy var poseSmoother = PoseSmoother<OneEuroPointFilter, HumanSkeleton>()

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

  var minPoseThreshold: Double { return 0.4 }

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    let image = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)
    let options = FritzVisionPoseModelOptions()
    options.minPoseThreshold = minPoseThreshold

    guard let result = try? poseModel.predict(image, options: options) else {
      // If there was no pose, display original image
      displayInputImage(image)
      return
    }

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
