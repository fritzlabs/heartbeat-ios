//
//  ImageLabelViewController.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 6/7/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import Firebase
import FritzVisionLabelModel
import FritzVision

class ImageLabelViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let fritzVision = FritzVisionLabelModel()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        doDetection(name: "bostonCommon")
        // doDetection(name: "Park")
    }
    lazy var vision = Vision.vision()


    func doDetection(name: String) {
        print(name)
        // set the default image
        guard let image = UIImage.init(named: name) else {
            fatalError("No default image found")
        }
        imageView.image = image
        detectImage(image: image)
        detectImageFritz(image: image)

    }

    func detectImage(image: UIImage) {

        let options = VisionLabelDetectorOptions(
            confidenceThreshold: 0.5
        )
        let labelDetector = vision.labelDetector(options: options)  // Check console for errors.
        let viImage = VisionImage(image: image)
        labelDetector.detect(in: viImage) { (labels, error) in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                // Error. You should also check the console for error messages.
                // ...
                return
            }
            print("Firebase")
            print("--------")
            for label in labels {
                print(label.label, label.confidence)
            }
        }
    }

    func detectImageFritz(image: UIImage) {
        let frImage = try! FritzVisionImage(image: image)
        let results = try! fritzVision.predict(image: frImage)
        print("Fritz Results")
        print("-------------")
        for result in results {
            if result.confidence > 0.05 {
                print(result.label, result.confidence)
            }
        }

    }
}
