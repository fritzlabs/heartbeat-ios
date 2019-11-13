import UIKit
import AVKit
import AVFoundation
import Fritz
import ColorSlider

class VideoHairViewController: UIViewController, HairPredictor {

  var videoPicker: VideoPicker!
  var videoPlayer: FritzVisionVideo!
  var filterOptions = FritzVisionHairSegmentationFilterOptions()

  lazy var visionModel = FritzVisionHairSegmentationModelFast()
  var colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)

  override func viewDidLoad() {
    super.viewDidLoad()
    colorSlider.addTarget(self, action: #selector(updateColor(_:)), for: .valueChanged)
    filterOptions.maskColor = colorSlider.color
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Show video picker
    self.videoPicker = VideoPicker(controller: self, delegate: self)
    self.videoPicker.present(from: view)
  }
}

extension VideoHairViewController: VideoPickerDelegate {

  func didSelect(url: URL?) {
    guard let url = url else { return }

    // Setting the options for the video
    let options = FritzVisionVideoOptions()
    options.filters.append(FritzVisionHairBlendFilter(model: visionModel, options: filterOptions))
    videoPlayer = FritzVisionVideo(url: url, options: options)

    // Setup the view
    let fritzView = FritzVideoView()
    fritzView.frame = view.bounds
    fritzView.fritzVideo = videoPlayer

    // Add components to the view and start the video
    addColorSlider()
    view.addSubview(fritzView)
    view.bringSubviewToFront(fritzView)
    view.bringSubviewToFront(colorSlider)
    fritzView.play()
  }
}

extension VideoHairViewController {
  
  @objc func updateColor(_ slider: ColorSlider) {
    filterOptions.maskColor = slider.color
  }
}
