//
//  FritzCamera.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/20/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation
import Fritz


protocol FritzCameraDelegate: class {

  func capture(_ cameraSession: FritzCamera, didCaptureFritzImage image: FritzVisionImage?, timestamp: Date)

  func processPhoto(_ cameraSession: FritzCamera, didCaptureFritzImage image: FritzVisionImage?, timestamp: Date) throws -> UIImage?

  func cameraSetupCompleted(camera: FritzCamera, result: CameraSetupResult)

  func cameraRestartCompleted(camera: FritzCamera, result: CameraSetupResult)

  func finishedFocus(camera: FritzCamera)
}


enum CameraSetupResult: String {
  typealias RawValue = String
  case videoPermissionDenied = "Video Permissions Denied"
  case videoPermissionRestricted = "Video Permissions Restricted"
  case videoRequiresAuthorization = "Video Permissions Require Authorization"
  case unknownError = "Unknown Error"
  case invalidVideoDataOutput = "Invalid Video Data Output"
  case invalidPhotoOutput = "Invalid Photo Output"
  case invalidVideoInput = "Invalid Video Input"
  case requiresUpdate = "Requires AV Update"
  case videoSuccess = "Video Setup Success"
}

final class FritzCamera: NSObject {

  weak var delegate: FritzCameraDelegate?

  var captureHighResolutionImages = true {
    didSet {
      restartVideo()
    }
  }

  var position: AVCaptureDevice.Position = .back {
    didSet {
      restartVideo()
    }
  }

  var resolution: CameraResolution = .photo {
    didSet {
      restartVideo()
    }
  }

  var frameRate: Int = 30 {
    didSet {
      restartVideo()
    }
  }

  var session = AVCaptureSession()

  fileprivate var discoverySession: AVCaptureDevice.DiscoverySession? {
    var deviceTypes = [AVCaptureDevice.DeviceType]()
    deviceTypes.append(.builtInWideAngleCamera)
    deviceTypes.append(.builtInDualCamera)
    return AVCaptureDevice.DiscoverySession(
      deviceTypes: deviceTypes,
      mediaType: AVMediaType.video,
      position: AVCaptureDevice.Position.unspecified)
  }

  var videoInput: AVCaptureDeviceInput?
  var currentCaptureDevice: AVCaptureDevice?
  var videoBufferQueue = DispatchQueue(label: "ai.fritz.videoBufferQueue", attributes: .concurrent)
  var sessionQueue = DispatchQueue(label: "ai.fritz.sessionQueue")

  // private var _videoDataOutput: AVCaptureVideoDataOutput?
  var videoDataOutput: AVCaptureVideoDataOutput {
    let output = AVCaptureVideoDataOutput()
    output.alwaysDiscardsLateVideoFrames = true
    output.setSampleBufferDelegate(self, queue: videoBufferQueue)
    // Core ML requires 32BGRA or 32RGBA
    output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
    return output
  }
  
  var photoOutput = AVCapturePhotoOutput()

  func start() {
    FritzLogger.notice(message: "starting capture session")
    self.sessionQueue.async {
      self.session.startRunning()
    }
  }

  func stop() {
    FritzLogger.notice(message: "stopping capture session")
    self.sessionQueue.async {
      self.session.stopRunning()
    }
  }
}
