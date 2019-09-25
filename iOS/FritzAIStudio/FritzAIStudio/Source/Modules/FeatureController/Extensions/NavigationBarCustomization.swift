//
//  NavigationBarCustomization.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/24/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit

extension FeatureViewController {

  func updateNavBar() {
    let settingsButton = UIImage(named: "SettingsIcon")
    let settingsItem = UIBarButtonItem(
      image: settingsButton,
      style: .plain,
      target: self,
      action: #selector(settingsButtonTapped(_:)))

    self.navigationItem.rightBarButtonItem = settingsItem
    self.navigationItem.title = navTitle
  }

  @objc func settingsButtonTapped(_ button: UIBarButtonItem) {
    FritzLogger.notice(message: "Settings button tapped")
    let storyboard = UIStoryboard(
      name: "ModelOptions",
      bundle: Bundle(for: FeatureViewController.self))

    let settingViewController = storyboard.instantiateViewController(
      withIdentifier: "ConfigurePredictor") as! ConfigureFeaturePopoverViewController
    settingViewController.modelGroup = modelGroup

    let navController =
      UINavigationController(rootViewController: settingViewController)
    navController.modalPresentationStyle = .fullScreen
    let popover = navController.popoverPresentationController
    popover?.barButtonItem = button
    
    present(navController, animated: true)
  }

}
