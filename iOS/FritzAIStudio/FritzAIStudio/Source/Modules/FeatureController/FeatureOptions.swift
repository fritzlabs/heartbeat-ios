//
//  FeatureOptions.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit

public enum CellType {
  case rangeValue
  case segmentValue
  case colorSlider
}


public protocol PredictorOption {
  static var cellType: CellType { get }
  var priority: Int { get }
  var optionType: PredictorOptionTypes { get }
}

protocol FeatureOptionCellDelegate: class {
  func update(_ value: PredictorOption)
}


/// Represent a range of values
struct RangeValue: PredictorOption {
  static let cellType: CellType = .rangeValue

  let optionType: PredictorOptionTypes
  let min: Float
  let max: Float
  var value: Float
  let priority: Int
}


/// Represent distinct values.
struct SegmentValue: PredictorOption {
  static let cellType: CellType = .segmentValue


  let optionType: PredictorOptionTypes
  let options: [String]
  var selectedIndex: Int
  let priority: Int
}


/// Represent distinct values.
struct ColorSliderValue: PredictorOption {
  static let cellType: CellType = .colorSlider

  let optionType: PredictorOptionTypes
  var color: UIColor

  let priority: Int
}


