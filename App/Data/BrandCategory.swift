//
//  BrandCategory.swift
//
//
//  Created by Joel Teply on 6/7/16.
//
//

import Foundation
import RealmSwift

class BrandCategory : Object {
    
    override static func ignoredProperties() -> [String] {
        return ["paint", "childPaints", "_cachedChildPaints", "texture", "childTextures", "_cachedChildTextures", "defaultCategory", "view", "_view"]
    }
    
    @objc dynamic var categoryID = UUID().uuidString
    @objc dynamic var parentCategory: BrandCategory? = nil
    
    override class func primaryKey() -> String? { return "categoryID"}
    
    //drawable
    @objc dynamic var assetPath = ""
    @objc dynamic var isIndoor = true
    @objc dynamic var isOutdoor = false
    @objc dynamic var name = ""
    @objc dynamic var orderIndex = 0
    @objc dynamic var selectedItem: BrandItem? = nil
    
    let items = List<BrandItem>()
    let subCategories = List<BrandCategory>()
}
