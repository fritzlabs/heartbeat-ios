//
//  AppDelegate.swift
//  Fritz Labs
//
//  Created by Andrew Barba on 12/12/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import Crashlytics
import Fabric
import FritzCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Configure crash reporting
    Fabric.with([Crashlytics.self])

    // Configure Fritz models
    // FritzCore.setLogLevel(.debug)
    FritzCore.configure()

    return true
  }
}
