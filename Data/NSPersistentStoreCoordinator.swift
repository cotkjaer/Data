//
//  NSPersistentStoreCoordinator.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 22/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData
import UserInterface
import File
import Error

extension NSPersistentStoreCoordinator
{
    private func preloadSqLite(forModelNamed name: String, inBundle bundle: Bundle) throws
    {
        guard let pathToDocumentsFolder = FileManager.default.documentsFolderPath() else { return }
        
        let _ = try FileManager.default.copy(resourceNamed: name, ofType: "sqlite", toFolder: pathToDocumentsFolder)
        let _ = try FileManager.default.copy(resourceNamed: name, ofType: "sqlite-shm", toFolder: pathToDocumentsFolder)
        let _ = try FileManager.default.copy(resourceNamed: name, ofType: "sqlite-wal", toFolder: pathToDocumentsFolder)
    }
    
    public convenience init(modelName: String, inBundle bundle: Bundle = Bundle.main, storeType: PersistentStoreType = .sqLite, prepopulate: Bool = true) throws
    {
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd")
            else
        {
            throw NSError(domain: "NSPersistentStoreCoordinator", code: 1, description: "Failed to create NSPersistentStoreCoordinator", reason: "Could not find ManagedObject model called \(modelName) in \(bundle)", underlyingError: nil)
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else
        {
            throw NSError(domain: "NSPersistentStoreCoordinator", code: 2, description: "Failed to create NSPersistentStoreCoordinator", reason: "Could not create ManagedObject model from URL \(modelURL)", underlyingError: nil)
        }
        
        self.init(managedObjectModel: model)
        
        do
        {
            if storeType == .sqLite && prepopulate
            {
                try preloadSqLite(forModelNamed: modelName, inBundle: bundle)
            }
            
            try addPersistentStore(ofType: storeType.persistentStoreType, configurationName: nil, at: storeType.persistentStoreFileURL(modelName), options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                                                                                                                             NSInferMappingModelAutomaticallyOption: true])
        }
        catch let internalError as NSError
        {
            throw NSError(domain: "NSPersistentStoreCoordinator", code: 3, description: "Failed to create NSPersistentStoreCoordinator", reason: "Could not create Persistent Store", underlyingError: internalError)
        }
    }
}

