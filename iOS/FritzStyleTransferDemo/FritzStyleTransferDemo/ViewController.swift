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

  lazy var styleModel = PaintingStyleModel.Style.starryNight.build()

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

    // The style transfer takes a 640x480 image as input and outputs an image of the same size.
    session.sessionPreset = AVCaptureSession.Preset.vga640x480
    return session
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Add preview View as a subview
    previewView = UIImageView(frame: view.bounds)
    previewView.contentMode = .scaleAspectFill
    view.addSubview(previewView)

    let videoOutput = AVCaptureVideoDataOutput()
    // Necessary video settings for displaying pixels using the VideoPreviewView
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

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let fritzImage = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)
    guard let stylizedImage = try? styleModel.predict(fritzImage) else { return }
    let styled = UIImage(pixelBuffer: stylizedImage)
    DispatchQueue.main.async {
      self.previewView.image = styled
    }

  }
}
