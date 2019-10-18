import UIKit

public protocol VideoPickerDelegate: class {
  func didSelect(url: URL?)
}

open class VideoPicker: NSObject {

  private let pickerController: UIImagePickerController
  private weak var presentationController: UIViewController?
  private weak var delegate: VideoPickerDelegate?

  public init(presentationController: UIViewController, delegate: VideoPickerDelegate) {
    self.pickerController = UIImagePickerController()

    super.init()

    self.presentationController = presentationController
    self.delegate = delegate

    self.pickerController.delegate = self
    self.pickerController.allowsEditing = true
    self.pickerController.mediaTypes = ["public.movie"]
    self.pickerController.videoQuality = .typeHigh
  }

  private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
    guard UIImagePickerController.isSourceTypeAvailable(type) else {
      return nil
    }

    return UIAlertAction(title: title, style: .default) { [unowned self] _ in
      self.pickerController.sourceType = type
      self.presentationController?.present(self.pickerController, animated: true)
    }
  }

  public func present(from sourceView: UIView) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    if let action = self.action(for: .photoLibrary, title: "Video library") {
      alertController.addAction(action)
    }

    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    if UIDevice.current.userInterfaceIdiom == .pad {
      alertController.popoverPresentationController?.sourceView = sourceView
      alertController.popoverPresentationController?.sourceRect = sourceView.bounds
      alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
    }

    self.presentationController?.present(alertController, animated: true)
  }

  private func pickerController(_ controller: UIImagePickerController, didSelect url: URL?) {
    controller.dismiss(animated: true, completion: nil)

    self.delegate?.didSelect(url: url)
  }
}

extension VideoPicker: UIImagePickerControllerDelegate {

  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.pickerController(picker, didSelect: nil)
  }

  public func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    guard let url = info[.mediaURL] as? URL else {
      return self.pickerController(picker, didSelect: nil)
    }

    self.pickerController(picker, didSelect: url)
  }
}

extension VideoPicker: UINavigationControllerDelegate {

}
