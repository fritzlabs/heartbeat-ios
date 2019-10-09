//
//  PoseEstimation+ImagePredictor.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/23/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz

extension FritzVisionHumanPosePredictor: ImagePredictor {

  func predict(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage? {

    let poseOptions = FritzVisionPoseModelOptions()
    poseOptions.minPoseThreshold = Double((options[.minPoseThreshold] as! RangeValue).value)
    poseOptions.minPartThreshold = Double((options[.minPartThreshold] as! RangeValue).value)

    let poseResult = try predict(image, options: poseOptions)
    let numPoseOption = options[.numPoses] as? RangeValue
    let poses = poseResult.poses(limit: Int(numPoseOption!.value))
    return image.draw(poses: poses)
  }
}
