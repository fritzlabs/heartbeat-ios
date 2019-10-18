import Foundation
import UIKit
import Fritz
import ColorSlider

protocol HairPredictor: UIViewController {

  var visionModel: FritzVisionHairSegmentationModelFast { get }
  var colorSlider: ColorSlider { get }
  var color: HairColor! { get set }
}

struct HairColor {
  var hairColor: UIColor
}

extension HairPredictor {

  func predict(with src: FritzVisionImage) -> UIImage? {
    guard let result = try? visionModel.predict(src),
      let mask = result.buildSingleClassMask(
        forClass: FritzVisionHairClass.hair,
        clippingScoresAbove: clippingScoresAbove,
        zeroingScoresBelow: zeroingScoresBelow,
        resize: false,
        color: maskColor)
      else { return nil }

    let blended = src.blend(
      withMask: mask,
      blendKernel: blendKernel,
      opacity: opacity
    )

    return blended
  }
}

extension HairPredictor {
  /// Scores output from model greater than this value will be set as 1.
  /// Lowering this value will make the mask more intense for lower confidence values.
  var clippingScoresAbove: Double { return 0.7 }

  /// Values lower than this value will not appear in the mask.
  var zeroingScoresBelow: Double { return 0.3 }

  /// Controls the opacity the mask is applied to the base image.
  var opacity: CGFloat { return 0.7 }

  /// The method used to blend the hair mask with the underlying image.
  /// Soft light produces the best results in our tests, but check out
  /// .hue and .color for different effects.
  var blendKernel: CIBlendKernel { return .softLight }

  /// Color of the mask.
  var maskColor: UIColor {
    get { return color.hairColor }
    set { color.hairColor = newValue }
  }
}

extension HairPredictor {
  
  func addColorSlider() {
    colorSlider.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(colorSlider)
    let rightEdgeConstraint = NSLayoutConstraint(
      item: colorSlider,
      attribute: .trailing,
      relatedBy: .equal,
      toItem: view,
      attribute: .trailingMargin,
      multiplier: 1.0,
      constant: 0.0)
    let centerVerticalConstraint = NSLayoutConstraint(
      item: colorSlider,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: view,
      attribute: .centerY,
      multiplier: 1.0,
      constant: 0)
    let widthConstraint = NSLayoutConstraint(
      item: colorSlider,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: 30)
    let heightConstraint = NSLayoutConstraint(
      item: colorSlider,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: 250)

    widthConstraint.isActive = true
    heightConstraint.isActive = true
    rightEdgeConstraint.isActive = true
    centerVerticalConstraint.isActive = true
  }
}
