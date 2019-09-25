//
//  RangeSliderCell.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit

class RangeSliderCell: UITableViewCell {

    @IBOutlet var test: RangeSliderCell!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!

    weak var delegate: FeatureOptionCellDelegate?

    var name: String!
    var value: RangeValue!

    @IBAction func valueChanged(_ sender: UISlider) {
        value.value = sender.value
        delegate?.update(value)
        initLabels()
    }

    func initLabels() {
        DispatchQueue.main.async {
            self.valueSlider.minimumValue = self.value.min
            self.valueSlider.maximumValue = self.value.max
            self.valueSlider.value = self.value.value
            self.valueLabel.text = "\(self.value.value)"
        }
    }

    static var identifier: String {
        return String(describing: self)
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }


}

