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


extension FritzVisionStyleModel: ImagePredictor {
  func predict(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage? {

    let options = FritzVisionStyleModelOptions()

    let buffer = try predict(image, options: options)
    return UIImage(pixelBuffer: buffer)
  }
}


class StyleTransferViewController: FeatureViewController {

  enum StyleModels: String, RawRepresentable, CaseIterable {
    case customStyleTransfer = "custom_style_transfer"
    // Generally the raw
    case starryNight
    case pinkBlueRhombus
    case theScream
    case bicentennialPrint
    case poppyField
    case kaleidoscope
    case femmes
    case headOfClown
    case horsesOnSeashore
    case theTrial
    case ritmoPlastico
  }

  override var debugImage: UIImage? { return UIImage(named: "styleTransferBoston.jpg") }

  override func build(_ predictorDetails: FritzModelDetails) -> AIStudioImagePredictor? {

    guard let modelType = StyleModels(rawValue: predictorDetails.featureName),
      let model = predictorDetails.managedModel.loadModel()
      else { return nil }

    switch modelType {
    case .customStyleTransfer:
      if let model = try? FritzVisionStyleModel(model: model) {
        return AIStudioImagePredictor(model: model, predictorDetails: predictorDetails)
      }
      return nil
    default:
      // A bit of a hacky way to get the prepackaged models.
      if let model = FritzVisionStyleModel.value(forKey: modelType.rawValue) as? FritzVisionStyleModel {
        return AIStudioImagePredictor(model: model, predictorDetails: predictorDetails)
      }
      return nil
    }
  }

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

    return ModelGroupManager(with: models, initialModel: models[0], tagName: "aistudio-ios-style-transfer")
  }

  convenience init() {
    let group = StyleTransferViewController.buildModelGroup()

    self.init(modelGroup: group, title: "Style Transfer")

    self.position = .front
    self.streamBackgroundImage = false
    self.resolution = .vga640x480
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    gestureRecognizer.numberOfTapsRequired = 2
    view.addGestureRecognizer(gestureRecognizer)
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
