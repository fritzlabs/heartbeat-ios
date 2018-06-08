//  Stroke.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//

import UIKit

/// A drawing stroke
open class Stroke: NSObject {
    
    /// The points that make up the stroke
    internal var points: [CGPoint]

    /// The properties of the stroke
    internal var settings: StrokeSettings

    /// Default initializer
    override public init() {
        points = []
        settings = StrokeSettings()
        super.init()
    }
    
    /// Initialize a stroke with certain points and settings
    public convenience init(points: [CGPoint], settings: StrokeSettings) {
        self.init()
        self.points = points
        self.settings = StrokeSettings(settings)
    }

    /// Used to decode a Stroke with a decoder
    required public convenience init?(coder aDecoder: NSCoder) {
        let points = aDecoder.decodeObject(forKey: Stroke.pointsKey) as? [CGPoint] ?? []
        let settings = aDecoder.decodeObject(forKey: Stroke.settingsKey) as? StrokeSettings ?? StrokeSettings()
        self.init(points: points, settings: settings)
    }
}

// MARK: - NSCoding

extension Stroke: NSCoding {
    internal static let pointsKey = "points"
    internal static let settingsKey = "settings"

    /// Used to encode a Stroke with a coder
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.points, forKey: Stroke.pointsKey)
        aCoder.encode(self.settings, forKey: Stroke.settingsKey)
    }
}
