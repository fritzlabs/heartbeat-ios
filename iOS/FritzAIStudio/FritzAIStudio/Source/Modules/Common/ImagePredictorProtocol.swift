//
//  ImagePredictorProtocol.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/24/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz


protocol ImagePredictor {


  /// Runs prediction for a FritzVisionImage with user configurable options.
  ///
  /// A common use case of this Delegate is to extend an existing FritzVision model
  /// That just runs the predict method.
  ///
  /// - Parameters:
  ///   - image: FritzVisionImage with camera orientation settings applied.
  ///   - options: Options that can be be configured for the model.  These commonly can either be used to build the Model's options object or for postprocessing parameters.
  func predict(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage?

}
