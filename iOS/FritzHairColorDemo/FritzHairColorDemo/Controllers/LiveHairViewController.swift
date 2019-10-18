import UIKit
import AVFoundation
import Fritz
import ColorSlider

class LiveHairViewController: UIViewController, HairPredictor {

  var color: HairColor!
  var _colorSlider: ColorSlider?
  var colorSlider: ColorSlider {
    if let slider = _colorSlider {
      return slider
    }

    let slider = ColorSlider(orientation: .vertical, previewSide: .left)
    _colorSlider = slider
    slider.addTarget(self, action: #selector(updateColor(_:)), for: .valueChanged)
    return slider
  }

  var cameraView: UIImageView!
  internal lazy var visionModel = FritzVisionHairSegmentationModelFast()

  private lazy var cameraSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.session")
  private let captureQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.capture", qos: DispatchQoS.userInitiated)

  override func viewDidLoad() {
    super.viewDidLoad()

    color = HairColor(hairColor: colorSlider.color)
    cameraView = UIImageView(frame: view.bounds)
    cameraView.contentMode = .scaleAspectFill
    view.addSubview(cameraView)
    addColorSlider()

    // Setup camera
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
      let input = try? AVCaptureDeviceInput(device: device)
      else { return }

    let output = AVCaptureVideoDataOutput()

    // Configure pixelBuffer format for use in model
    output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
    output.alwaysDiscardsLateVideoFrames = true
    output.setSampleBufferDelegate(self, queue: captureQueue)

    sessionQueue.async {
      self.cameraSession.beginConfiguration()
      self.cameraSession.addInput(input)
      self.cameraSession.addOutput(output)
      self.cameraSession.commitConfiguration()
      self.cameraSession.sessionPreset = .photo

      // Front camera images are mirrored.
      output.connection(with: .video)?.isVideoMirrored = true
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    sessionQueue.async {
      self.cameraSession.startRunning()
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    view.bringSubviewToFront(colorSlider)
  }
}

extension LiveHairViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let image = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)
    let blended = self.predict(with: image)

    DispatchQueue.main.async {
      self.cameraView.image = blended
    }
  }
}

extension LiveHairViewController {
  
  @objc func updateColor(_ slider: ColorSlider) {
    maskColor = slider.color
  }
}
