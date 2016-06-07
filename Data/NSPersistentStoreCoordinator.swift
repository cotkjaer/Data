//
//  NSPersistentStoreCoordinator.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 22/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData
import Error

extension NSPersistentStoreCoordinator
{
    public convenience init(modelName: String, inBundle bundle: NSBundle? = nil, storeType: PersistentStoreType = .SQLite) throws
    {
        if let modelURL = (bundle ?? NSBundle.mainBundle()).URLForResource(modelName, withExtension: "momd")
        {
            if let model = NSManagedObjectModel(contentsOfURL: modelURL)
            {
                self.init(managedObjectModel: model)
                
                do
                {
                    try addPersistentStoreWithType(storeType.persistentStoreType, configuration: nil, URL: storeType.persistentStoreFileURL(modelName), options: nil)
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

