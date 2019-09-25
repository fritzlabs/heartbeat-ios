//
//  FeatureViewController.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//


import UIKit
import AVFoundation
import Fritz


class FeatureViewController: FritzCameraViewController, FritzCameraControllerDelegate {

  let modelGroup: ModelGroupManager

  var feature: AIStudioImagePredictor?

  let navTitle: String

  public init(modelGroup: ModelGroupManager, title: String) {
    self.modelGroup = modelGroup
    self.navTitle = title
    super.init()

    self.delegate = self
    self.modelGroup.fetchModels()

    setCancelButton(visible: false)

    if let selectedModel = modelGroup.selectedPredictorDetails {
      self.feature = build(selectedModel)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    self.modelGroup = ModelGroupManager()
    self.navTitle = ""
    super.init(coder: aDecoder)
  }

  open func build(_ predictorDetails: FritzModelDetails) -> AIStudioImagePredictor? {
    return nil
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.updateNavBar()
    updateDebugImage()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }


  @IBAction func unwindWithUpdate(segue: UIStoryboardSegue) {
    unwindFromChoosePredictor(segue: segue)
  }

  @IBAction func unwindWithCancel(segue: UIStoryboardSegue) { }

  open func processImage(_ image: FritzVisionImage?) throws -> UIImage? {
    return try self.feature?.processImage(image)
  }

}
