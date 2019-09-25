//
//  FritzCameraButton.swift
//  Lumina
//
//  Created by David Okun on 9/11/17.
//  Copyright © 2017 David Okun. All rights reserved.
//

import UIKit

final class SettingsButton: UIButton {
  private var buttonWidth = 40
  private var buttonHeight = 40

  private var border: UIView?

  private var _image: UIImage?
  var image: UIImage? {
    get {
      return _image
    }
    set {
      self.setImage(newValue, for: UIControl.State.normal)
      _image = newValue
    }
  }

  private var _text: String?
  var text: String? {
    get {
      return _text
    }
    set {
      self.setTitle(newValue, for: UIControl.State.normal)
      _text = newValue
    }
  }

  init(origin: CGPoint = CGPoint(x: UIScreen.main.bounds.maxX - 50, y: 10)) {
    super.init(frame: CGRect.zero)
    self.backgroundColor = UIColor.clear
    if let titleLabel = self.titleLabel {
      titleLabel.textColor = UIColor.white
      titleLabel.font = UIFont.systemFont(ofSize: 20)
    }
      self.image = UIImage(named: "SettingsIcon", in: Bundle(for: FritzCameraViewController.self), compatibleWith: nil)
      self.frame = CGRect(
        origin: origin,
        size: CGSize(width: self.buttonWidth, height: self.buttonHeight)
      )
      addButtonShadowEffects()
  }

  private func addButtonShadowEffects() {
    self.layer.shadowOffset = CGSize(width: 0, height: 0)
    self.layer.shadowOpacity = 1
    self.layer.shadowRadius = 6
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

fileprivate extension UIColor {
  class var normalState: UIColor {
    return UIColor(white: 1.0, alpha: 0.65)
  }

  class var recordingState: UIColor {
    return UIColor.red.withAlphaComponent(0.65)
  }

  class var takePhotoState: UIColor {
    return UIColor.lightGray.withAlphaComponent(0.65)
  }

  class var borderNormalState: CGColor {
    return UIColor.gray.cgColor
  }

  class var borderRecordingState: CGColor {
    return UIColor.red.cgColor
  }

  class var borderTakePhotoState: CGColor {
    return UIColor.darkGray.cgColor
  }
}
