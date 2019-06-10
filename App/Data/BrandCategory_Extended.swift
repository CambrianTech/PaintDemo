//
//  BrandCategory_Extended.swift
//  HomeHarmony
//
//  Created by Joel Teply on 11/7/16.
//  Copyright © 2016 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift

internal protocol BrandCategorySelectionDelegate : NSObjectProtocol {
    func categorySelected(_ sender: AnyObject, category:BrandCategory, indexPath:IndexPath)
}

extension BrandCategory: Drawable {
    
    func needsDarkText() -> Bool {
        if let drawable = self.selectedItem {
            return drawable.needsDarkText()
        }
        return false
    }
    
    var text: String? {
        return self.name
    }
    
    var view: UIView? {
        get {
            return self.selectedItem?.view
        }
    }
}

