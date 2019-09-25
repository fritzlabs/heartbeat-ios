import UIKit
import AVFoundation
import Fritz

class ViewController: UIViewController {

  var cameraView: UIImageView!

  private lazy var visionModel = FritzVisionHairSegmentationModel()

  private lazy var cameraSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.session")
  private let captureQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.capture", qos: DispatchQoS.userInitiated)

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraView = UIImageView(frame: view.bounds)
    cameraView.contentMode = .scaleAspectFill
    view.addSubview(cameraView)

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
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

  /// Scores output from model greater than this value will be set as 1.
  /// Lowering this value will make the mask more intense for lower confidence values.
  var clippingScoresAbove: Double { return 0.7 }

  /// Values lower than this value will not appear in the mask.
  var zeroingScoresBelow: Double { return 0.3 }

  /// Controls the opacity the mask is applied to the base image.
  var opacity: CGFloat { return 0.7 }

  /// The method used to blend the hair mask with the underlying image.
  /// Soft light produces the best results in our tests, but check out
  /// .hue and .color for different effects.
  var blendMode: CIBlendKernel { return .softLight }

  /// Color of the mask.
  var color: UIColor { return .blue }

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let image = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)

    guard let result = try? visionModel.predict(image),
      let mask = result.buildSingleClassMask(
      forClass: FritzVisionHairSegmentationClass.hair,
      clippingScoresAbove: clippingScoresAbove,
      zeroingScoresBelow: zeroingScoresBelow,
      resize: false,
      color: color)
      else { return }

    let blended = image.blend(
      withMask: mask,
      blendKernel: blendMode,
      opacity: opacity
    )

    DispatchQueue.main.async {
      self.cameraView.image = blended
    }
  }
}
