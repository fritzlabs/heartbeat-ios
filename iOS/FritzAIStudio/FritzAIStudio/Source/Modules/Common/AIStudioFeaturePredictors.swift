//
//  AIStudioFeaturePredictors.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/24/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation


enum AIStudioFeaturePredictors: String, RawRepresentable {

  case peopleSegmentation = "people_image_segmentation"
  case livingRoomSegmentation = "living_room_segmentation"
  case outdoorSegmentation = "outdoor_image_segmentation"
  case flexibleStyleTransfer = "flexible_style_transfer"
  case styleTransfer = "custom_style_transfer"
  case hairColor = "hair_color"
  case poseEstimation = "pose_estimation"
  case unknown = "unknown"

  var defaultOptions: ConfigurableOptions {
    switch self {
    case .peopleSegmentation:
      return ImageSegmentationViewController.defaultOptions
    case .livingRoomSegmentation:
      return ImageSegmentationViewController.defaultOptions
    case .outdoorSegmentation:
      return ImageSegmentationViewController.defaultOptions
    case .hairColor:
      return HairColorViewController.defaultOptions
    case .flexibleStyleTransfer:
      return FlexibleStyleTransferViewController.defaultOptions
    case .styleTransfer:
      return [:]
    case .poseEstimation:
      return PoseEstimationViewController.defaultOptions
    case .unknown:
      return [:]
    }
  }
}
