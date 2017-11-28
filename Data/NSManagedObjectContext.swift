//
//  NSManagedObjectContext.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 21/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData

extension NSManagedObjectContext
{
    public convenience init(modelName: String, inBundle: Bundle? = nil, storeType: PersistentStoreType = .sqLite) throws
    {
        let coordinator = try NSPersistentStoreCoordinator(modelName:modelName, inBundle: inBundle ?? Bundle.main, storeType: storeType)
        
        self.init(persistentStoreCoordinator: coordinator)
    }
    
    public convenience init(
        persistentStoreCoordinator: NSPersistentStoreCoordinator,
        concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType)
    {
        self.init(concurrencyType: concurrencyType)
        self.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    public convenience init(
        parentContext: NSManagedObjectContext,
        concurrencyType: NSManagedObjectContextConcurrencyType? = nil)
    {
        let ct = concurrencyType ?? parentContext.concurrencyType
        
        self.init(concurrencyType: ct)
        self.parent = parentContext
    }
    
    public func childContext(_ concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType) -> NSManagedObjectContext
    {
        return NSManagedObjectContext(parentContext: self, concurrencyType: concurrencyType)
    }
    
    public func objectInChildContext<T: NSManagedObject>(_ object: T, concurrencyType: NSManagedObjectContextConcurrencyType? = nil) -> (NSManagedObjectContext, T)?
    {
        if let /*registeredObject*/ _ = registeredObject(for: object.objectID)
        {
            let context = NSManagedObjectContext(parentContext: self, concurrencyType: concurrencyType)
            
            if let childObject = context.object(with: object.objectID) as? T
            {
                return (context, childObject)
            }
        }
        
        return nil
    }
    
    fileprivate func entityDescriptionFor<T: NSManagedObject>(_ type: T.Type) -> NSEntityDescription?
    {
        if #available(iOS 10.0, *) {
            
            if let name = type.entity().name
            {
                return NSEntityDescription.entity(forEntityName: name, in: self)
            }
        }
        else
        {
            if let entityDescription = NSEntityDescription.entity(forEntityName: type.entityName, in: self)
            {
                return entityDescription
            }
        }
        
        return nil
    }
    
    fileprivate func executeFetchRequestLogErrors<R, T: NSManagedObject>(_ request: NSFetchRequest<R>) -> [T]?
    {
        do
        {
            return try self.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as? [T]
        }
        catch let error
        {
            debugPrint("Error: \(error)")
            
        }
        
        return nil
    }
    
    public func fetch<T: NSManagedObject>(_ type: T.Type, predicate:NSPredicate? = nil) -> [T]?
    {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        
        fetchRequest.predicate = predicate ?? NSPredicate(value: true)
        
        return self.executeFetchRequestLogErrors(fetchRequest)
    }
    
    
    /// returns all entities with the given type
    public func all<T: NSManagedObject>(_ type: T.Type) -> [T]?
    {
        return fetch(T.self, predicate: NSPredicate(value: true))
    }
    
    /// counts all entities with the given type
    public func count<T: NSManagedObject>(_ type: T.Type, predicate:NSPredicate? = nil) -> Int
    {
        let fetchRequest = NSFetchRequest<T>()//entityName: T.entityName)
        
        fetchRequest.predicate = predicate ?? NSPredicate(value: true)
        
        do
        {
            return try count(for: fetchRequest)
        }
        catch let error
        {
            debugPrint("Error: \(error)")
        }
        
        return 0
    }
    
    public func any<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil) -> T?
    {
        let fetchRequest = NSFetchRequest<T>()
        fetchRequest.entity = entityDescriptionFor(type)
        fetchRequest.predicate = predicate //NSPredicate(value: true)
        fetchRequest.fetchLimit = 1
        
        return executeFetchRequestLogErrors(fetchRequest)?.last as? T
    }
    
    public func first<T: NSManagedObject>(_ type: T.Type, sortDescriptors: [NSSortDescriptor], predicate:NSPredicate? = nil) -> T?
    {
        let fetchRequest = NSFetchRequest<T>()
        
        fetchRequest.entity = entityDescriptionFor(type)
        fetchRequest.predicate = predicate // ?? NSPredicate(value: true)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchLimit = 1
        
        return executeFetchRequestLogErrors(fetchRequest)?.first as? T
    }
}


// MARK: - Save

extension NSManagedObjectContext
{
    public func saveSafely() -> (Bool, NSError?)
    {
        if hasChanges
        {
            do
            {
                try save()
                return (true, nil)
            }
            catch let error as NSError
            {
                return (false, error)
            }
        }
        
        return (false, nil)
    }
    
    @discardableResult
    public func saveWithAlert() -> Bool
    {
        let (saved, error) = saveSafely()
        
        error?.presentAsAlert()
        
        return saved
    }
}
