//
//  DemosViewController.swift
//  FritzAIStudio
//
//  Created by Andrew Barba on 12/26/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import Fritz

class DemosViewController: UITableViewController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black
    title = "Demos".uppercased()
    tableView.register(DemoTableViewCell.self, forCellReuseIdentifier: "DemoTableViewCell")
    tableView.register(LinkTableViewCell.self, forCellReuseIdentifier: "LinkTableViewCell")
    clearsSelectionOnViewWillAppear = true
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let _ = tableView.cellForRow(at: indexPath) as? LinkTableViewCell, let url = URL(string: "https://app.fritz.ai/register") {
      UIApplication.shared.open(url)
      tableView.deselectRow(at: indexPath, animated: true)
    }

    if let cell = tableView.cellForRow(at: indexPath) as? DemoTableViewCell {
      guard let identifier = cell.reuseIdentifier else { return }

      var viewController: UIViewController?
      switch identifier {
      case "ImageSegmentation":
        viewController = ImageSegmentationViewController()
      case "PoseEstimation":
        viewController = PoseEstimationViewController()
      case "StyleTransfer":
        viewController = StyleTransferViewController()
      case "FlexibleStyleTransfer":
        viewController = FlexibleStyleTransferViewController()
      case "HairColor":
        viewController = HairColorViewController()
      default:
        return
      }

      if let currentController = viewController {
        self.navigationController?.pushViewController(currentController, animated: true)
      }
    }
  }

}
