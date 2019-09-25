//
//  ModelChooserTableViewController.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/5/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import UIKit

class ChooseModelTableViewController: UITableViewController {
  public var models: [FritzModelDetails]!

  private var downloadedModels: [FritzModelDetails] {
    return models.filter { $0.isDownloaded }
  }
  private var notDownloadedModels: [FritzModelDetails] {
    return models.filter { !$0.isDownloaded }
  }

  weak var delegate: ChooseFeatureDelegate?

  public var selectedModel: FritzModelDetails? {
    didSet {
      if let selectedModel = selectedModel,
        let index = models.firstIndex(of: selectedModel) {
        selectedModelIndex = index
      }
    }
  }

  public var selectedModelIndex: Int?

  override func viewDidLoad() {
    super.viewDidLoad()

    if let selectedModel = selectedModel {
      self.selectedModelIndex = models.firstIndex(of: selectedModel)
    }
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {

    if section == 0 {
      return "Downloaded models"
    }
    return "Models available to download"
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return downloadedModels.count
    }
    return notDownloadedModels.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath)
      let model = downloadedModels[indexPath.row]
      cell.textLabel?.text = model.name

      if model == selectedModel {
        cell.accessoryType = .checkmark
      }

      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath)
    cell.textLabel?.text = notDownloadedModels[indexPath.row].name

    return cell

  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      let model = downloadedModels[indexPath.row]
      self.selectedModel = model
      self.delegate?.choosePredictor(model)
      self.performSegue(withIdentifier: "SelectModel", sender: self)
    }
    if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath)
      let model = notDownloadedModels[indexPath.row]
      handleAlert(for: model, cell: cell)
    }
  }
}


extension ChooseModelTableViewController {

  func handleAlert(for model: FritzModelDetails, cell: UITableViewCell) {
    let alertController = UIAlertController(title: model.name, message: model.description, preferredStyle: .actionSheet)

    let downloadAction = UIAlertAction(title: "Download", style: .default) { action in
      let spinner = UIActivityIndicatorView(style: .gray)
      spinner.startAnimating()
      DispatchQueue.main.async {
        cell.accessoryView = spinner
        self.tableView.reloadData()
      }
      model.managedModel.fetchModel { [weak self] downloaded, error in
        guard let _ = downloaded else { return }

        DispatchQueue.main.async {
          cell.accessoryView = nil
          self?.tableView.reloadData()
        }

      }
    }
    alertController.addAction(downloadAction)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)

    //Show alert view
    present(alertController, animated: true, completion: nil)
  }
}
