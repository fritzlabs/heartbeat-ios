//
//  DebugImageExtensions.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/26/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz

extension FritzCameraViewController {

  func updateDebugImage() {
    if debugImageEnabled, let debugImage = debugImage, let camera = camera {
      let fritzImage = FritzVisionImage(image: debugImage)
      self.capture(camera, didCaptureFritzImage: fritzImage, timestamp: Date())
      self.textPrompt = ""
    }
  }
}
