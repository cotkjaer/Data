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
    
    
    internal var fileExtension : String
    {
        switch self
        {
        case .sqLite:
            return "sqlite"
        case .inMemory:
            return ""
        case .binary:
            return "sqlite" //TODO: fix
        }
    }

    internal func persistentStoreBundledFileURL(_ modelName: String, inBundle bundle : Bundle = Bundle.main) -> URL?
    {
        switch self
        {
        case .inMemory:
            return nil
        default:
            return bundle.url(forResource: modelName, withExtension: fileExtension)
       }
    }

    internal func persistentStoreFileURL(_ modelName: String) throws -> URL?
    {
        switch self
        {
        case .inMemory:
            return nil
        default:
            let documentsDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            return documentsDirectoryURL.appendingPathComponent(modelName + "." + fileExtension)
        }
    }
    
    internal func prePopulate(_ modelName: String, fromBundle bundle : Bundle = Bundle.main) throws
    {
        let documentsFileURL = try persistentStoreFileURL(modelName)
        
        guard documentsFileURL == nil else { return }
        
        
    }
}
