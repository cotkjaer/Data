//
//  FetchedResultsController.swift
//  Data
//
//  Created by Christian Otkjær on 05/12/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import CoreData

internal protocol FetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: FetchedResultsController)
    
    func controllerDidChangeContent(_ controller: FetchedResultsController)
    
    // MARK: - Objects
    
    func controller(_ controller: FetchedResultsController, didInsertObject object: AnyObject, atIndexPath path: IndexPath)
    
    func controller(_ controller: FetchedResultsController, didDeleteObject object: AnyObject, atIndexPath path: IndexPath)
    
    func controller(_ controller: FetchedResultsController, didUpdateObject object: AnyObject, atIndexPath path: IndexPath)
    
    func controller(_ controller: FetchedResultsController, didMoveObject object: AnyObject, atIndexPath: IndexPath, toIndexPath: IndexPath)
    
    // MARK: - Sections
    
    func controller(_ controller: FetchedResultsController, didInsertSection section: Int)
    
    func controller(_ controller: FetchedResultsController, didDeleteSection section: Int)
    
    func controller(_ controller: FetchedResultsController, didUpdateSection section: Int)
}

internal class FetchedResultsController : NSObject
{
    var delegate : FetchedResultsControllerDelegate? { didSet { fetch() } }
    
    var managedObjectContext : NSManagedObjectContext? { didSet { if oldValue != managedObjectContext { updateFetchedResultsController() } } }
    
    var sectionNameKeyPath: String? { didSet { if oldValue != sectionNameKeyPath { updateFetchedResultsController() } } }
    
    var fetchRequest: NSFetchRequest<NSManagedObject>? { didSet { if oldValue != fetchRequest { updateFetchedResultsController() } } }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSManagedObject>? { didSet { fetch() } }
    
    func updateFetchedResultsController()
    {
        guard let context = managedObjectContext,
            let request = fetchRequest else { fetchedResultsController = nil; return }
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        
        frc.delegate = self
        
        fetchedResultsController = frc
        
        fetch()
    }
    
    func fetch()
    {
        do
        {
            try fetchedResultsController?.performFetch()
        }
        catch let error
        {
            print("Error: \(error)")
        }
    }
    
    // MARK: - Objects
    
    func object(at optionalIndexPath: IndexPath?) -> NSManagedObject?
    {
        if let indexPath = optionalIndexPath
        {
            return fetchedResultsController?.object(at: indexPath)
        }
        
        return nil
    }
    
    func indexPath(forObject optionalObject: NSManagedObject?) -> IndexPath?
    {
        if let object = optionalObject
        {
            return fetchedResultsController?.indexPath(forObject: object)
        }
        
        return nil
    }
    
    func indexPathForObjectWithID(_ optionalID: NSManagedObjectID?) -> IndexPath?
    {
        guard let id = optionalID else { return nil }
        
        
        if let object = fetchedResultsController?.fetchedObjects?.find(condition: { $0.objectID == id })
        {
            return indexPath(forObject: object)
        }
        
        return nil
    }
    
    func numberOfObjects(inSection: Int? = nil) -> Int
    {
        if let section = inSection
        {
            return fetchedResultsController?.sections?.get(section)?.numberOfObjects ?? 0
        }
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func title(forSection section: Int? = nil) -> String?
    {
        return fetchedResultsController?.sections?.get(section)?.name
    }
    
    func numberOfSections() -> Int
    {
        return fetchedResultsController?.sections?.count ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FetchedResultsController: NSFetchedResultsControllerDelegate
{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String?
    {
        guard controller == self.fetchedResultsController else { return nil }
        
        return sectionName
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        guard controller == fetchedResultsController else { return }
        
        delegate?.controllerWillChangeContent(self)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        guard controller == fetchedResultsController else { return }
        
        delegate?.controllerDidChangeContent(self)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)
    {
        guard controller == self.fetchedResultsController else { return }
        
        switch type
        {
        case .insert where newIndexPath != nil:
            
            delegate?.controller(self, didInsertObject: anObject as AnyObject, atIndexPath: newIndexPath!)
            
        case .delete where indexPath != nil:
            
            delegate?.controller(self, didDeleteObject: anObject as AnyObject, atIndexPath: indexPath!)
            
        case .update where indexPath != nil:
            
            delegate?.controller(self, didUpdateObject: anObject as AnyObject, atIndexPath: indexPath!)
            
        case .move where indexPath != nil && newIndexPath != nil:
            
            delegate?.controller(self, didMoveObject: anObject as AnyObject, atIndexPath: indexPath!, toIndexPath: newIndexPath!)
            
        default:
            debugPrint("funky change-type: \(type) for item-change")
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType)
    {
        guard controller == self.fetchedResultsController else { return }
        
        switch type
        {
        case .insert:
            
            delegate?.controller(self, didInsertSection: sectionIndex)
            
        case .delete:
            
            delegate?.controller(self, didDeleteSection: sectionIndex)
            
        case .update:
            
            delegate?.controller(self, didUpdateSection: sectionIndex)
            
        default:
            
            debugPrint("funky change-type: \(type) for section-change")
            
        }
    }
}
