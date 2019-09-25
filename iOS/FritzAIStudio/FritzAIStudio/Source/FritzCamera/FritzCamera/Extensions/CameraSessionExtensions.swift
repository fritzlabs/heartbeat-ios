//
//  FritzCamera+Session.swift
//

import Foundation
import AVFoundation

extension FritzCamera {

  func requestVideoPermissions() {
    self.sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: .video) { success in
      if success {
        FritzLogger.notice(message: "successfully enabled video permissions")
        self.sessionQueue.resume()
        self.delegate?.cameraSetupCompleted(camera: self, result: .requiresUpdate)
      } else {
        self.delegate?.cameraSetupCompleted(camera: self, result: .videoPermissionDenied)
      }
    }
  }

  func updateOutputVideoOrientation(_ orientation: AVCaptureVideoOrientation) {
    FritzLogger.notice(message: "Updating output video orientation")
    self.sessionQueue.async {
      for output in self.session.outputs {
        guard let connection = output.connection(with: AVMediaType.video)
        else {
          continue
        }
        
        if connection.isVideoMirroringSupported, self.position == .front {
          connection.isVideoMirrored = true
        }
      }
    }
  }

  func restartVideo() {
    FritzLogger.notice(message: "restarting video feed")
    if self.session.isRunning {
      self.stop()
      updateVideo({ result in
        if result == .videoSuccess {
          self.start()
          self.delegate?.cameraRestartCompleted(camera: self, result: result)
        } else {
          self.delegate?.cameraSetupCompleted(camera: self, result: result)
        }
      })
    }
  }

  func updateVideo(_ completion: @escaping (_ result: CameraSetupResult) -> Void) {
    self.sessionQueue.async {
      self.purgeVideoDevices()
      switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
      case .authorized:
        return completion(self.videoSetupApproved())
      case .denied:
        return completion(CameraSetupResult.videoPermissionDenied)
      case .notDetermined:
        return completion(CameraSetupResult.videoRequiresAuthorization)
      case .restricted:
        return completion(CameraSetupResult.videoPermissionRestricted)
      @unknown default:
        return completion(CameraSetupResult.unknownError)
      }
    }
  }

  private func videoSetupApproved() -> CameraSetupResult {
    self.session.sessionPreset = .high // set to high here so that device input can be added to session. resolution can be checked for update later
    guard let videoInput = self.getNewVideoInputDevice() else {
      return .invalidVideoInput
    }
    if let failureResult = checkSessionValidity(for: videoInput) {
      return failureResult
    }
    self.videoInput = videoInput
    self.session.addInput(videoInput)
    self.session.addOutput(self.videoDataOutput)
    self.session.addOutput(self.photoOutput)

    self.session.commitConfiguration()

    if self.session.canSetSessionPreset(self.resolution.foundationPreset()) {
      FritzLogger.notice(message: "creating video session with resolution: \(self.resolution.rawValue)")
      self.session.sessionPreset = self.resolution.foundationPreset()
    }

    configureHiResPhotoOutput(for: self.session)
    configureFrameRate()
    return .videoSuccess
  }

  private func checkSessionValidity(for input: AVCaptureDeviceInput) -> CameraSetupResult? {
    guard self.session.canAddInput(input) else {
      FritzLogger.error(message: "cannot add video input")
      return .invalidVideoInput
    }
    guard self.session.canAddOutput(self.videoDataOutput) else {
      FritzLogger.error(message: "cannot add video data output")
      return .invalidVideoDataOutput
    }
    guard self.session.canAddOutput(self.photoOutput) else {
      FritzLogger.error(message: "cannot add photo output")
      return .invalidPhotoOutput
    }

    return nil
  }

  private func configureHiResPhotoOutput(for session: AVCaptureSession) {
    if self.captureHighResolutionImages && !self.photoOutput.isHighResolutionCaptureEnabled {
      FritzLogger.notice(message: "enabling high resolution photo capture")
      self.photoOutput.isHighResolutionCaptureEnabled = true
    } else if !self.captureHighResolutionImages {
      FritzLogger.error(message: "Disabling High Resolution Camera capture")
      self.captureHighResolutionImages = false
    }
  }

}
