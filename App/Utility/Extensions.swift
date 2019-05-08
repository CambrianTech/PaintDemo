//
//  Extensions.swift
//  HarmonyApp
//
//  Created by joseph on 4/11/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import CoreGraphics



extension UINavigationController {
    
    public func useTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
    }
    
    public func stopUsingTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for:UIBarMetrics.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }
}


public extension URL {
    public static func fromString(_ string: String) -> URL? {
        return URL(string: string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
    }
}

public extension UIColor {
    public var isLight: Bool {
        get {
            return hsba.b > 0.77 && hsba.s < 0.3
        }
    }
    
    var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) = (0, 0, 0, 0)
        self.getHue(&(hsba.h), saturation: &(hsba.s), brightness: &(hsba.b), alpha: &(hsba.a))
        return hsba
    }
}

public extension Int {
    /// Returns a random Int point number between 0 and current value
    public var random:Int {
        get {
            return random(self)
        }
    }
    
    /**
     Random integer between 0 and n-1.
     
     - parameter n: Int
     
     - returns: Int
     */
    public func random(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    /**
     Random integer between min and max
     
     - parameter min: Int
     - parameter max: Int
     
     - returns: Int
     */
    public func random(min: Int, max: Int) -> Int {
        return random((max - min) + 1) + min
    }
}
public extension Double {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random number Double
     
     - parameter min: Double
     - parameter max: Double
     
     - returns: Double
     */
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}
public extension Float {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Float {
        get {
            return Float(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random num Float
     
     - parameter min: Float
     - parameter max: Float
     
     - returns: Float
     */
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}
public extension CGFloat {
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign:CGFloat {
        get {
            return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
        }
    }
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:CGFloat {
        get {
            return CGFloat(Float.random)
        }
    }
    /**
     Create a random num CGFloat
     
     - parameter min: CGFloat
     - parameter max: CGFloat
     
     - returns: CGFloat random number
     */
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}
