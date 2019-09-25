//
//  SettingsButtonInteractionExtension.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/21/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit
import Fritz

extension FeatureViewController {

  func unwindFromChoosePredictor(segue: UIStoryboardSegue) {
    if let modelConfigViewController =
      segue.source as? ConfigureFeaturePopoverViewController {
      // Add options to feature regardless if it's changed or not.
      guard let newFeatureDetails =
        modelConfigViewController.modelGroup.selectedPredictorDetails else { return }

      guard let feature = feature else {
        self.feature = build(newFeatureDetails)
        updateDebugImage()
        return
      }

      if !feature.predictorDetails.isSamePredictor(newFeatureDetails) {
        self.feature = build(newFeatureDetails)
        updateDebugImage()
        return
      }
      feature.predictorDetails.options = newFeatureDetails.options
      updateDebugImage()
    }
  }

}
