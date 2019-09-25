import UIKit
import AVFoundation
import Fritz

class ViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!
  var backgroundView: UIImageView!
  var backgroundViewDelayed: UIImageView!

  let context = CIContext()

  /// Scores output from model greater than this value will be set as 1.
  /// Lowering this value will make the mask more intense for lower confidence values.
  var clippingScoresAbove: Double { return 0.5 }

  /// Values lower than this value will not appear in the mask.

  var zeroingScoresBelow: Double { return 0.3 }

  /// Controls the opacity the mask is applied to the base image.
  var opacity: CGFloat { return 1.0 }

  private lazy var visionModel = FritzVisionSkySegmentationModel()

  let foreground = UIImage(named: "mountains.jpg")
  let background = UIImage(named: "clouds.png")

  var animationDuration = 12.0

  override func viewDidLoad() {
    super.viewDidLoad()

    backgroundView = initialBackground()
    backgroundViewDelayed = initialBackground()

    imageView = UIImageView(frame: view.bounds)
    imageView.contentMode = .scaleAspectFill
    view.addSubview(imageView)
    createSticker(foreground!)
    view.addSubview(backgroundView)
    view.addSubview(backgroundViewDelayed)

    view.bringSubviewToFront(imageView)
    startAnimation(on: backgroundView, delay: 0.0)
    startAnimation(on: backgroundViewDelayed, delay: animationDuration / 2)

  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  func initialBackground() -> UIImageView {
    let shiftedLeft = CGRect(origin: CGPoint(x: -view.bounds.width, y: view.bounds.minY),
      size: view.bounds.size)
    let view = UIImageView(frame: shiftedLeft)
    view.contentMode = .scaleAspectFill
    view.image = background
    return view
  }

  func startAnimation(on imageView: UIImageView, delay: Double) {
    UIView.animate(withDuration: animationDuration, delay: delay, options: [.repeat, .curveLinear], animations: {
        imageView.frame = CGRect(
          origin: CGPoint(x: self.view.bounds.width, y: self.view.bounds.minY),
          size: self.view.bounds.size
        )
      })
  }

  /// Remove background of input image based on an alpha mask.
  ///
  /// - Parameters:
  ///   - image: Image to mask
  ///   - mask: Input mask.  Reduces pixel opacity by mask alpha value. For instance
  ///       an alpha value of 255 will be completely opaque, 0 will be completely transparent
  ///       and a value of 125 will be partially transparent.
  /// - Returns: Image mask with background removed.
  func createMask(of image: UIImage, fromMask mask: UIImage, withBackground background: UIImage? = nil) -> UIImage? {
    guard let imageCG = image.cgImage, let maskCG = mask.cgImage else { return nil }
    let imageCI = CIImage(cgImage: imageCG)
    let maskCI = CIImage(cgImage: maskCG)

    let background = background?.cgImage != nil ? CIImage(cgImage: background!.cgImage!) : CIImage.empty()

    guard let filter = CIFilter(name: "CIBlendWithAlphaMask") else { return nil }
    filter.setValue(imageCI, forKey: "inputImage")
    filter.setValue(maskCI, forKey: "inputMaskImage")
    filter.setValue(background, forKey: "inputBackgroundImage")

    guard let maskedImage = context.createCGImage(filter.outputImage!, from: maskCI.extent) else {
      return nil
    }

    return UIImage(cgImage: maskedImage)
  }

  func createSticker(_ image: UIImage) {
    let fritzImage = FritzVisionImage(image: image)
    guard let result = try? visionModel.predict(fritzImage),
      let mask = result.buildSingleClassMask(
        forClass: FritzVisionSkyClass.none,
        clippingScoresAbove: clippingScoresAbove,
        zeroingScoresBelow: zeroingScoresBelow
      )
      else { return }

    guard let skyRemoved = createMask(of: image, fromMask: mask) else { return }

    DispatchQueue.main.async {
      self.imageView.image = skyRemoved
    }
  }
}
