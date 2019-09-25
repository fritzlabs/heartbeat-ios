//
//  FritzCamera+AVCaptureVideoDelegate.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/20/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz
import AVFoundation


extension FritzCamera: AVCaptureVideoDataOutputSampleBufferDelegate {

  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    let image = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)

    self.delegate?.capture(self, didCaptureFritzImage: image, timestamp: Date())
  }
}
