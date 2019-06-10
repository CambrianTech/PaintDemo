//
//  DataManager.swift
//  Prestige
//
//  Created by Joel Teply on 6/7/16.
//  Copyright © 2016 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift

class DataController: NSObject {
    var brandContext: Realm?
    var projectContext: Realm?
    
    var workingDirectory = DataController.getWriteDirectory()
    
    override init() {
        super.init()
    
        self.brandContext = intitializeDataStore("BrandModel", readOnly: true)
        self.projectContext = intitializeDataStore("ProjectModel", readOnly: false)
        
    }
    
    static func getWriteDirectory() -> URL {
        return try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    static let sharedInstance = DataController()
    
    func intitializeDataStore(_ datastoreName:String, readOnly:Bool = true, failureCount:Int = 0) -> Realm? {
        // This resource is the same name as your xcdatamodeld contained in your project.
        
        //TODO: make work on apple TV

        
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = workingDirectory.appendingPathComponent(datastoreName).appendingPathExtension("realm")
        
       
        let exists = FileManager.default.fileExists(atPath: storeURL.path)

        if (!exists) {
            //bring over from bundle
            let bundleURL = Bundle.main.bundleURL.appendingPathComponent(datastoreName).appendingPathExtension("realm")
            
            if (FileManager.default.fileExists(atPath: bundleURL.path)) {
                print("Store does not yet exist at \(storeURL), but found prepopulated file at \(bundleURL)")
                
                do {
                    try FileManager.default.copyItem(at: bundleURL, to: storeURL)
                    print("Successfully copied prepopulated file")
                } catch {
                    fatalError("Error migrating store: \(error)")
                }
            }
        } else {
            print("Using existing store at \(storeURL)")
        }
        
        var config = Realm.Configuration.defaultConfiguration
        config.fileURL = storeURL
        config.readOnly = readOnly
        config.schemaVersion = 0
        config.migrationBlock = { migration, oldSchemaVersion in
            if config.schemaVersion == oldSchemaVersion {
                
            }
        }
        
        do {
            let realm = try Realm(configuration: config)
            
            return realm
        } catch {
            if (failureCount == 0 && FileManager.default.fileExists(atPath: storeURL.path)) {
                do {
                    //attempt to delete datastore and recreate
                    try FileManager.default.removeItem(atPath: storeURL.path)
                    return intitializeDataStore(datastoreName, readOnly: readOnly, failureCount: failureCount+1)
                } catch {
                    fatalError("Error migrating store: \(error)")
                }
            } else {
                let message = "Error occurred:\(error)"
                fatalError(message)
            }
        }
        
        return nil
    }
    
    class func performTransaction(_ object: Object, context:Realm, block:(()->(Bool))? = nil) -> Bool {

        var success = true
        
        let startedTransaction = !context.isInWriteTransaction
        
        if (startedTransaction) {
            context.beginWrite()
        }
        
        if let block = block {
            success = block()
        }
        
        if (startedTransaction) {
            if (success) {
                do {
                    try context.commitWrite()
                } catch {
                    success = false
                }
            } else {
                context.cancelWrite()
            }
        }
        
        return success
    }
}
