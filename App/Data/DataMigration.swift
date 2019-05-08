//
//  DataMigration.swift
//  HomeHarmony
//
//  Created by Joel Teply on 10/2/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift

func migrateZeroToOne(migration: Migration) {
        
    //projects
    migration.enumerateObjects(ofType: VisualizerProject.className()) {
        oldObject, newObject in
        
    }
    
//    //BrandCategory
//    migration.renameProperty(onType: BrandCategory.className(), from: "categoryID", to: "id")
//    migration.renameProperty(onType: BrandCategory.className(), from: "selectedItem", to: "displayItem")
//    
//    //BrandItem
//    migration.renameProperty(onType: BrandItem.className(), from: "itemID", to: "id")
//    migration.renameProperty(onType: BrandItem.className(), from: "itemType", to: "type")
//    migration.renameProperty(onType: BrandItem.className(), from: "itemCode", to: "storeID")
//    migration.renameProperty(onType: BrandItem.className(), from: "storeID", to: "storeLink")
    
}

