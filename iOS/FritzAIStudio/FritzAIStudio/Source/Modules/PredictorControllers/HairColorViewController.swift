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
import ColorSlider

class HairColorViewController: FeatureViewController {

  /// Default options.  These are options that users can change on the feature page.
  /// When a predictor is build, it is instantiated with this option set.
  static let defaultOptions: [PredictorOptionTypes:PredictorOption] = [
    .color: ColorSliderValue(optionType: .color, color: .red, priority: 0),
    .blendingMode: SegmentValue(
      optionType: .blendingMode,
      options: ["Soft light", "Hue", "Color", "Plus Lighter"],
      selectedIndex: 0,
      priority: 1
    ),
    .alpha: RangeValue(optionType: .alpha, min: 0.0, max: 1.0, value: 0.75, priority: 2),
    .maxThreshold: RangeValue(optionType: .maxThreshold, min: 0.0, max: 1.0, value: 0.7, priority: 3),
    .minThreshold: RangeValue(optionType: .minThreshold, min: 0.0, max: 1.0, value: 0.3, priority: 4),
    .interpolationQuality: SegmentValue(
      optionType: .interpolationQuality,
      options: ["Low", "Medium", "High", "None"],
      selectedIndex: 0,
      priority: 5
    )
  ]

  var _colorSlider: ColorSlider?
  var colorSlider: ColorSlider {
    if let slider = _colorSlider {
      return slider
    }

    let slider = ColorSlider(orientation: .vertical, previewSide: .left)
    _colorSlider = slider
    slider.addTarget(self, action: #selector(updateColor(_:)), for: .valueChanged)
    return slider
  }

  override var debugImage: UIImage? { return UIImage(named: "hair1.jpg") }

  convenience init() {

    let managedModel = FritzVisionHairSegmentationModel().managedModel
    let hairSeg = FritzModelDetails(
      with: managedModel,
      featureDescription: .hairColor
    )
    let group = ModelGroupManager(initialModel: hairSeg, tagName: nil)

    self.init(modelGroup: group, title: "Hair Segmentation")

    // Configure camera options for this class.
    self.position = .front
    self.streamBackgroundImage = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addColorSlider()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let feature = feature {
      let colorOption = feature.predictorDetails.options[.color] as! ColorSliderValue
      colorSlider.color = colorOption.color
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    view.bringSubviewToFront(colorSlider)
  }

  /// Build a new instance of the image predictor.
  /// This is called when the view controller is initialized and when a new model is chosed
  /// from the settings popover.
  override func build(_ predictorDetails: FritzModelDetails) -> AIStudioImagePredictor? {
    guard let mlmodel = predictorDetails.managedModel.loadModel() else { return nil }

    switch predictorDetails.featureDescription {
    case .hairColor:
      let model = FritzVisionHairSegmentationModel(model: mlmodel)
      return AIStudioImagePredictor(model: model, predictorDetails: predictorDetails)
    default:
      return nil
    }
  }

  override func processImage(_ image: FritzVisionImage?) throws -> UIImage? {

    guard let fritzImage = image else { return nil }
    let options = feature?.predictorDetails.options ?? type(of: self).defaultOptions

    let alpha = (options[.alpha] as! RangeValue).value

    // Change blend mode
    let blend = (options[.blendingMode] as! SegmentValue).selectedIndex
    var blendingMode: CIBlendKernel
    switch blend {
    case 0: blendingMode = .softLight
    case 1: blendingMode = .hue
    case 2: blendingMode = .color
    case 3: blendingMode = .componentAdd
    default: blendingMode = .softLight
    }

    guard let mask = try? feature?.model.predict(fritzImage, options: options) else { return nil }
    guard let blended = fritzImage.blend(withMask: mask, blendKernel: blendingMode, opacity: CGFloat(alpha))
      else { return nil }

    return blended
  }
}
