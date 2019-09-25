//
//  CapturePhotoDelgate.swift
//  FritzAIStudio
//
//  Created by Christopher Kelly on 4/23/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import Fritz



extension FritzCamera: AVCapturePhotoCaptureDelegate {

  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard let pixelBuffer = photo.pixelBuffer else { return }

    // Gets the CGOrientation of the photo
    let imageOrientation = photo.getImageOrientation(forCamera: position)

    let image = FritzVisionImage(imageBuffer: pixelBuffer)
    image.metadata = FritzVisionImageMetadata()
    image.metadata?.orientation = FritzImageOrientation(imageOrientation)

    guard let output = try? delegate?.processPhoto(self, didCaptureFritzImage: image, timestamp: Date()),
      let jpegData = output.jpegData(compressionQuality: 1.0)
    else { return }

    // Save JPEG to photo library
    PHPhotoLibrary.requestAuthorization { status in
      if status == .authorized {
        PHPhotoLibrary.shared().performChanges({
          let creationRequest = PHAssetCreationRequest.forAsset()
          creationRequest.addResource(with: .photo, data: jpegData, options: nil)
        }, completionHandler: { _, error in
          if let error = error {
            print("Error occurred while saving photo to photo library: \(error)")
          }
        })
      }
    }
  }



}
