//
//  HairColor+ColorSlider.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/25/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit
import ColorSlider


extension HairColorViewController {

  @objc func updateColor(_ slider: ColorSlider) {
    let color = slider.color
    guard let feature = feature else { return }
    var sliderValue = feature.predictorDetails.options[.color] as! ColorSliderValue
    sliderValue.color = color
    feature.predictorDetails.options[.color] = sliderValue
  }

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
