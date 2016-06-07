//
//  PersistentStoreType.swift
//  Data
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import CoreData

public enum PersistentStoreType
{
    case SQLite, Binary, InMemory
    
    internal var persistentStoreType : String
        {
            switch self
            {
            case .SQLite:
                return NSSQLiteStoreType
            case .InMemory:
                return NSInMemoryStoreType
            case .Binary:
                return NSBinaryStoreType
            }
    }
    
    private func persistentStoreFileURL(modelName: String, fileExtension: String, error: NSErrorPointer = nil) -> NSURL?
    {
        do
        {
            let documentsDirectoryURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            
            return documentsDirectoryURL.URLByAppendingPathComponent(modelName + "." + fileExtension)
            
        }
        catch let error
        {
            debugPrint("Error: \(error)")
        }
        
        return nil
    }
    
    internal func persistentStoreFileURL(modelName: String, error: NSErrorPointer = nil) -> NSURL?
    {
        switch self
        {
        case .SQLite:
            return persistentStoreFileURL(modelName, fileExtension: ".sqlite")
        case .InMemory:
            return nil
        case .Binary:
            return persistentStoreFileURL(modelName, fileExtension: ".sqlite")
        }
    }
}
