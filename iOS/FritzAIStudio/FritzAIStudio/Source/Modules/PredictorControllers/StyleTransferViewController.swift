//
//  StyleTransferViewController.swift
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


extension FritzVisionStylePredictor: ImagePredictor {
  func predict(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage? {

    let styleOptions = FritzVisionStyleModelOptions()
    
    let value = options[.modelResolution] as! SegmentValue
    // This is a bit hacky, but we can change it if it becomes a problem
    let index = value.selectedIndex
    if index == 0 {
      styleOptions.flexibleModelDimensions = .lowResolution
    } else if index == 1 {
      styleOptions.flexibleModelDimensions = .mediumResolution
    } else if index == 2 {
      styleOptions.flexibleModelDimensions = .highResolution
    } else if index == 3 {
      styleOptions.flexibleModelDimensions = .original
    }
    
    // Resize the final image to match the input
    styleOptions.resizeOutputToInputDimensions = true
    
    // Stylize the image
    let stylizedBuffer = try predict(image, options: styleOptions)

    return UIImage(pixelBuffer: stylizedBuffer)
  }
}


class StyleTransferViewController: FeatureViewController {

  override var debugImage: UIImage? { return UIImage(named: "styleTransferBoston.jpg") }
  
  static let defaultOptions: ConfigurableOptions = [
    .modelResolution: SegmentValue(
      optionType: .modelResolution,
      options: ["Low", "Medium", "High", "original"],
      selectedIndex: 0, priority: 0
    )
  ]
  
  class func buildModelGroup() -> ModelGroupManager {
    var models: [FritzModelDetails] = []
    for paintingStyle in PaintingStyleModel.Style.allCases {
      let styleModel = paintingStyle.build()
      let fritzModel = FritzModelDetails(
        with: styleModel.managedModel,
        featureDescription: .styleTransfer,
        name: paintingStyle.name
      )
      models.append(fritzModel)
    }
    
    for patternStyle in PatternStyleModel.Style.allCases {
      let styleModel = patternStyle.build()
      let fritzModel = FritzModelDetails(
        with: styleModel.managedModel,
        featureDescription: .styleTransfer,
        name: patternStyle.name
      )
      models.append(fritzModel)
    }

    return ModelGroupManager(with: models, initialModel: models[0], tagName: nil)
  }

  convenience init() {
    let group = StyleTransferViewController.buildModelGroup()
    self.init(modelGroup: group, title: "Style Transfer")
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
    guard let model = predictorDetails.managedModel.loadModel(),
      let predictor = try? FritzVisionStylePredictor(model: model) else { return nil }
    
    return AIStudioImagePredictor(model: predictor, predictorDetails: predictorDetails)
  }
}

extension StyleTransferViewController {

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
