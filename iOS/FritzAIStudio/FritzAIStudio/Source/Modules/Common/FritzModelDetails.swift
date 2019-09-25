//
//  FritzModelDetails.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 3/6/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz


public class FritzModelDetails: Equatable {

  public static func == (lhs: FritzModelDetails, rhs: FritzModelDetails) -> Bool {
    // This is not the best way to do equality.  It's just checking that it's a
    // different model on the surface.  would be good to clean this up in the future.
    return lhs.modelConfig.version == rhs.modelConfig.version && lhs.modelConfig.identifier == rhs.modelConfig.identifier && lhs.featureName == rhs.featureName
  }

  /// Active Model Configuration for managed model.
  var modelConfig: FritzModelConfiguration {
    return managedModel.activeModelConfig
  }

  /// ManagedModel used to manage interactions with Fritz API.
  let managedModel: FritzManagedModel

  let featureDescription: AIStudioFeaturePredictors

  var options: ConfigurableOptions

  /// Feature name used to configure which variant of a feature is loaded.
  /// For example, ImageSegmentation defines three variants: people_segmentation, living_room_segmentation, and outdoor_segementation.
  private var _featureName: String?
  public var featureName: String {
    if let name = _featureName {
      return name
    }
    return modelConfig.metadata?["fritz_feature"] ?? featureDescription.rawValue
  }

  /// Display name of model.
  private let _name: String?
  public var name: String {
    return managedModel.activeModelConfig.metadata?["name"] ?? _name ?? featureName
  }

  /// Description of model.
  public var description: String {
    return managedModel.activeModelConfig.metadata?["description"] ?? ""
  }

  /// Initialize FritzModel, a wrapper for a FritzManagedModel.
  ///
  /// - Parameters:
  ///   - managedModel: ManagedModel instance.
  ///   - predefinedFeatureName: Optional feature name that overrides any feature_name metadata property
  init(
    with managedModel: FritzManagedModel,
    featureDescription: AIStudioFeaturePredictors,
    name: String? = nil
  ) {
    self.managedModel = managedModel
    self.featureDescription = featureDescription
    self.options = featureDescription.defaultOptions
    self._name = name
    self.managedModel.updateModelIfNeeded(skipCache: true) { (result, error) in
      
    }
  }

  public func download() {
    managedModel.startDownload()
  }

  public var isDownloaded: Bool {
    return managedModel.hasDownloadedModel
  }

  public func isSamePredictor(_ otherDetails: FritzModelDetails) -> Bool {
    return self.modelConfig.identifier == otherDetails.modelConfig.identifier
      && self.modelConfig.version == otherDetails.modelConfig.version
  }

}
