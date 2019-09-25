//
//  VideoPreviewView.swift
//  Heartbeat
//
//  Copyright © 2018 Fritz, Inc. All rights reserved.
//
import Foundation
import UIKit


class VideoPreviewView: UIView {
    private var openGLView: OpenGLPixelBufferView

    override init(frame: CGRect) {
        openGLView = OpenGLPixelBufferView(frame: CGRect.zero)
        super.init(frame: frame)

        openGLView.frame = bounds
        openGLView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(openGLView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func display(buffer: CVPixelBuffer!) {
        openGLView.display(buffer)
    }

    public func flushPixelBufferCache() {
        openGLView.flushPixelBufferCache()
    }

    public func reset() {
        openGLView.reset()
    }
}
