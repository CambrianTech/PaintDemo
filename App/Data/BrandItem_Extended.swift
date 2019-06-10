//
//  BrandItem_Extended.swift
//  HomeHarmony
//
//  Created by Joel Teply on 11/7/16.
//  Copyright © 2016 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift

internal protocol ItemSelectionDelegate : NSObjectProtocol {
    func itemSelected(_ sender: AnyObject, item:BrandItem)
    func categoryScrolledTo(_ sender: AnyObject, category:BrandCategory, indexPath:IndexPath)
}

extension BrandItem: Drawable {
    
    var isFlooring:Bool {
        get {
            return self.itemType == .Texture
        }
    }
    
    var isPaint:Bool {
        get {
            return self.itemType == .Paint
        }
    }
    
    static let metaDataItemIDField = "materialID"
    
    func needsDarkText() -> Bool {
        return ImageManager.needsDarkText(CGFloat(hue) / 255.0,
                                          saturation: CGFloat(saturation) / 255.0,
                                          brightness: CGFloat(brightness) / 255.0)
    }

    
    func getRootCategory() -> BrandCategory {
        var category = self.parentCategory
        while(category?.parentCategory != nil) {
            category = category?.parentCategory
        }
        return (category)!
    }
    
    class func itemForID(_ id: String) -> BrandItem? {
        if id.count > 0 {
            return DataController.sharedInstance.brandContext?.object(ofType: BrandItem.self, forPrimaryKey: id)
        }
        return nil
    }
    
    class func randomItem() -> BrandItem? {
        if let realm = DataController.sharedInstance.brandContext {
            let items = realm.objects(BrandItem.self)
            let item = items[items.count.random]
            return item
        }
        return nil
    }
    
    class func randomPaint() -> BrandItem? {
        if let realm = DataController.sharedInstance.brandContext {
            let predicate = NSPredicate(format: "itemType == %d",
                                        BrandItemType.Paint.rawValue)
            let items = realm.objects(BrandItem.self).filter(predicate)
            return items[items.count.random]
        }
        return nil
    }
    
    var text: String? {
        return self.name
    }
    
    var color:UIColor {
        get {
            return UIColor(red: CGFloat(self.red) / 255.0,
                           green: CGFloat(self.green) / 255.0,
                           blue: CGFloat(self.blue) / 255.0,
                           alpha: CGFloat(self.opacity) / 255.0)
        }
        set {
            var fRed : CGFloat = 0
            var fGreen : CGFloat = 0
            var fBlue : CGFloat = 0
            var fAlpha: CGFloat = 0
            if !newValue.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
                return
            }
            
            self.red = Int(fRed * 255.0)
            self.green = Int(fGreen * 255.0)
            self.blue = Int(fBlue * 255.0)
            self.opacity = Int(fAlpha * 255.0)
            
            var fHue : CGFloat = 0
            var fSat : CGFloat = 0
            var fBright : CGFloat = 0
            
            if !newValue.getHue(&fHue, saturation: &fSat, brightness: &fBright, alpha: &fAlpha) {
                return
            }
            
            self.hue = Int(fHue * 360.0)
            self.saturation = Int(fSat * 255.0)
            self.brightness = Int(fBright * 255.0)
        }
    }
    
    class func getCloseColors(_ color: UIColor, range:Int!=20) -> Results<BrandItem> {
        
        let rgba = colorRGBA(color)
        let red = Int(rgba[0] * 255)
        let green = Int(rgba[1] * 255)
        let blue = Int(rgba[2] * 255)
        
        let context = DataController.sharedInstance.brandContext
        let predicate = NSPredicate(format: "(red BETWEEN {%i, %i}) AND (green BETWEEN {%i, %i}) AND (blue BETWEEN {%i, %i})",
                                    red - range, red + range, green - range, green + range, blue - range, blue + range)
        let near = context?.objects(BrandItem.self).filter(predicate)
        print("near colors count: \(near!.count)")
        return near!
    }
    
    class func getClosestMatch(_ color: UIColor, range:Int!=20) -> BrandItem? {
        let closest = getCloseColors(color, range:range)
        
        var nearest = CGFloat.greatestFiniteMagnitude
        var bestMatch: BrandItem? = nil
        
        for item in closest {
            let distance = distanceBetweenColors(item.color, color2: color)
            if  distance < nearest {
                nearest = distance
                bestMatch = item
            }
        }
        
        if let _ = bestMatch {
            print("distance of nearest color: \(nearest)")
        }
        
        return bestMatch
    }
    
    var isInFavorites: Bool {
        get {
            return Favorites.sharedInstance.isInFavorites(self)
        }
    }
    
    
    var view: UIView? {
        get {
            let view = UIImageView()
            view.backgroundColor = self.color
            view.kf.setImage(with: getThumbnailPath())
            return view
        }
    }
    
    func gotoStore() {
        UIApplication.shared.openURL(self.storeURL)
    }
    
    dynamic var storeURL:URL {
        return getStoreURL(self.storeID)
    }
    
    func getAssetPath() -> URL {
        var url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        url = url.appendingPathComponent("dbassets")
        url = url.appendingPathComponent(self.assetPath)
        return url
    }

    func getDiffusePath() -> URL? {
        if self.itemType == .Texture {
            var url = getAssetPath()
            url = url.appendingPathComponent("Base_Color.jpg")
            return url
        }
        return nil
    }
    
    func getThumbnailPath() -> URL? {
        if self.itemType == .Texture {
            var url = getAssetPath()
            url = url.appendingPathComponent("Thumbnail.jpg")
            return url
        }
        return nil
    }
}

