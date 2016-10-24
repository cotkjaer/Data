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
    case sqLite, binary, inMemory
    
    internal var persistentStoreType : String
        {
            switch self
            {
            case .sqLite:
                return NSSQLiteStoreType
            case .inMemory:
                return NSInMemoryStoreType
            case .binary:
                return NSBinaryStoreType
            }
    }
    
    fileprivate func persistentStoreFileURL(_ modelName: String, fileExtension: String, error: NSErrorPointer? = nil) -> URL?
    {
        do
        {
            let documentsDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            return documentsDirectoryURL.appendingPathComponent(modelName + "." + fileExtension)
            
        }
        catch let error
        {
            debugPrint("Error: \(error)")
        }
        
        return nil
    }
    
    internal func persistentStoreFileURL(_ modelName: String, error: NSErrorPointer? = nil) -> URL?
    {
        switch self
        {
        case .sqLite:
            return persistentStoreFileURL(modelName, fileExtension: ".sqlite")
        case .inMemory:
            return nil
        case .binary:
            return persistentStoreFileURL(modelName, fileExtension: ".sqlite")
        }
    }
}
