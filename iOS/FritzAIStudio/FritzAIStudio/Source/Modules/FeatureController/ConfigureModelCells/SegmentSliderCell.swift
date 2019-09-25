//
//  RangeSliderCell.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit

class SegmentSliderCell: UITableViewCell {
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        value.selectedIndex = sender.selectedSegmentIndex
        delegate?.update(value)
    }
    
    @IBOutlet weak var segmentSlider: UISegmentedControl!
    weak var delegate: FeatureOptionCellDelegate?
    
    var name: String!
    var value: SegmentValue!
    
    func initSegments() {
        for (i, option) in value.options.enumerated() {
            segmentSlider.setTitle(option, forSegmentAt: i)
        }
        segmentSlider.selectedSegmentIndex = value.selectedIndex
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
}

