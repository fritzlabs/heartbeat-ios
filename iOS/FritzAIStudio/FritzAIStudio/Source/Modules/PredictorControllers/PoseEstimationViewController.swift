//
//  ImageSegmentationViewController
//  FritzAIStudio
//
//  Created by Chris Kelly on 9/12/2018.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import Fritz
import VideoToolbox



class PoseEstimationViewController: FeatureViewController {

  static let defaultOptions: ConfigurableOptions = [
    .minPoseThreshold: RangeValue(optionType: .minPoseThreshold, min: 0.0, max: 1.0, value: 0.4, priority: 0),
    .minPartThreshold: RangeValue(optionType: .minPartThreshold, min: 0.0, max: 1.0, value: 0.4, priority: 1),
    .numPoses: RangeValue(optionType: .numPoses, min: 1.0, max: 20.0, value: 7.0, priority: 2)
  ]

  override var debugImage: UIImage? {
    return UIImage(named: "pose.jpg")
  }

  override func build(_ predictorDetails: FritzModelDetails) -> AIStudioImagePredictor? {
    guard let mlmodel = predictorDetails.managedModel.loadModel()
      else { return nil }
    let poseModel = FritzVisionHumanPoseModel(model: mlmodel)

    switch predictorDetails.featureDescription {
    case .poseEstimation:
      return AIStudioImagePredictor(model: poseModel, predictorDetails: predictorDetails)
    default: return nil
    }
  }

  convenience init() {
    let managedModel = FritzVisionHumanPoseModel().managedModel
    let poseModel = FritzModelDetails(
      with: managedModel,
      featureDescription: .poseEstimation)

    let group = ModelGroupManager(initialModel: poseModel, tagName: "aistudio-ios-pose-estimation")
    self.init(modelGroup: group, title: "Pose Estimation")
  }
}
