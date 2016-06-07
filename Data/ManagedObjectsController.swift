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
    
    func objectForIndexPath(optionalIndexPath: NSIndexPath?) -> NSManagedObject?
    
    func indexPathForObject(optionalObject: NSManagedObject?) -> NSIndexPath?
    
    func indexPathForObjectWithID(optionalID: NSManagedObjectID?) -> NSIndexPath?
}

// MARK: - Navigation

extension ManagedObjectsController 
{
    internal func prepareForSegue<CV:CellsView>(segue: UIStoryboardSegue, sender: AnyObject?, cellsView: CV?)
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
        else if let indexPath = sender as? NSIndexPath
        {
            object = objectForIndexPath(indexPath)
        }
        
        if let controller = segue.destinationViewController as? ManagedObjectDetailController
        {
            prepareDetailController(controller, object: object)
        }
        
        if let navController = segue.destinationViewController as? UINavigationController,
            let controller = navController.managedObjectDetailController
        {
            prepareDetailController(controller, object: object)
        }
    }
    
    internal func prepareDetailController(detailController: ManagedObjectDetailController, object: NSManagedObject?)
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
    func controllerWillChangeContent(controller: FetchedResultsController)
    
    func controllerDidChangeContent(controller: FetchedResultsController)
    
    func controller(controller: FetchedResultsController, didInsertObject object: AnyObject, atIndexPath path: NSIndexPath)
    func controller(controller: FetchedResultsController, didDeleteObject object: AnyObject, atIndexPath path: NSIndexPath)
    func controller(controller: FetchedResultsController, didUpdateObject object: AnyObject, atIndexPath path: NSIndexPath)
    func controller(controller: FetchedResultsController, didMoveObject object: AnyObject, atIndexPath: NSIndexPath, toIndexPath: NSIndexPath)

    func controller(controller: FetchedResultsController, didInsertSection section: Int)
    func controller(controller: FetchedResultsController, didDeleteSection section: Int)
    func controller(controller: FetchedResultsController, didUpdateSection section: Int)
}

internal class FetchedResultsController : NSObject
{
    var delegate : FetchedResultsControllerDelegate? { didSet { fetch() } }
    
    var managedObjectContext : NSManagedObjectContext? { didSet { if oldValue != managedObjectContext { updateFetchedResultsController() } } }
    
    var sectionNameKeyPath: String? { didSet { if oldValue != sectionNameKeyPath { updateFetchedResultsController() } } }
    
    var fetchRequest: NSFetchRequest? { didSet { if oldValue != fetchRequest { updateFetchedResultsController() } } }

    private var fetchedResultsController: NSFetchedResultsController? { didSet { fetch() } }

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
    
    func objectForIndexPath(optionalIndexPath: NSIndexPath?) -> NSManagedObject?
    {
        if let indexPath = optionalIndexPath
        {
            return fetchedResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject
        }
        
        return nil
    }
    
    func indexPathForObject(optionalObject: NSManagedObject?) -> NSIndexPath?
    {
        if let object = optionalObject
        {
            return fetchedResultsController?.indexPathForObject(object)
        }
        
        return nil
    }
    
    func indexPathForObjectWithID(optionalID: NSManagedObjectID?) -> NSIndexPath?
    {
        if let id = optionalID, let object = fetchedResultsController?.fetchedObjects?.find({ $0.objectID == id }) as? NSManagedObject
        {
            return indexPathForObject(object)
        }
        
        return nil
    }
    
    func numberOfObjects(inSection: Int? = nil) -> Int
    {
        if let section = inSection
        {
            return fetchedResultsController?.numberOfObjectsInSection(section) ?? 0
        }
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func titleForSection(section: Int? = nil) -> String?
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
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
    {
        guard controller == self.fetchedResultsController else { return nil }

        return sectionName
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        guard controller == self.fetchedResultsController else { return }

        delegate?.controllerWillChangeContent(self)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        guard controller == self.fetchedResultsController else { return }

        delegate?.controllerDidChangeContent(self)
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        guard controller == self.fetchedResultsController else { return }

        switch type
        {
        case .Insert where newIndexPath != nil:
            
            delegate?.controller(self, didInsertObject: anObject, atIndexPath: newIndexPath!)
            
        case .Delete where indexPath != nil:
            
            delegate?.controller(self, didDeleteObject: anObject, atIndexPath: indexPath!)
            
        case .Update where indexPath != nil:
            
            delegate?.controller(self, didUpdateObject: anObject, atIndexPath: indexPath!)
            
        case .Move where indexPath != nil && newIndexPath != nil:
 
            delegate?.controller(self, didMoveObject: anObject, atIndexPath: indexPath!, toIndexPath: newIndexPath!)

        default:
            debugPrint("funky change-type: \(type) for item-change")
        }
    }
    
    func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        guard controller == self.fetchedResultsController else { return }
        
        switch type
        {
        case .Insert:
         
            delegate?.controller(self, didInsertSection: sectionIndex)
            
        case .Delete:
            
            delegate?.controller(self, didDeleteSection: sectionIndex)
            
        case .Update:
            
            delegate?.controller(self, didUpdateSection: sectionIndex)
            
        default:
            
            debugPrint("funky change-type: \(type) for section-change")
            
        }
    }
}
