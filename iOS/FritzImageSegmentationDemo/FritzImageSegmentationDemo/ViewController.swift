import UIKit
import AVFoundation
import Fritz

class ViewController: UIViewController {

  var cameraView: UIImageView!
  var maskView: UIImageView!
  var backgroundView: UIImageView!

  private lazy var visionModel = FritzVisionPeopleSegmentationModel()

  private lazy var cameraSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.session")
  private let captureQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.capture", qos: DispatchQoS.userInitiated)

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraView = UIImageView(frame: view.bounds)
    cameraView.contentMode = .scaleAspectFill

    maskView = UIImageView(frame: view.bounds)
    maskView.contentMode = .scaleAspectFill

    cameraView.mask = maskView

    backgroundView = UIImageView(frame: view.bounds)
    backgroundView.contentMode = .scaleAspectFill

    let blurView = CustomBlurView(withRadius: 6.0)
    blurView.frame = self.cameraView.bounds

    backgroundView.addSubview(blurView)

    view.addSubview(backgroundView)
    view.addSubview(cameraView)

    // Setup camera
    guard let device = AVCaptureDevice.default(for: .video),
      let input = try? AVCaptureDeviceInput(device: device) else { return }

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

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let image = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)

    guard let result = try? visionModel.predict(image),
      let rotatedImage = image.rotate()
      else { return }

    let background = UIImage(pixelBuffer: rotatedImage)

    let mask = result.buildSingleClassMask(
      forClass: FritzVisionPeopleClass.person,
      clippingScoresAbove: 0.7,
      zeroingScoresBelow: 0.25
    )

    DispatchQueue.main.async {
      self.cameraView.image = background
      self.maskView.image = mask
      self.backgroundView.image = background
    }
  }
}
