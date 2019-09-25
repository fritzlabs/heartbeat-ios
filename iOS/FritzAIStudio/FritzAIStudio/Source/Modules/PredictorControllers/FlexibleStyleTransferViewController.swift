//
//  FlexibleStyleTransferViewController.swift
//  FritzAIStudio
//
//  Created by Jameson Toole on 6/8/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Vision
import CoreML
import Fritz


extension kaleidoscope_512x512_a025_stable_flexible: SwiftIdentifiedModel {
  static let modelIdentifier = "8c07e18043b547748150356b4faae7e1"
  static let packagedModelVersion = 1
}


extension FritzVisionFlexibleStyleModel: ImagePredictor {
  func predict(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage? {

    let value = options[.modelResolution] as! SegmentValue
    // This is a bit hacky, but we can change it if it becomes a problem
    let index = value.selectedIndex
    let styleOptions = FritzVisionFlexibleStyleModelOptions()
    if index == 0 {
      styleOptions.flexibleModelDimensions = .lowResolution
    } else if index == 1 {
      styleOptions.flexibleModelDimensions = .mediumResolution
    } else if index == 2 {
      styleOptions.flexibleModelDimensions = .highResolution
    } else if index == 3 {
      styleOptions.flexibleModelDimensions = .original
    }

    let stylizedBuffer = try predict(image, options: styleOptions)
    let originalSize = image.size
    guard let resized = resizePixelBuffer(stylizedBuffer, width: Int(originalSize.width) , height: Int(originalSize.height)) else { return nil }

    return UIImage(pixelBuffer: resized)
  }
}


class FlexibleStyleTransferViewController: FeatureViewController {

  override var debugImage: UIImage? { return UIImage(named: "styleTransferBoston.jpg") }
  
  static let defaultOptions: ConfigurableOptions = [
    .modelResolution: SegmentValue(
      optionType: .modelResolution,
      options: ["Low", "Medium", "High", "original"],
      selectedIndex: 1, priority: 0
    )
  ]

  convenience init() {
    let managedModel = FritzManagedModel(identifiedModelType: kaleidoscope_512x512_a025_stable_flexible.self)
    let details = FritzModelDetails(
      with: managedModel,
      featureDescription: .flexibleStyleTransfer,
      name: "Kaleidoscope"
    )
    let group = ModelGroupManager(initialModel: details, tagName: "aistudio-ios-flexible-style-transfer")
    self.init(modelGroup: group, title: "Flexible Style Transfer")
    self.position = .front
    self.resolution = .high1920x1080
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    gestureRecognizer.numberOfTapsRequired = 2
    view.addGestureRecognizer(gestureRecognizer)
  }

  override func build(_ predictorDetails: FritzModelDetails) -> AIStudioImagePredictor? {
    guard let model = predictorDetails.managedModel.loadModel() else { return nil }

    if let predictor = try? FritzVisionFlexibleStyleModel(model: model) {
      return AIStudioImagePredictor(model: predictor, predictorDetails: predictorDetails)
    }
    return nil
  }
}

extension FlexibleStyleTransferViewController {

  @objc func doubleTapped() {
    activateNextStyle()
  }

  func updateFeature(_ fritzModel: FritzModelDetails) {
    if let feature = build(fritzModel) {
      self.feature = feature
      self.streamBackgroundImage = false
    }
  }

  func activateNextStyle() {
    let allModels = modelGroup.models

    // No index, choose first one,
    guard let selectedModel = modelGroup.selectedPredictorDetails,
      let index = allModels.firstIndex(of: selectedModel),
      index != allModels.count - 1 else {
        // If there is not a selected model, or the model is the last
        // model, start at the beginining. Ideally, we would show the plain
        // image, but there is a small still untraced bug in the FritzCameraViewController blocking that.
        let newModel = modelGroup.models[0]
        // Model is the same model that is already loaded.
        if newModel == modelGroup.selectedPredictorDetails {
          return
        }
        modelGroup.selectedPredictorDetails = newModel
        updateFeature(newModel)
        return
    }

    // Normal model, just take the next one
    let nextModel = allModels[index + 1]
    modelGroup.selectedPredictorDetails = nextModel
    updateFeature(nextModel)
  }
}
