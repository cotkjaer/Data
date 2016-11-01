//
//  ManagedObjectsController.swift
//  Data
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import CoreData
import UserInterface

public protocol ManagedObjectsController: ManagedObjectDetailControllerDelegate
{
    var managedObjectContext : NSManagedObjectContext? { set get }
    
    // MARK: - Objects
    
    func objectForIndexPath(_ optionalIndexPath: IndexPath?) -> NSManagedObject?
    
    func indexPathForObject(_ optionalObject: NSManagedObject?) -> IndexPath?
    
    func indexPathForObjectWithID(_ optionalID: NSManagedObjectID?) -> IndexPath?
}

// MARK: - Navigation

extension ManagedObjectsController 
{
    internal func prepareForSegue<CV:CellsView>(_ segue: UIStoryboardSegue, sender: Any?, cellsView: CV?)
    {
        var object : NSManagedObject? = nil
        
        if let o = sender as? NSManagedObject
        {
            object = o
        }
        
        if let cell = sender as? CV.Cell,
            let indexPath = cellsView?.indexPathForCell(cell)
        {
            object = objectForIndexPath(indexPath)
        }
        else if let indexPath = sender as? IndexPath
        {
            object = objectForIndexPath(indexPath)
        }
        
        if let controller = segue.destination as? ManagedObjectDetailController
        {
            prepareDetailController(controller, object: object)
        }
        
        if let navController = segue.destination as? UINavigationController,
            let controller = navController.managedObjectDetailController
        {
            prepareDetailController(controller, object: object)
        }
    }
    
    internal func prepareDetailController(_ detailController: ManagedObjectDetailController, object: NSManagedObject?)
    {
        detailController.managedObjectDetailControllerDelegate = self
        detailController.managedObjectContext = managedObjectContext?.childContext()
        
        if let managedObject = object
        {
            detailController.managedObjectID = managedObject.objectID
        }
    }
}

internal protocol FetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: FetchedResultsController)
    
    func controllerDidChangeContent(_ controller: FetchedResultsController)
    
    func controller(_ controller: FetchedResultsController, didInsertObject object: AnyObject, atIndexPath path: IndexPath)
    func controller(_ controller: FetchedResultsController, didDeleteObject object: AnyObject, atIndexPath path: IndexPath)
    func controller(_ controller: FetchedResultsController, didUpdateObject object: AnyObject, atIndexPath path: IndexPath)
    func controller(_ controller: FetchedResultsController, didMoveObject object: AnyObject, atIndexPath: IndexPath, toIndexPath: IndexPath)

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
        if let context = managedObjectContext,
            let fetchRequest = self.fetchRequest
        {
            let frc = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: sectionNameKeyPath,
                cacheName: nil)
            
            frc.delegate = self
            
            fetchedResultsController = frc
            
            fetch()
        }
        else
        {
            fetchedResultsController = nil
        }
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
    
    func objectForIndexPath(_ optionalIndexPath: IndexPath?) -> NSManagedObject?
    {
        if let indexPath = optionalIndexPath
        {
            return fetchedResultsController?.object(at: indexPath)
        }
        
        return nil
    }
    
    func indexPathForObject(_ optionalObject: NSManagedObject?) -> IndexPath?
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
            return indexPathForObject(object)
        }
        
        return nil
    }
    
    func numberOfObjects(_ inSection: Int? = nil) -> Int
    {
        if let section = inSection
        {
            return fetchedResultsController?.sections?.get(section)?.numberOfObjects ?? 0//numberOfObjectsInSection(section) ?? 0
        }
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func titleForSection(_ section: Int? = nil) -> String?
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
    @nonobjc
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String?
    {
        guard controller == self.fetchedResultsController else { return nil }

        return sectionName
    }
    
    @nonobjc func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        guard controller == self.fetchedResultsController else { return }

        delegate?.controllerWillChangeContent(self)
    }
    
    @nonobjc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        guard controller == self.fetchedResultsController else { return }

        delegate?.controllerDidChangeContent(self)
    }
    
    @nonobjc func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
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
