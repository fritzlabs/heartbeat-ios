//
//  FritzVisionCameraDelegate.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/20/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz


protocol FritzCameraControllerDelegate: class {

  /// Processes image from camera.
  func processImage(_ image: FritzVisionImage?) throws -> UIImage?

}
