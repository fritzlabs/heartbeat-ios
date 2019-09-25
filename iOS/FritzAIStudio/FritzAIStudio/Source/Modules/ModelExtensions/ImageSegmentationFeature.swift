//
//  ImageSegmentationFeature.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/22/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz



extension FritzVisionSegmentationModel: ImagePredictor {

  private func predictSingleClass(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage? {

    let mask = try self.predict(image)

    let color = (options[.color] as! ColorSliderValue).color
    let minThreshold = Double((options[.minThreshold] as! RangeValue).value)
    let maxThreshold = Double((options[.maxThreshold] as! RangeValue).value)

    return mask.buildSingleClassMask(
      forClass: FritzVisionHairSegmentationClass.hair,
      clippingScoresAbove: maxThreshold,
      zeroingScoresBelow: minThreshold,
      maxAlpha: 255,
      resize: false,
      color: color)
  }

  func predict(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage? {

    // color option is only an option in the hair color view for now.
    if options[PredictorOptionTypes.color] != nil {
      return try predictSingleClass(image, options: options)
    }

    let mask = try self.predict(image)

    let minThreshold = Double((options[.minThreshold] as! RangeValue).value)
    let alpha = UInt8((options[.alpha] as! RangeValue).value)

    return mask.buildMultiClassMask(
      withMinimumAcceptedScore: minThreshold,
      maxAlpha: alpha,
      resize: true)
  }
}


