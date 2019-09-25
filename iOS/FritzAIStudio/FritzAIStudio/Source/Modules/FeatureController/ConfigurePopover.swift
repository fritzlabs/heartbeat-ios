//
//  ConfigureModelPopover.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/6/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit


protocol ChooseFeatureDelegate: class {

  func choosePredictor(_ predictor: FritzModelDetails)
}


class ConfigureFeaturePopoverViewController: UITableViewController {

  @IBAction func unwindWithSelectedRow(segue: UIStoryboardSegue) {
    tableView.reloadData()
  }

  public var modelGroup: ModelGroupManager!

  fileprivate var selectedPredictorDetails: FritzModelDetails? {
    get {
      return modelGroup.selectedPredictorDetails
    }
    set {
      modelGroup.selectedPredictorDetails = newValue
    }
  }

  fileprivate var options: ConfigurableOptions! {
    set {
      modelGroup.selectedPredictorDetails!.options = newValue
    }
    get {
      return modelGroup.selectedPredictorDetails!.options
    }
  }

  private var optionsList: [PredictorOption]! {
    return options.values.map { $0 }.sorted { $0.priority < $1.priority }
  }

  private func getOption(for section: Int) -> PredictorOption {
    return optionsList[section - 1]
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.delegate = self
    self.tableView.dataSource = self

    tableView.register(ChooseModelCell.nib, forCellReuseIdentifier: ChooseModelCell.identifier)
    tableView.register(RangeSliderCell.nib, forCellReuseIdentifier: RangeSliderCell.identifier)
    tableView.register(SegmentSliderCell.nib, forCellReuseIdentifier: SegmentSliderCell.identifier)
    tableView.register(ChooseColorCell.nib, forCellReuseIdentifier: ChooseColorCell.identifier)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ChooseModel" {
      let modelSelectionViewController = segue.destination as! ChooseModelTableViewController
      modelSelectionViewController.delegate = self
      modelSelectionViewController.models = modelGroup.models
      modelSelectionViewController.selectedModel = selectedPredictorDetails
      return
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
    if section == 0 {
      return "Model Name"
    }
    return getOption(for: section).optionType.getName()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1 + optionsList.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: ChooseModelCell.identifier) as! ChooseModelCell
      if let name = selectedPredictorDetails?.name {
        cell.textLabel?.text = name
      } else {
        cell.textLabel?.text = "Choose a model"
      }
      cell.accessoryType = .disclosureIndicator
      return cell
    }

    let option = getOption(for: indexPath.section)

    switch type(of: option).cellType {
    case .rangeValue:
      let cell = tableView.dequeueReusableCell(withIdentifier: RangeSliderCell.identifier) as! RangeSliderCell
      cell.name = option.optionType.getName()
      cell.delegate = self
      cell.value = (option as! RangeValue)
      cell.initLabels()
      return cell
    case .segmentValue:
      let cell = tableView.dequeueReusableCell(withIdentifier: SegmentSliderCell.identifier) as! SegmentSliderCell
      cell.name = option.optionType.getName()
      cell.delegate = self
      cell.value = (option as! SegmentValue)
      cell.initSegments()
      return cell
    case .colorSlider:
      let cell = tableView.dequeueReusableCell(withIdentifier: ChooseColorCell.identifier) as! ChooseColorCell
      cell.name = option.optionType.getName()
      cell.delegate = self
      cell.initColorSlider(option as! ColorSliderValue)
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      // Segue to the second view controller
      self.performSegue(withIdentifier: "ChooseModel", sender: self)
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
}

extension ConfigureFeaturePopoverViewController: ChooseFeatureDelegate {

  func choosePredictor(_ predictorDetails: FritzModelDetails) {
    self.selectedPredictorDetails = predictorDetails
  }
}


extension ConfigureFeaturePopoverViewController: FeatureOptionCellDelegate {

  func update(_ value: PredictorOption) {
    options[value.optionType] = value
  }
}
