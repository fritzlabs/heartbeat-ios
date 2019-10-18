import UIKit
import Fritz

class ViewController: UITableViewController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black
    title = "Hair Coloring".uppercased()
    tableView.register(DemoTableViewCell.self, forCellReuseIdentifier: "DemoTableViewCell")
    tableView.register(LinkTableViewCell.self, forCellReuseIdentifier: "LinkTableViewCell")
    clearsSelectionOnViewWillAppear = true
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let _ = tableView.cellForRow(at: indexPath) as? LinkTableViewCell,
      let url = URL(string: "https://app.fritz.ai/register") {
      UIApplication.shared.open(url)
      tableView.deselectRow(at: indexPath, animated: true)
    }

    if let cell = tableView.cellForRow(at: indexPath) as? DemoTableViewCell {
      guard let identifier = cell.reuseIdentifier else { return }

      var viewController: UIViewController?
      switch identifier {
      case "LiveHairColor":
        viewController = LiveHairViewController()
      case "VideoHairColor":
        viewController = VideoHairViewController()
      default:
        return
      }

      if let currentController = viewController {
        self.navigationController?.pushViewController(currentController, animated: true)
      }
    }
  }
}
