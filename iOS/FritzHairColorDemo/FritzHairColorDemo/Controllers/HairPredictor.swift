import Foundation
import UIKit
import Fritz
import ColorSlider

protocol HairPredictor: UIViewController {

  var visionModel: FritzVisionHairSegmentationModelFast { get }
  var colorSlider: ColorSlider { get }
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
