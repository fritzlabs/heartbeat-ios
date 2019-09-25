//
//  CaptureDeviceHandlerExtension.swift
//  Lumina
//
//  Created by David Okun on 11/20/17.
//  Copyright © 2017 David Okun. All rights reserved.
//

import Foundation
import AVFoundation

extension FritzCamera {
  func getNewVideoInputDevice() -> AVCaptureDeviceInput? {
    do {
      guard let device = getDevice(with: self.position == .front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back) else {
        // LuminaLogger.error(message: "could not find valid AVCaptureDevice")
        return nil
      }
      let input = try AVCaptureDeviceInput(device: device)
      return input
    } catch {
      return nil
    }
  }

  func purgeVideoDevices() {
    FritzLogger.notice(message: "purging old video devices on capture session")
    for oldInput in self.session.inputs where oldInput == self.videoInput {
      self.session.removeInput(oldInput)
    }
    for oldOutput in self.session.outputs {
      if oldOutput == self.videoDataOutput || oldOutput == self.photoOutput  {
        self.session.removeOutput(oldOutput)
      }
      if let dataOutput = oldOutput as? AVCaptureVideoDataOutput {
        self.session.removeOutput(dataOutput)
      }
    }
  }

  func getDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
      self.currentCaptureDevice = device
      return device
    } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
      self.currentCaptureDevice = device
      return device
    }
    return nil
  }

  func configureFrameRate() {
    guard let device = self.currentCaptureDevice else {
      return
    }
    for vFormat in device.formats {
      let dimensions = CMVideoFormatDescriptionGetDimensions(vFormat.formatDescription)
      let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
      guard let frameRate = ranges.first else {
        continue
      }
      if frameRate.maxFrameRate >= Float64(self.frameRate) &&
        frameRate.minFrameRate <= Float64(self.frameRate) &&
        self.resolution.getDimensions().width == dimensions.width &&
        self.resolution.getDimensions().height == dimensions.height &&
        CMFormatDescriptionGetMediaSubType(vFormat.formatDescription) == 875704422 { // meant for full range 420f
        do {
          try device.lockForConfiguration()
          device.activeFormat = vFormat as AVCaptureDevice.Format
          device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(self.frameRate))
          device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(self.frameRate))
          device.unlockForConfiguration()
          break
        } catch {
          continue
        }
      }
    }
  }
}
