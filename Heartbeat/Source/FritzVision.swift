//
//  FritzVision.swift
//  FritzVisionModel
//
//  Created by Christopher Kelly on 6/7/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

import CoreVideo
import UIKit


extension UIImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        guard let image = self.cgImage else { return nil }
        let frameSize = CGSize(width: image.width, height: image.height)

        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)

        if status != kCVReturnSuccess {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)

        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))

        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}


class FritzVisionImage {

    var image: CVPixelBuffer

    internal func toMLFeatureProvider() -> MobileNetInput {
        return MobileNetInput(image: self.image)
    }

    init(image: CVPixelBuffer) {
        self.image = image
    }

    init(image: UIImage) throws {
        self.image = image.toPixelBuffer()!
    }
}

struct FritzVisionLabel {
    let label: String
    let confidence: Double
}

typealias FritzVisionLabelCallback = ([FritzVisionLabel]?, Error?) -> Void

class FritzVisionModel {

    lazy var model = MobileNet().fritz()

    public func predict(image: FritzVisionImage, completion: @escaping FritzVisionLabelCallback) {
        do {
            let rawResult = try self.model.prediction(input: image.toMLFeatureProvider())
            let results = rawResult.classLabelProbs.map {label, confidence  in FritzVisionLabel(label: label, confidence: confidence) }
            completion(results, nil)
        } catch let error {
            completion(nil, error)
        }
    }

    public func predict(image: FritzVisionImage) throws -> [FritzVisionLabel] {
        let rawResult = try self.model.prediction(input: image.toMLFeatureProvider())
        return rawResult.classLabelProbs.map {label, confidence  in FritzVisionLabel(label: label, confidence: confidence) }
    }
}
