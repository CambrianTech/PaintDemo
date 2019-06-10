//
//  Favorites.swift
//  HarmonyApp
//
//  Created by Jaremy Longley on 4/26/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift


class Favorites : Object {
    
    static let sharedInstance = Favorites()
    weak var delegate: sharedFavoritesDelegate?
    weak var bottomDelegate: sharedFavoritesDelegate?
    
    @objc dynamic var id = UUID().uuidString
    override class func primaryKey() -> String? { return "id" }
    
    let list = List<Asset>()
    
    @objc dynamic var created = Date()
    @objc dynamic var modified = Date()
    
    dynamic var isEmpty: Bool {
        get {
            return self.list.isEmpty
        }
    }
    
    var currentFavorites:Favorites {
        get {
            guard let context = DataController.sharedInstance.projectContext
                else {
                    fatalError()
            }
            
            if let favs = DataController.sharedInstance.projectContext?.objects(Favorites.self).first {
                return favs
            } else {
                let favs = Favorites()
                try! context.write {
                    context.add(favs)
                }
                return favs
            }
        }
    }
    
    var sortedList:Results<Asset> {
        get {
            return currentFavorites.list.sorted(byKeyPath: "modified", ascending: false)
        }
    }
    
    func getAsCategory() -> BrandCategory {
        let category = BrandCategory()
        category.name = "Favorites"
        
        for asset in self.sortedList {
            if let item = asset.getItem() {
                category.items.append(item)
            }
        }
        return category
    }
    
    
    
    func isInFavorites(_ item: BrandItem) -> Bool {
        let favorites = currentFavorites
        for asset in favorites.list {
            if asset.itemID == item.itemID {
                print("item found")
                return true
            }
        }
        return false
    }
    
    func toggle(_ item: BrandItem) {
        if !isInFavorites(item) {
            append(item)
            delegate?.updateFavorites(item)
            bottomDelegate?.updateFavorites(item)
        } else {
            remove(item)
            delegate?.updateFavorites(item)
            bottomDelegate?.updateFavorites(item)
        }
    }
    
    func append(_ item: BrandItem) {
        if(isInFavorites(item)) { return }
        let favorites = currentFavorites
        
        
        try! favorites.realm?.write {
            print("creating new favorite asset")
            let asset = Asset()
            asset.itemID = item.itemID
            favorites.list.append(asset)
            favorites.modified = Date()
        }
    }
    
    func remove(_ item: BrandItem) -> Bool {
        
        let favorites = currentFavorites
        var found = false
        
        for (index, asset) in favorites.list.enumerated() {
            if asset.itemID == item.itemID {
                try! favorites.realm?.write {
                    favorites.list.remove(at: index)
                    favorites.realm?.delete(asset)
                    favorites.modified = Date()
                }
                print("item found and deleted")
                found = true
                break
            }
        }
        return found
    }
}








