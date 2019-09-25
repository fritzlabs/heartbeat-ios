//
//  AIStudioImagePredictor.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz



class AIStudioImagePredictor {

  let model: ImagePredictor

  let predictorDetails: FritzModelDetails

  init(model: ImagePredictor, predictorDetails: FritzModelDetails) {
    self.model = model
    self.predictorDetails = predictorDetails
  }
}

extension AIStudioImagePredictor: FritzCameraControllerDelegate {

  public func processImage(_ image: FritzVisionImage?) throws -> UIImage? {
    guard let image = image else { return nil }
    return try self.model.predict(image, options: predictorDetails.options)
  }
  
}

