//
//  UserPreferences.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/15/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class UserPreferences {
    fileprivate static var singleton : UserPreferences!
    
    internal class func sharedPreferences() -> UserPreferences {
        if (singleton == nil) {
            singleton = UserPreferences()
        }
        return singleton
    }
    
//    var hasSeenStillFinalInstructions:Bool {
//        get {
//            if let value = NSUserDefaults.standardUserDefaults().valueForKey("hasSeenStillFinalInstructions") as? Bool {
//                return value
//            }
//            return true
//        }
//        set {
//            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "hasSeenStillFinalInstructions")
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }
//    }
}
