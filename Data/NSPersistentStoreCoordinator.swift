//
//  NSPersistentStoreCoordinator.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 22/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData
import SwiftPlus

extension NSPersistentStoreCoordinator
{
    private func preloadSqLite(forModelNamed name: String, inBundle bundle: Bundle) throws
    {
        guard let pathToDocumentsFolder = FileManager.default.documentsFolderPath() else { return }
        
        let _ = try FileManager.default.copy(resourceNamed: name, ofType: "sqlite", toFolder: pathToDocumentsFolder)
        let _ = try FileManager.default.copy(resourceNamed: name, ofType: "sqlite-shm", toFolder: pathToDocumentsFolder)
        let _ = try FileManager.default.copy(resourceNamed: name, ofType: "sqlite-wal", toFolder: pathToDocumentsFolder)
    }
    
    public convenience init(modelName: String, inBundle bundle: Bundle? = nil, storeType: PersistentStoreType = .sqLite, prepopulate: Bool = true) throws
    {
        let bundle = bundle ?? Bundle.main
        
        if let modelURL = bundle.url(forResource: modelName, withExtension: "momd")
        {
            if let model = NSManagedObjectModel(contentsOf: modelURL)
            {
                self.init(managedObjectModel: model)
                
                do
                {
                    if storeType == .sqLite
                    {
                        try preloadSqLite(forModelNamed: modelName, inBundle: bundle)
                    }
                    
                    try addPersistentStore(ofType: storeType.persistentStoreType, configurationName: nil, at: storeType.persistentStoreFileURL(modelName), options: nil)
                }
                catch let internalError as NSError
                {
                    throw NSError(domain: "NSPersistentStoreCoordinator", code: 3, description: "Failed to create NSPersistentStoreCoordinator", reason: "Could not create Persistent Store", underlyingError: internalError)
                }
                
                return
            }
            else
            {
                throw NSError(domain: "NSPersistentStoreCoordinator", code: 2, description: "Failed to create NSPersistentStoreCoordinator", reason: "Could not create ManagedObject model from URL \(modelURL)", underlyingError: nil)
            }
        }
        else
        {
            throw NSError(domain: "NSPersistentStoreCoordinator", code: 1, description: "Failed to create NSPersistentStoreCoordinator", reason: "Could not find ManagedObject model called \(modelName) in \(bundle)", underlyingError: nil)
        }
    }
}

