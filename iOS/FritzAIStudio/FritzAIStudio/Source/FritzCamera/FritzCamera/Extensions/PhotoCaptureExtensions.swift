//
//  PhotoCaptureExtensions.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/23/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation



extension UIImage.Orientation {
  func getCGOrientationFromUIImage() -> CGImagePropertyOrientation {
    // call on top of UIImageOrientation to obtain the corresponding CGImage orientation.
    // This is required because UIImage.imageOrientation values don't match to CGImagePropertyOrientation values
    switch self {
    case UIImageOrientation.down: return CGImagePropertyOrientation.down
    case UIImageOrientation.left: return CGImagePropertyOrientation.left
    case UIImageOrientation.right: return CGImagePropertyOrientation.right
    case UIImageOrientation.up: return CGImagePropertyOrientation.up
    case UIImageOrientation.downMirrored: return CGImagePropertyOrientation.downMirrored
    case UIImageOrientation.leftMirrored: return CGImagePropertyOrientation.leftMirrored
    case UIImageOrientation.rightMirrored: return CGImagePropertyOrientation.rightMirrored
    case UIImageOrientation.upMirrored: return CGImagePropertyOrientation.upMirrored
    @unknown default:
      return CGImagePropertyOrientation.up
    }
  }
}

extension UIDeviceOrientation {
  func getUIImageOrientationFromDevice() -> UIImage.Orientation {
    // return CGImagePropertyOrientation based on Device Orientation
    // This extented function has been determined based on experimentation with how an UIImage gets displayed.
    switch self {
    case UIDeviceOrientation.portrait, .faceUp: return UIImage.Orientation.right
    case UIDeviceOrientation.portraitUpsideDown, .faceDown: return UIImage.Orientation.left
    case UIDeviceOrientation.landscapeLeft: return UIImage.Orientation.up // this is the base orientation
    case UIDeviceOrientation.landscapeRight: return UIImage.Orientation.down
    case UIDeviceOrientation.unknown: return UIImage.Orientation.up
    @unknown default:
      return .up
    }
  }
  func getAVCaptureVideoOrientationFromDevice() -> AVCaptureVideoOrientation? {
    // return AVCaptureVideoOrientation from device
    switch self {
    case UIDeviceOrientation.portrait: return AVCaptureVideoOrientation.portrait
    case UIDeviceOrientation.portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
    case UIDeviceOrientation.landscapeLeft: return AVCaptureVideoOrientation.landscapeLeft
    case UIDeviceOrientation.landscapeRight: return AVCaptureVideoOrientation.landscapeRight
    case UIDeviceOrientation.faceDown: return AVCaptureVideoOrientation.portrait // not so sure about this one
    case UIDeviceOrientation.faceUp: return AVCaptureVideoOrientation.portrait // not so sure about this one
    case UIDeviceOrientation.unknown: return nil
    @unknown default:
      return nil
    }
  }
}


extension FritzCamera {
  func captureStillImage() {

    FritzLogger.info(message: "Attempting photo capture")

    let settings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
    settings.isAutoStillImageStabilizationEnabled = true

    if self.captureHighResolutionImages {
      settings.isHighResolutionPhotoEnabled = true
    }
    self.photoOutput.capturePhoto(with: settings, delegate: self)
  }
}
