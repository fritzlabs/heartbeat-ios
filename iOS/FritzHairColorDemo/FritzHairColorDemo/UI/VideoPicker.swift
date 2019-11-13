import UIKit

public protocol VideoPickerDelegate: class {
  func didSelect(url: URL?)
}

public class VideoPicker: NSObject {

  private let pickerController = UIImagePickerController()
  private weak var viewController: UIViewController?
  private weak var delegate: VideoPickerDelegate?

  public init(controller: UIViewController, delegate: VideoPickerDelegate) {
    super.init()

    self.viewController = controller
    self.delegate = delegate
    self.pickerController.delegate = self
    self.pickerController.allowsEditing = true
    self.pickerController.mediaTypes = ["public.movie"]
    self.pickerController.videoQuality = .typeHigh
  }

  private func action(
    for type: UIImagePickerController.SourceType,
    title: String
  ) -> UIAlertAction? {
    guard UIImagePickerController.isSourceTypeAvailable(type) else {
      return nil
    }

    return UIAlertAction(title: title, style: .default) { [unowned self] _ in
      self.pickerController.sourceType = type
      self.viewController?.present(self.pickerController, animated: true)
    }
  }

  /// Show the action sheet.
  ///
  /// - Parameters:
  ///   - sourceView: the view to show the action sheet on
  public func present(from sourceView: UIView) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    if let action = self.action(for: .photoLibrary, title: "Video library") {
      alertController.addAction(action)
    }

    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
      self.popToRoot()
    })

    if UIDevice.current.userInterfaceIdiom == .pad {
      alertController.popoverPresentationController?.sourceView = sourceView
      alertController.popoverPresentationController?.sourceRect = sourceView.bounds
      alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
    }

    self.viewController?.present(alertController, animated: true)
  }

  /// Dismisses the menu and calls the delegate.
  ///
  /// - Parameters:
  ///  - controller: the picker controller
  ///  - url: the url of the selected item
  private func pickerController(_ controller: UIImagePickerController, didSelect url: URL?) {
    if let _ = url {
      controller.dismiss(animated: true)
    }
    else {
      controller.dismiss(animated: false) { self.popToRoot() }
    }
    self.delegate?.didSelect(url: url)
  }

  /// Go back to the main page
  private func popToRoot() {
    self.viewController?.navigationController?.popToRootViewController(animated: true)
  }
}

extension VideoPicker: UIImagePickerControllerDelegate {

  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.pickerController(picker, didSelect: nil)
  }

  public func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let url = info[.mediaURL] as? URL else {
      return self.pickerController(picker, didSelect: nil)
    }

    self.pickerController(picker, didSelect: url)
  }
}

extension VideoPicker: UINavigationControllerDelegate {}
