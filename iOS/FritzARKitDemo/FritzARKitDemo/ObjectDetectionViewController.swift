//
//  ObjectDetectionViewController.swift
//  ARPoseDemo
//
//  Created by Christopher Kelly on 5/8/19.
//  Copyright © 2019 Fritz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Fritz
import AVFoundation


class ObjectDetectionViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

  @IBOutlet var sceneView: ARSCNView!


  lazy var objectModel = FritzVisionObjectModel()

  var detectorQueue = DispatchQueue(label: "ai.arpose.fritz.detectorQueue")

  let labelName = "cup"

  var detectedObjects: [(SCNNode, CGRect)] = []

  var viewBounds: CGSize!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self
    sceneView.session.delegate = self

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    viewBounds = sceneView.bounds.size
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscapeRight
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }

  // MARK: - ARSCNViewDelegate
  /// Update detected objects.
  ///
  /// - Parameters:
  ///   - objects: Objects detected from most recent object detection run.
  ///   - image: Image.
  func update(newObjects objects: [CGRect], forImage image: FritzVisionImage) {

    let size = image.size

    // remove objects that are not still in there and save those that are.
    var toInclude: [(SCNNode, CGRect)] = []
    for (node, rect) in detectedObjects {
      var found: CGRect?
      for other in objects {
        if IOU(rect, other) > 0 {
          found = rect
        }
      }

      if let found = found {
        // Update position of that node
        toInclude.append((node, found))
      } else {
        node.removeFromParentNode()
      }
    }

    // Go through and add objects that are not already included
    for object in objects {
      var overlaps = false
      for (_, other) in toInclude {

        if IOU(object, other) > 0 {
          overlaps = true
        }
      }
      if !overlaps {
        guard let node = buildNode(size, object) else { continue }
        sceneView.scene.rootNode.addChildNode(node)
        toInclude.append((node, object))
      }
    }
    detectedObjects = toInclude
  }

  var predicting = false

  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    guard let frame = self.sceneView.session.currentFrame else { return }

    if predicting { return }

    detectorQueue.async {
      self.predicting = true
      self.runPrediction(on: frame)
      self.predicting = false
    }
  }

  func runPrediction(on frame: ARFrame) {

    let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
    let image = FritzVisionImage(imageBuffer: frame.capturedImage)
    image.metadata = FritzVisionImageMetadata()
    image.metadata?.orientation = FritzImageOrientation(UIImage.Orientation(orientation))

    let options = FritzVisionObjectModelOptions()
    options.forceVisionPrediction = true

    guard let objects = try? self.objectModel.predict(image, options: options) else { return }

    let selected = objects.filter { $0.label == self.labelName }
    let scaledObjects = selected.map { $0.boundingBox.scaledBy(image.size) }
    self.update(newObjects: scaledObjects, forImage: image)
  }


  /// Build Node when found object.
  ///
  /// - Parameters:
  ///   - size: Image size
  ///   - rect: Bounding box of object
  /// - Returns: Node in 3D space.
  func buildNode(_ size: CGSize, _ rect: CGRect) -> SCNNode? {

    // Find center of object and translate to current camera view
    let center = rect.center
    let deltaY = (size.height - viewBounds.height) / 2
    let deltaX = (size.width - viewBounds.width) / 2
    let point = CGPoint(x: center.x - deltaX, y: center.y - deltaY)


    // Build node and add to view
    let hitTestResults = sceneView.hitTest(point, types: [.featurePoint, .estimatedHorizontalPlane])
    guard let result = hitTestResults.first else { return nil }

    let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
    // Add a new anchor at the tap location.

    let node: SCNNode = {
      let sphere = SCNSphere(radius: 0.005)
      sphere.firstMaterial?.diffuse.contents = UIColor.red
      sphere.firstMaterial?.lightingModel = .constant
      sphere.firstMaterial?.isDoubleSided = true

      let node = SCNNode(geometry: sphere)
      node.position = hitPosition
      return node
    }()

    return node

  }

  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    DispatchQueue.main.async {
      self.viewBounds = self.sceneView.bounds.size
    }
  }

  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user

  }

  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay

  }

  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required

  }
}
