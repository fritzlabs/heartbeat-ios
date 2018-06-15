//
//  MNISTViewController.swift
//  Heartbeat
//
//  Created by Andrew Barba on 12/28/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreML


class MNISTViewController: UIViewController {

    let model = MNIST().fritz()

    @IBOutlet weak var touchDrawView: TouchDrawView! {
        didSet {
            touchDrawView.delegate = self
            touchDrawView.setWidth(30)
            touchDrawView.setColor(.white)
            touchDrawView.drawStopDelay = 0.3
            touchDrawView.layer.cornerRadius = 4
            touchDrawView.clipsToBounds = true
        }
    }

    @IBOutlet weak var resultView: UIView! {
        didSet {
            resultView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var resultLabel: UILabel! {
        didSet {
            // do something
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MNIST".uppercased()

        resetResultLabel()
    }

    @IBAction func handleResetTapped(_: Any) {
        reset()
    }

    private func reset() {
        touchDrawView.clearDrawing()
        resetResultLabel()
    }

    private func resetResultLabel() {
        resultLabel.text = "Write..."
    }

    private func setResult(_ result: Int?) {
        if let result = result {
            self.resultLabel.text = "“\(result)”"
        } else {
            self.resultLabel.text = "Unknown"
        }
    }
}

extension MNISTViewController: TouchDrawViewDelegate {

    func drawingStopped() {
        let image = touchDrawView.exportDrawing()
        setResult(recogize(image: image))
    }

    private func recogize(image: UIImage) -> Int? {
        let width: NSNumber = 28
        let croppedImage = image.cropped(to: 28)

        guard let input = try? MLMultiArray(shape: [1, width, width], dataType: .float32) else {
            return nil
        }

        for y in 0..<width.intValue {
            for x in 0..<width.intValue {
                let index = (y * width.intValue) + x
                let point = CGPoint(x: x, y: y)
                let color = croppedImage.pixelColor(at: point)
                input[index] = color.a > 0 ? 1 : 0
            }
        }

        let output: MNISTOutput
        do {
            output = try model.prediction(input1: input)
        } catch {
            return nil
        }

        var val: Float = 0
        var index: Int = 0
        for i in 0..<output.output1.count where val < output.output1[i].floatValue {
            val = output.output1[i].floatValue
            index = i
        }

        return index
    }
}

extension UIImage {

    func pixelColor(at point: CGPoint) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        let pngData = self.png()
        let image = UIImage(data: pngData, scale: 1)!
        let width = Int(image.size.width)
        let x = Int(point.x)
        let y = Int(point.y)

        let cfData: CFData = image.cgImage!.dataProvider!.data!
        let pointer = CFDataGetBytePtr(cfData)!

        let bytesPerPixel = 4
        let offset = (x + y * width) * bytesPerPixel
        return (pointer[offset], pointer[offset + 1], pointer[offset + 2], pointer[offset + 3])
    }

    func cropped(to width: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let adjustedWidth: CGFloat = width / scale
        let size = CGSize(width: adjustedWidth, height: adjustedWidth)
        return af_imageAspectScaled(toFill: size)
    }

    func png() -> Data {
        return UIImagePNGRepresentation(self)!
    }
}
