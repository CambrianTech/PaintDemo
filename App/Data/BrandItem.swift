//
//  BrandMaterial.swift
//
//
//  Created by Joel Teply on 6/7/16.
//
//

import Foundation
import RealmSwift

class BrandItem : Object {
    
    override static func ignoredProperties() -> [String] {
        return ["storeURL", "_view", "view", "color", "text"]
    }
    
    @objc dynamic var itemID: String = ""
    override class func primaryKey() -> String? { return "itemID"}
    
    convenience init(key: String) {
        self.init()
        self.itemID = key
    }
    
    @objc dynamic var parentCategory: BrandCategory? = nil
    @objc dynamic var name = ""
    @objc dynamic var itemCode = ""
    @objc dynamic var orderIndex = 0
    @objc dynamic var storeID = ""
    
    //material, model specific
    @objc dynamic var assetPath = ""
    @objc dynamic var scale: Float = 1.0
    @objc dynamic var reflectivity: Float = 5.0
    
    //paint specific
    @objc dynamic var red = 0
    @objc dynamic var green = 0
    @objc dynamic var blue = 0
    
    @objc dynamic var hue = 0
    @objc dynamic var saturation = 0
    @objc dynamic var brightness = 0
    @objc dynamic var info: String?
    
    @objc dynamic var opacity = 255
    
    @objc enum BrandItemType: Int {
        case Paint
        case Texture
        case Model
    }
    
    @objc dynamic var itemType = BrandItemType.Paint
}
