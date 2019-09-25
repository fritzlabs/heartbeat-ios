//
//  ARKit+Utilities.swift
//  ARKitCoreML
//
//  Created by Jason Clark on 10/11/18.
//  Copyright © 2018 Raizlabs. All rights reserved.
//

import ARKit

import CoreImage

import UIKit
import VideoToolbox

extension ARSCNView {

  /**
   Functionally equivalent to `SCNView`'s `snapshot()`, except only including the raw camera image, not any virtual geometry that may be in the scene.
   */
  public func capturedImage() -> UIImage? {
    guard let frame = session.currentFrame else { return nil }
    return frame.getCapturedImage(inSceneView: self)
  }

  /**
   Returns a cropped and deskewed image of the raw camera image of a given `ARImageAnchor`, not including any virtual geometry that may be in the scene.
   */
  public func capturedImage(from anchor: ARImageAnchor) -> UIImage? {
    guard
      let frame = session.currentFrame,
      let node = node(for: anchor),
      let pov = pointOfView,
      isNode(node, insideFrustumOf: pov),
      let snapshot = frame.getCapturedImage(inSceneView: self),
      let coreImage = CIImage(image: snapshot),
      let featureCorners = projectCorners(of: anchor)
      else {
        return nil
    }
    // CoreImage uses cartesian coordinates
    func cartesianForPoint(point: CGPoint, extent: CGRect) -> CGPoint {
      return CGPoint(x: point.x, y: extent.height - point.y)
    }
    let deskewed = coreImage.perspectiveCorrected(
      topLeft: cartesianForPoint(point: featureCorners.topLeft, extent: coreImage.extent),
      topRight: cartesianForPoint(point: featureCorners.topRight, extent: coreImage.extent),
      bottomLeft: cartesianForPoint(point: featureCorners.bottomLeft, extent: coreImage.extent),
      bottomRight: cartesianForPoint(point: featureCorners.bottomRight, extent: coreImage.extent)
    )
    return UIImage(ciImage: deskewed)
  }

}

extension ARFrame {
  /**
   Gives the camera data in the given frame after scaling and cropping it
   in the same way Apple does it for constructing the backing image you
   can retrieve via `sceneView.snapshot()`.
   */
  func getCapturedImage(inSceneView sceneView: ARSCNView) -> UIImage? {
    let rawImage = getOrientationCorrectedCameraImage(forOrientation: UIApplication.shared.statusBarOrientation)
    let viewportSize = sceneView.frame.size

    switch UIApplication.shared.statusBarOrientation {

    case .portrait, .portraitUpsideDown:
      guard let resized = rawImage?.resize(toHeight: viewportSize.height) else {
        return nil
      }
      return resized.crop(rect: CGRect(
        x: (resized.size.width - viewportSize.width) / 2,
        y: 0,
        width: viewportSize.width,
        height: viewportSize.height)
      )

    case .landscapeLeft, .landscapeRight:
      guard let resized = rawImage?.resize(toWidth: viewportSize.width) else {
        return nil
      }
      return resized.crop(rect: CGRect(
        x: 0,
        y: (resized.size.height - viewportSize.height) / 2,
        width: viewportSize.width,
        height: viewportSize.height)
      )

    case .unknown:
      return nil
    }
  }

}

private extension ARSCNView {

  private func projectCorners(of imageAnchor: ARImageAnchor) -> (topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint, topLeft: CGPoint)? {
    guard
      let camera = session.currentFrame?.camera,
      let corners = CornerTrackingNode.tracking(anchor: imageAnchor, inScene: self)
      else { return nil }

    defer {
      corners.removeFromParentNode()
    }

    let pointsWorldSpace = [
      corners.topRight.simdWorldPosition,
      corners.bottomRight.simdWorldPosition,
      corners.bottomLeft.simdWorldPosition,
      corners.topLeft.simdWorldPosition,
    ]

    let pointsImageSpace: [CGPoint] = pointsWorldSpace.map {
      var point = camera.projectPoint($0,
                                      orientation: UIApplication.shared.statusBarOrientation,
                                      viewportSize: bounds.size)
      point.x *= UIScreen.main.scale
      point.y *= UIScreen.main.scale
      return point
    }

    return (
      topRight: pointsImageSpace[0],
      bottomRight: pointsImageSpace[1],
      bottomLeft: pointsImageSpace[2],
      topLeft: pointsImageSpace[3]
    )
  }

}

private extension ARFrame {
  /**
   Rotates the image from the camera to match the orientation of the device.
   */
  private func getOrientationCorrectedCameraImage(forOrientation orientation: UIInterfaceOrientation) -> UIImage? {
    var rotationRadians: Float = 0
    switch orientation {
    case .portrait:
      rotationRadians = .pi / 2
    case .portraitUpsideDown:
      rotationRadians = -.pi / 2
    case .landscapeLeft:
      rotationRadians = .pi
    case .landscapeRight:
      break
    case .unknown:
      return nil
    }
    return UIImage(pixelBuffer: capturedImage)?.rotate(radians: rotationRadians)
  }

}


private class CornerTrackingNode: SCNNode {

  let topLeft = SCNNode()
  let topRight = SCNNode()
  let bottomLeft = SCNNode()
  let bottomRight = SCNNode()

  init(anchor: ARImageAnchor) {
    super.init()

    let physicalSize = anchor.referenceImage.physicalSize
    let halfWidth = Float(physicalSize.width / 2)
    let halfHeight = Float(physicalSize.height / 2)

    addChildNode(topLeft)
    topLeft.position = position
    topLeft.localTranslate(by: SCNVector3(-halfWidth, 0, halfHeight))

    addChildNode(topRight)
    topRight.position = position
    topRight.localTranslate(by: SCNVector3(halfWidth, 0, halfHeight))

    addChildNode(bottomLeft)
    bottomLeft.position = position
    bottomLeft.localTranslate(by: SCNVector3(-halfWidth, 0, -halfHeight))

    addChildNode(bottomRight)
    bottomRight.position = position
    bottomRight.localTranslate(by: SCNVector3(halfWidth, 0, -halfHeight))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  static func tracking(anchor: ARImageAnchor, inScene scene: ARSCNView) -> CornerTrackingNode? {
    guard let node = scene.node(for: anchor) else { return nil }
    let tracker = CornerTrackingNode(anchor: anchor)
    node.addChildNode(tracker)
    return tracker
  }

}

extension CIImage {

  func perspectiveCorrected(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
    return self.applyingFilter("CIPerspectiveCorrection", parameters: [
      "inputTopLeft": CIVector(cgPoint: topLeft),
      "inputTopRight": CIVector(cgPoint: topRight),
      "inputBottomLeft": CIVector(cgPoint: bottomLeft),
      "inputBottomRight": CIVector(cgPoint: bottomRight),
      ])
  }

}


extension UIImage {

  public convenience init?(pixelBuffer: CVPixelBuffer) {
    var cgImage: CGImage?
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
    guard let image = cgImage else { return nil }
    self.init(cgImage: image)
  }

  public func crop(rect: CGRect) -> UIImage? {
    var rect = rect
    rect.origin.x *= scale
    rect.origin.y *= scale
    rect.size.width *= scale
    rect.size.height *= scale

    if let imageRef = cgImage?.cropping(to: rect) {
      return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
    }
    return nil
  }

  public func rotate(radians: Float) -> UIImage? {
    var newSize = CGRect(origin: .zero, size: size)
      .applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size

    newSize.width = floor(newSize.width)
    newSize.height = floor(newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, true, scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    // Move origin to middle
    context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
    // Rotate around middle
    context.rotate(by: CGFloat(radians))

    self.draw(in: CGRect(
      x: -size.width / 2,
      y: -size.height / 2,
      width: size.width, height: size.height
    ))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
  }

  public func getOrCreateCGImage() -> CGImage? {
    return cgImage ?? ciImage.flatMap {
      let context = CIContext()
      return context.createCGImage($0, from: $0.extent)
    }
  }

  /**
   Scales the image to the given height while preserving its aspect ratio.
   */
  public func resize(toHeight newHeight: CGFloat) -> UIImage? {
    guard self.size.height != newHeight else { return self }
    let ratio = newHeight / size.height
    let newSize = CGSize(width: size.width * ratio, height: newHeight)
    return resize(to: newSize)
  }

  /**
   Scales the image to the given width while preserving its aspect ratio.
   */
  public func resize(toWidth newWidth: CGFloat) -> UIImage? {
    guard self.size.width != newWidth else { return self }
    let ratio = newWidth / size.width
    let newSize = CGSize(width: newWidth, height: size.height * ratio)
    return resize(to: newSize)
  }

  private func resize(to newSize: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    self.draw(in: CGRect(origin: .zero, size: newSize))
    let scaledImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }

}
