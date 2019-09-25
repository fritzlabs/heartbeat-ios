//
//  CameraViewController+CameraDelegate.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/20/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz



extension FritzCameraViewController: FritzCameraDelegate {

  func capture(_ cameraSession: FritzCamera, didCaptureFritzImage image: FritzVisionImage?, timestamp: Date) {
    let outputImage = try? delegate?.processImage(image)

    var backgroundImage: UIImage?
    if streamBackgroundImage, let rotatedImage = image?.rotate() {
      backgroundImage = UIImage(pixelBuffer: rotatedImage)
    }

    DispatchQueue.main.async {
      self.cameraView.image = outputImage
      if self.streamBackgroundImage {
        self.backgroundView.image = backgroundImage
      }
    }
  }

  func processPhoto(_ cameraSession: FritzCamera, didCaptureFritzImage image: FritzVisionImage?, timestamp: Date) throws -> UIImage? {
    return try delegate?.processImage(image)
  }

  func cameraSetupCompleted(camera: FritzCamera, result: CameraSetupResult) {
    handleCameraSetupResult(result)
  }

  func cameraRestartCompleted(camera: FritzCamera, result: CameraSetupResult) {
    DispatchQueue.main.async {
      self.updateUI(orientation: UIApplication.shared.statusBarOrientation)
    }
  }

  func finishedFocus(camera: FritzCamera) {
    DispatchQueue.main.async {
      self.isUpdating = false
    }
  }
}
