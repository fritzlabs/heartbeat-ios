//
//  RootViewController.swift
//  FritzAIStudio
//
//  Created by Andrew Barba on 12/14/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        performSegue(withIdentifier: R.segue.rootViewController.toDemos, sender: self)
    }
}
