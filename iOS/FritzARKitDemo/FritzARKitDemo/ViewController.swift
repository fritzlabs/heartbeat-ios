//
//  ViewController.swift
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

typealias HumanPose = Pose<HumanSkeleton>
extension CGRect {

  var center: CGPoint {
    return CGPoint(
      x: (self.minX + self.maxX) / 2,
      y: (self.minY + self.maxY) / 2
    )
  }
}

extension Pose {

  func boundingBox() -> CGRect {
    var (minX, minY, maxX, maxY) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))

    for keypoint in keypoints {
      let x = keypoint.position.x
      let y = keypoint.position.y

      if x < minX {
        minX = x
      }
      if x > maxX {
        maxX = x
      }
      if y < minY {
        minY = y
      }
      if y > maxY {
        maxY = y
      }
    }

    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
  }

}


extension float4x4 {
  var translation: float3 {
    let translation = self.columns.3
    return float3(translation.x, translation.y, translation.z)
  }
}

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

  @IBOutlet var sceneView: ARSCNView!

  lazy var poseModel = FritzVisionHumanPoseModelFast()

  private var anchorPoints = [UUID: HumanSkeleton]()

  var detectorQueue = DispatchQueue(label: "ai.arpose.fritz.detectorQueue")

  let labelName = "cup"

  // List of nodes associated with a pose and rect of bounding box for pose.
  var detectedPoses: [([SCNNode], CGRect)] = []

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
  func update(newPoses poses: [HumanPose], forImage image: FritzVisionImage) {

    let size = image.size
    // Find center of object and translate to current camera view
    let deltaY = (size.height - viewBounds.height) / 2
    let deltaX = (size.width - viewBounds.width) / 2

    // remove objects that are not still in there and save those that are.
    var toInclude: [([SCNNode], CGRect)] = []
    for (nodes, rect) in detectedPoses {

      var found: CGRect?
      for pose in poses {
        if IOU(rect, pose.boundingBox()) > 0 {
          found = rect
          for node in nodes {
            node.removeFromParentNode()
          }
          // Update position of that node
          var newNodes: [SCNNode] = []
          for keypoint in pose.keypoints {
            let point = CGPoint(
              x: CGFloat(keypoint.position.x) - deltaX,
              y: CGFloat(keypoint.position.y) - deltaY
            )

            guard let node = buildNode(point) else { continue }
            sceneView.scene.rootNode.addChildNode(node)
            newNodes.append(node)
          }
          toInclude.append((newNodes, rect))
        }
      }


      if let found = found {
      } else {
        toInclude.append((nodes, rect))

      }
    }

    // Go through and add objects that are not already included
    for pose in poses {
      var overlaps = false
      for (_, other) in toInclude {

        if IOU(other, pose.boundingBox()) > 0 {
          overlaps = true
        }
      }

      if !overlaps {
        var nodes: [SCNNode] = []
        for keypoint in pose.keypoints {
          let point = CGPoint(
            x: CGFloat(keypoint.position.x) - deltaX,
            y: CGFloat(keypoint.position.y) - deltaY
          )

          guard let node = buildNode(point) else { continue }
          sceneView.scene.rootNode.addChildNode(node)
          nodes.append(node)
        }

        if nodes.count > 5 {
          toInclude.append((nodes, pose.boundingBox()))
        }
      }
    }
    detectedPoses = toInclude
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

    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.3
    options.minPoseThreshold = 0.1
    options.forceVisionPrediction = true
    guard let poseResults = try? self.poseModel.predict(image, options: options),
      let pose = poseResults.pose()
      else { return }

    self.update(newPoses: [pose], forImage: image)
  }


  /// Build Node when found object.
  ///
  /// - Parameters:
  ///   - size: Image size
  ///   - rect: Bounding box of object
  /// - Returns: Node in 3D space.
  func buildNode(_ point: CGPoint) -> SCNNode? {
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
