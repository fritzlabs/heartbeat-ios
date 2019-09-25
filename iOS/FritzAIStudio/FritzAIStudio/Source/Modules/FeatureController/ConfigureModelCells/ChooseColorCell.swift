//
//  RangeSliderCell.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit
import ColorSlider

class ChooseColorCell: UITableViewCell {

  @IBOutlet weak var sliderView: UIView!
  
  @objc func valueChanged(_ sender: UISegmentedControl) {
    value.color = colorSlider.color
    delegate?.update(value)
  }

  var _colorSlider: ColorSlider?
  var colorSlider: ColorSlider {
    if let slider = _colorSlider {
      return slider
    }
    let slider = ColorSlider(orientation: .horizontal, previewSide: .top)
    _colorSlider = slider
    slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)

    return slider
  }

  weak var delegate: FeatureOptionCellDelegate?

  var name: String!

  var value: ColorSliderValue!

  func initColorSlider(_ colorSliderValue: ColorSliderValue) {
    self.value = colorSliderValue
    self.colorSlider.color = colorSliderValue.color
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    colorSlider.frame = bounds
  }

  override func awakeFromNib() {
    addSubview(colorSlider)
  }

  static var identifier: String {
    return String(describing: self)
  }

  static var nib: UINib {
    return UINib(nibName: identifier, bundle: nil)
  }
}

