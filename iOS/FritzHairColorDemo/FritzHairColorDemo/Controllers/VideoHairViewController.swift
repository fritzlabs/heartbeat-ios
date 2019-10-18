import UIKit
import AVKit
import AVFoundation
import Fritz
import ColorSlider

class VideoHairViewController: UIViewController, HairPredictor {

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

  var videoPicker: VideoPicker!
  var videoPlayer: AVPlayer!
  var isLoop: Bool = true

  internal lazy var visionModel = FritzVisionHairSegmentationModelFast()

  override func viewDidLoad() {
    super.viewDidLoad()
    color = HairColor(hairColor: colorSlider.color)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Show video picker
    self.videoPicker = VideoPicker(presentationController: self, delegate: self)
    self.videoPicker.present(from: view)
  }
}

extension VideoHairViewController: VideoPickerDelegate {

  func didSelect(url: URL?) {
    guard let url = url else {
      return
    }

    // Run prediction on every frame of the video
    let composition = AVVideoComposition(asset: AVAsset(url: url)) { request in
      let source = request.sourceImage
      let fritzImage = FritzVisionImage(image: UIImage(ciImage: source))

      if let maskedImage = self.predict(with: fritzImage) {
        request.finish(with: maskedImage.ciImage!, context: nil)
      }
      else {
        request.finish(with: source, context: nil)
      }
    }

    // Set up the video player and start it
    let videoURL = URL(string: url.absoluteString)
    videoPlayer = AVPlayer(url: videoURL!)
    videoPlayer.currentItem!.videoComposition = composition
    let playerLayer = AVPlayerLayer(player: videoPlayer)
    playerLayer.frame = view.bounds
    view.layer.addSublayer(playerLayer)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(reachTheEndOfTheVideo(_:)),
                                           name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                           object: self.videoPlayer?.currentItem)
    beginPlayback()
  }
}

extension VideoHairViewController {

  func beginPlayback() {
    guard let videoPlayer = videoPlayer else { return }
    videoPlayer.play()
    addColorSlider()
    view.bringSubviewToFront(colorSlider)
  }

  @objc func reachTheEndOfTheVideo(_ notification: Notification) {
    if isLoop {
      videoPlayer?.pause()
      videoPlayer?.seek(to: CMTime.zero)
      videoPlayer?.play()
    }
  }
}

extension VideoHairViewController {
  
  @objc func updateColor(_ slider: ColorSlider) {
    maskColor = slider.color
  }
}
