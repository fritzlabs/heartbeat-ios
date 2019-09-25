//
//  ViewControllerButtonFunctions.swift
//  Lumina
//
//  Created by David Okun on 11/20/17.
//  Copyright © 2017 David Okun. All rights reserved.
//

import Foundation
import UIKit

extension FritzCameraViewController {
  @objc func cancelButtonTapped() {
    FritzLogger.notice(message: "cancel button tapped")
    dismiss(animated: true)
  }

  @objc func shutterButtonTapped() {
    FritzLogger.notice(message: "shutter button tapped")
    shutterButton.takePhoto()
    cameraView.layer.opacity = 0
    backgroundView.layer.opacity = 0

    UIView.animate(withDuration: 0.25) {
      self.cameraView.layer.opacity = 1
      self.backgroundView.layer.opacity = 1
    }
    guard self.camera != nil else {
      return
    }
    self.camera?.captureStillImage()
  }


  @objc func switchButtonTapped() {
    FritzLogger.notice(message: "camera switch button tapped")
    switch self.position {
    case .back:
      self.position = .front
    default:
      self.position = .back
    }
  }
}
