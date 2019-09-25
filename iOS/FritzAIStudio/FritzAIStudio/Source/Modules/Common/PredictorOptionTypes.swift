//
//  ConfigurableOptionType.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/24/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation


public typealias ConfigurableOptions = [PredictorOptionTypes:PredictorOption]

/// Various Model Configuration parameters.
public enum PredictorOptionTypes {
  // These are global to all models, if you want to add a new one, just add a new case here.
  case minThreshold
  case maxThreshold
  case alpha
  case modelResolution
  case numPoses
  case minPoseThreshold
  case minPartThreshold
  case color
  case interpolationQuality
  case blendingMode
  case boundingBoxes
  case opacity

  func getName() -> String{
    switch self {
    case .minThreshold: return "Min Threshold"
    case .maxThreshold: return "Max Threshold"
    case .alpha: return "Alpha"
    case .modelResolution: return "Model Resolution"
    case .numPoses: return "Number of Poses"
    case .minPartThreshold: return "Min Part Threshold"
    case .minPoseThreshold: return "Min pose Threshold"
    case .color: return "Color"
    case .interpolationQuality: return "Interpolation Quality"
    case .blendingMode: return "Blending Mode"
    case .boundingBoxes: return "Bounding Boxes"
    case .opacity: return "Opacity"
    }
  }
}
