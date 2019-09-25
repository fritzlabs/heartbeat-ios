//
//  Utils.swift
//  ARPoseDemo
//
//  Created by Christopher Kelly on 5/9/19.
//  Copyright © 2019 Fritz. All rights reserved.
//

import Foundation
import ARKit
// MARK: - SCNVector3 extensions

extension SCNVector3 {


  static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
    return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
  }

  func friendlyString() -> String {
    return "(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)), \(String(format: "%.2f", z)))"
  }

  func dot(_ vec: SCNVector3) -> Float {
    return (self.x * vec.x) + (self.y * vec.y) + (self.z * vec.z)
  }

  func cross(_ vec: SCNVector3) -> SCNVector3 {
    return SCNVector3(self.y * vec.z - self.z * vec.y, self.z * vec.x - self.x * vec.z, self.x * vec.y - self.y * vec.x)
  }
}
