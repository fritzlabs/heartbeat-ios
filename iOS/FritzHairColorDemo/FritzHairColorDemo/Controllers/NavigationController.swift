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
}
