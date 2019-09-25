//
//  CameraViewController.swift
//  CameraFramework
//
//  Created by David Okun on 8/29/17.
//  Copyright © 2017 David Okun. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Fritz



/// The main class that developers should interact with and instantiate when using Lumina
open class FritzCameraViewController: UIViewController {

  internal var logger = Logger(label: "ai.fritz.Fritz")

  var camera: FritzCamera?

  private var _cameraView: UIImageView?
  var cameraView: UIImageView {
    if let currentView = _cameraView {
      return currentView
    }

    let cameraView = UIImageView()
    cameraView.contentMode = .scaleAspectFill
    cameraView.frame = view.bounds
    _cameraView = cameraView

    return cameraView
  }

  private var _backgroundView: UIImageView?
  var backgroundView: UIImageView {
    if let currentView = _backgroundView {
      return currentView
    }
    let currentView = UIImageView()
    currentView.frame = view.bounds
    currentView.contentMode = .scaleAspectFill
    _backgroundView = currentView
    return currentView
  }

  private var _focusRecognizer: UITapGestureRecognizer?
  var focusRecognizer: UITapGestureRecognizer {
    if let currentRecognizer = _focusRecognizer {
      return currentRecognizer
    }
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(recognizer:)))
    recognizer.delegate = self
    _focusRecognizer = recognizer
    return recognizer
  }

  private var _cancelButton: FritzCameraButton?
  var cancelButton: FritzCameraButton {
    if let currentButton = _cancelButton {
      return currentButton
    }
    let origin = CGPoint(x: 20 , y: 20)
    let button = FritzCameraButton(with: SystemButtonType.cancel, origin: origin)
    button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    _cancelButton = button
    return button
  }

  private var _shutterButton: FritzCameraButton?
  var shutterButton: FritzCameraButton {
    if let currentButton = _shutterButton {
      return currentButton
    }
    let button = FritzCameraButton(with: SystemButtonType.shutter)
    button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shutterButtonTapped)))
    _shutterButton = button
    return button
  }

  private var _switchButton: FritzCameraButton?
  var switchButton: FritzCameraButton {
    if let currentButton = _switchButton {
      return currentButton
    }
    let button = FritzCameraButton(with: SystemButtonType.cameraSwitch)
    button.addTarget(self, action: #selector(switchButtonTapped), for: .touchUpInside)
    _switchButton = button
    return button
  }

  private var _textPromptView: FritzTextPromptView?
  var textPromptView: FritzTextPromptView {
    if let existingView = _textPromptView {
      return existingView
    }
    let promptView = FritzTextPromptView()
    _textPromptView = promptView
    return promptView
  }

  var isUpdating = false

  /// The delegate for streaming output from Lumina
  weak var delegate: FritzCameraControllerDelegate?

  /// The position of the camera
  ///
  /// - Note: Responds live to being set at any time, and will update automatically
  open var position: AVCaptureDevice.Position = .back {
    didSet {
      FritzLogger.notice(message: "Switching camera position to \(position.rawValue)")
      guard let camera = self.camera else {
        return
      }
      
      camera.position = position
    }
  }

  /// The position of the camera
  ///
  /// - Note: Responds live to being set at any time, and will update automatically
  open var streamBackgroundImage: Bool = false {
    didSet {
      FritzLogger.notice(message: "Streaming Background Image set to \(streamBackgroundImage)")
      backgroundView.isHidden = !streamBackgroundImage
    }
  }

  /// Set this to choose a resolution for the camera at any time - defaults to highest resolution possible for camera
  ///
  /// - Note: Responds live to being set at any time, and will update automatically
  open var resolution: CameraResolution = .highest {
    didSet {
      FritzLogger.notice(message: "Updating camera resolution to \(resolution.rawValue)")
      self.camera?.resolution = resolution
    }
  }

  /// Set this to choose a frame rate for the camera at any time - defaults to 30 if query is not available
  ///
  /// - Note: Responds live to being set at any time, and will update automatically
  open var frameRate: Int = 30 {
    didSet {
      FritzLogger.notice(message: "Attempting to update camera frame rate to \(frameRate) FPS")
      self.camera?.frameRate = frameRate
    }
  }

  /// Lumina comes ready with a view for a text prompt to give instructions to the user, and this is where you can set the text of that prompt
  ///
  /// - Note: Responds live to being set at any time, and will update automatically
  ///
  /// - Warning: If left empty, or unset, no view will be present, but view will be created if changed
  open var textPrompt = "" {
    didSet {
      FritzLogger.notice(message: "Updating text prompt view to: \(textPrompt)")
      self.textPromptView.updateText(to: textPrompt)
    }
  }

  /// Image used for debugging.
  open var debugImage: UIImage? { return nil }

  open var debugImageEnabled: Bool = false

  /// Setting visibility of the buttons (default: all buttons are visible)
  public func setCancelButton(visible: Bool) {
    cancelButton.isHidden = !visible
  }

  public func setShutterButton(visible: Bool) {
    shutterButton.isHidden = !visible
  }

  public func setSwitchButton(visible: Bool) {
    switchButton.isHidden = !visible
  }

  public func pauseCamera() {
    self.camera?.stop()
  }

  public func startCamera() {
    self.camera?.start()
  }

  /// Set this to apply a level of logging to Lumina, to track activity within the framework
  public static var loggingLevel: Logger.Level = .critical {
    didSet {
      FritzLogger.level = loggingLevel
    }
  }

  /// run this in order to create FritzCamera
  public init() {
    super.init(nibName: nil, bundle: nil)
    let camera = FritzCamera()
    camera.delegate = self
    self.camera = camera
  }

  /// run this in order to create FritzCamera with a storyboard
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    let camera = FritzCamera()
    camera.delegate = self
    self.camera = camera
  }

  /// override with caution
  open override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    FritzLogger.error(message: "Camera framework is overloading on memory")
  }

  /// override with caution
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    createUI()
    if debugImageEnabled {
      updateDebugImage()
      return
    } 
    self.camera?.updateVideo({ result in
      self.handleCameraSetupResult(result)
    })

  }

  /// override with caution
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  open override var shouldAutorotate: Bool {
    guard let _ = self.camera else {
      return true
    }
    return false
  }

  /// override with caution
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    self.camera?.stop()
  }

  /// override with caution
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateUI(orientation: UIApplication.shared.statusBarOrientation)
    updateButtonFrames()
  }

  /// override with caution
  open override var prefersStatusBarHidden: Bool {
    return false
  }

}
