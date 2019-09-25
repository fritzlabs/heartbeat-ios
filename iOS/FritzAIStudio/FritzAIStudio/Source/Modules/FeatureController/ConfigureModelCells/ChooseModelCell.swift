//
//  ChooseModelCell.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation

import UIKit

class ChooseModelCell: UITableViewCell {

    static var identifier: String {
        return String(describing: self)
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var name: String?
}
