import UIKit
import AVFoundation
import Fritz

class ViewController: UIViewController, UIImagePickerControllerDelegate,
  UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    var maskView: UIImageView!
    var backgroundView: UIImageView!

    let context = CIContext()
    private lazy var visionModel = FritzVisionPetSegmentationModel()

    override func viewDidLoad() {
      super.viewDidLoad()
      openPhotoLibrary()
      backgroundView = UIImageView(frame: view.bounds)
      backgroundView.backgroundColor = .red
      view.addSubview(backgroundView)

      imageView = UIImageView(frame: view.bounds)
      imageView.contentMode = .scaleAspectFit
      view.addSubview(imageView)
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
    }

    func openPhotoLibrary() {
      if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
      }
    }

    @objc func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
      self.dismiss(animated: true, completion: { () -> Void in
      })
      createSticker(image)
    }
}


extension ViewController {

  /// Scores output from model greater than this value will be set as 1.
  /// Lowering this value will make the mask more intense for lower confidence values.
  var clippingScoresAbove: Double { return 0.6 }

  /// Values lower than this value will not appear in the mask.
  var zeroingScoresBelow: Double { return 0.4 }

  func createSticker(_ image: UIImage) {
    let fritzImage = FritzVisionImage(image: image)
    guard let result = try? visionModel.predict(fritzImage),
      let mask = result.buildSingleClassMask(
        forClass: FritzVisionPetClass.pet,
        clippingScoresAbove: clippingScoresAbove,
        zeroingScoresBelow: zeroingScoresBelow
      )
      else { return }

    let petSticker = fritzImage.masked(with: mask)

    DispatchQueue.main.async {
      self.imageView.image = petSticker
    }
  }
}
