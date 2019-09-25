//
//  NavigationController.swift
//  FritzAIStudio
//
//  Created by Andrew Barba on 12/14/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationBar.tintColor = .white
    navigationBar.shadowImage = UIImage()
    navigationBar.isTranslucent = true
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    let blurView = createBlurView()
    navigationBar.addSubview(blurView)

    let titleFont = UIFont.systemFont(ofSize: 17, weight: .bold)
    navigationBar.titleTextAttributes = [
      .font: titleFont,
      .foregroundColor: UIColor.white
    ]

    let buttonFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
      .setTitleTextAttributes([ .font: buttonFont], for: .normal)
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
      .setTitleTextAttributes([ .font: buttonFont], for: .highlighted)
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
      .setTitleTextAttributes([ .font: buttonFont], for: .disabled)
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
      .setTitleTextAttributes([ .font: buttonFont], for: .selected)
  }

  private func createBlurView() -> UIVisualEffectView {
    let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    var bounds = navigationBar.bounds
    let notchHeight: CGFloat = UIDevice.hasNotch ? 30.0 : 0.0
    bounds.size.height += 20 + notchHeight
    bounds.origin.y -= 20 + notchHeight

    visualEffectView.isUserInteractionEnabled = false
    visualEffectView.frame = bounds
    visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    visualEffectView.layer.zPosition = -1
    return visualEffectView
  }
}
