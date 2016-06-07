//
//  FetchedResultsCollectionViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreData
import Collections
import UserInterface

public class FetchedResultsCollectionViewController: UICollectionViewController, FetchedResultsControllerDelegate, ManagedObjectsController
{
    private lazy var fetchedResultsController : FetchedResultsController = { let c = FetchedResultsController(); c.delegate = self; return c }()
    
    /// Set this if you are updating the tabledata "manually" (e.g. when rearranging)
    public var ignoreControllerChanges: Bool = false
    
    public var managedObjectContext : NSManagedObjectContext?
        {
        set { fetchedResultsController.managedObjectContext = newValue }
        get { return fetchedResultsController.managedObjectContext }
    }
    public var sectionNameKeyPath : String?
        {
        set { fetchedResultsController.sectionNameKeyPath = newValue }
        get { return fetchedResultsController.sectionNameKeyPath }
    }
    public var fetchRequest : NSFetchRequest?
        {
        set { fetchedResultsController.fetchRequest = newValue }
        get { return fetchedResultsController.fetchRequest }
    }
    
    // MARK: - Objects
    
    public func objectForIndexPath(optionalIndexPath: NSIndexPath?) -> NSManagedObject?
    {
        return fetchedResultsController.objectForIndexPath(optionalIndexPath)
    }
    
    public func indexPathForObject(optionalObject: NSManagedObject?) -> NSIndexPath?
    {
        return fetchedResultsController.indexPathForObject(optionalObject)
    }
    
    public func indexPathForObjectWithID(optionalID: NSManagedObjectID?) -> NSIndexPath?
    {
        return fetchedResultsController.indexPathForObjectWithID(optionalID)
    }
    
    public func numberOfObjects(inSection: Int? = nil) -> Int
    {
        return fetchedResultsController.numberOfObjects(inSection)
    }
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        fetchedResultsController.fetch()
        
        setupRearranging()
    }
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.numberOfSections()
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchedResultsController.numberOfObjects(section)
    }
    
    public func cellReuseIdentifierForIndexPath(indexPath: NSIndexPath) -> String
    {
        return "Cell"
    }
    
    public func configureCell(cell: UICollectionViewCell, forObject object: NSManagedObject?, atIndexPath indexPath: NSIndexPath)
    {
        debugPrint("override configureCell")
    }
    
    final override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
        
        configureCell(cell, forObject: objectForIndexPath(indexPath), atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - ManagedObjectDetailControllerDelegate
    
    public func managedObjectDetailControllerDidFinish(controller: ManagedObjectDetailController, saved: Bool)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        prepareForSegue(segue, sender: sender, cellsView: collectionView)
    }
    
    // MARK: - FetchedResultsControllerDelegate
    
    var blockOperation : NSBlockOperation?
    var shouldReloadCollectionView = false { didSet { if shouldReloadCollectionView { blockOperation = nil } } }
    
    
    func controllerWillChangeContent(controller: FetchedResultsController)
    {
        guard !ignoreControllerChanges else { return }
        
        shouldReloadCollectionView = false
        blockOperation = NSBlockOperation()
    }

    func controllerDidChangeContent(controller: FetchedResultsController)
    {
        // Checks if we should reload the collection view to aleviate a bug @ http://openradar.appspot.com/12954582
        if shouldReloadCollectionView
        {
            collectionView?.reloadData()
        }
        else if let blockOperation = blockOperation, let collectionView = collectionView
        {
            collectionView.performBatchUpdates(blockOperation.start, completion: nil)
        }
    }

    func controller(controller: FetchedResultsController, didInsertSection section: Int)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.insertSection( section ) }
    }
    
    func controller(controller: FetchedResultsController, didDeleteSection section: Int)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.deleteSection( section ) }
    }
    
    func controller(controller: FetchedResultsController, didUpdateSection section: Int)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.reloadSection( section ) }
    }
    
    func controller(controller: FetchedResultsController, didInsertObject object: AnyObject, atIndexPath path: NSIndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        if collectionView.numberOfSections() > 0
        {
            if collectionView.numberOfItemsInSection( path.section ) == 0
            {
                shouldReloadCollectionView = true
            }
            else
            {
                blockOperation?.addExecutionBlock { collectionView.insertItemAtIndexPath( path ) }
            }
        }
        else
        {
            shouldReloadCollectionView = true
        }
    }
    
    func controller(controller: FetchedResultsController, didDeleteObject object: AnyObject, atIndexPath path: NSIndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        if collectionView.numberOfItemsInSection( path.section ) == 1
        {
            shouldReloadCollectionView = true
        }
        else
        {
            blockOperation?.addExecutionBlock { collectionView.deleteItemAtIndexPath( path ) }
        }
    }
    
    func controller(controller: FetchedResultsController, didUpdateObject object: AnyObject, atIndexPath path: NSIndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.reloadItemAtIndexPath( path ) }
        
    }
    
    func controller(controller: FetchedResultsController, didMoveObject object: AnyObject, atIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.moveItemFromIndexPath( atIndexPath, toIndexPath: toIndexPath ) }
    }

    
    /*
    public func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        if let collectionView = collectionView
        {
            switch type
            {
            case .Insert:
                
                blockOperation?.addExecutionBlock { collectionView.insertSection( sectionIndex ) }
                
            case .Delete:
                
                blockOperation?.addExecutionBlock { collectionView.deleteSection( sectionIndex ) }
                
            case .Update:
                
                blockOperation?.addExecutionBlock { collectionView.reloadSection( sectionIndex ) }
                
            default:
                
                debugPrint("funky change-type: \(type) for section-change")
                
            }
        }
    }
    
    public func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        if let collectionView = self.collectionView
        {
            switch type
            {
            case .Insert where newIndexPath != nil:
                
                if collectionView.numberOfSections() > 0
                {
                    if collectionView.numberOfItemsInSection( newIndexPath?.section ) == 0
                    {
                        shouldReloadCollectionView = true
                    }
                    else
                    {
                        blockOperation?.addExecutionBlock { collectionView.insertItemAtIndexPath( newIndexPath ) }
                    }
                }
                else
                {
                    shouldReloadCollectionView = true
                }
                
            case .Delete where indexPath != nil:
                
                if collectionView.numberOfItemsInSection( indexPath!.section ) == 1
                {
                    shouldReloadCollectionView = true
                }
                else
                {
                    blockOperation?.addExecutionBlock { collectionView.deleteItemAtIndexPath( indexPath ) }
                }
                
            case .Update where indexPath != nil:
                
                blockOperation?.addExecutionBlock { collectionView.reloadItemAtIndexPath( indexPath ) }
                
            case .Move where indexPath != nil && newIndexPath != nil:
                
                blockOperation?.addExecutionBlock { collectionView.moveItemFromIndexPath( indexPath, toIndexPath: newIndexPath ) }
                
            default:
                debugPrint("funky change-type: \(type) for item-change")
                
            }
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if shouldReloadCollectionView
        {
            collectionView?.reloadData()
        }
        else if let blockOperation = blockOperation, let collectionView = collectionView
        {
            collectionView.performBatchUpdates(blockOperation.start, completion: nil)
        }
    }
*/
    
//    public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
//    {
//        return sectionName
//    }
    
    // MARK: - Rearranging
    
    var cellBeingDragged : UICollectionViewCell?
    var cachedCellMasksToBounds = false
    var cachedCellCornerRadius = CGFloat(0)
    var cachedCellShadowOffset = CGSize(width: 0, height: 5)
    var cachedCellShadowRadius = CGFloat(5)
    var cachedCellShadowOpacity = Float(0.4)
    var cachedCellTransform = CGAffineTransformIdentity
    
    func setupRearranging()
    {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FetchedResultsCollectionViewController.handleLongGesture(_:)))
        collectionView?.addGestureRecognizer(longPressGesture)
    }
    
    @available(iOS 9.0, *)
    func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        if let collectionView = self.collectionView
        {
            let location = gesture.locationInView(collectionView)
            
            switch(gesture.state)
            {
            case .Began:
                
                collectionView.superview?.bringSubviewToFront(collectionView)
                
                if let indexPathForPressedItem = collectionView.indexPathForItemAtPoint(location)
                {
                    if let cell = collectionView.cellForItemAtIndexPath(indexPathForPressedItem)
                    {
                        cellBeingDragged = cell
                        cachCell(cell)
                    }
                    collectionView.beginInteractiveMovementForItemAtIndexPath(indexPathForPressedItem)
                }
                
            case .Changed:
                
                debugPrint(gesture.view)
                
                collectionView.updateInteractiveMovementTargetPosition(location)
                
            case .Ended:
                restoreCellBeingDragged()
                collectionView.endInteractiveMovement()
                
            default:
                restoreCellBeingDragged()
                collectionView.cancelInteractiveMovement()
            }
        }
    }
    
    func cachCell(cell: UICollectionViewCell)
    {
        cellBeingDragged = cell
        
        cachedCellCornerRadius = cell.layer.cornerRadius
        cachedCellMasksToBounds = cell.layer.masksToBounds
        cachedCellShadowOffset = cell.layer.shadowOffset
        cachedCellShadowOpacity = cell.layer.shadowOpacity
        cachedCellShadowRadius = cell.layer.shadowRadius
        cachedCellTransform = cell.transform
        
        UIView.animateWithDuration(0.25)
            {
                cell.layer.masksToBounds = false
                cell.layer.cornerRadius = 0
                cell.layer.shadowOffset = CGSize(width: 0, height: 5)
                cell.layer.shadowRadius = 5
                cell.layer.shadowOpacity = 0.4
                cell.transform = CGAffineTransformScale(cell.transform, 1.05, 1.05)
        }
    }
    
    func restoreCellBeingDragged()
    {
        if let cell = cellBeingDragged
        {
            UIView.animateWithDuration(0.25)
                {
                    cell.layer.masksToBounds = self.cachedCellMasksToBounds
                    cell.layer.cornerRadius = self.cachedCellCornerRadius
                    cell.layer.shadowOffset = self.cachedCellShadowOffset
                    cell.layer.shadowRadius = self.cachedCellShadowRadius
                    cell.layer.shadowOpacity = self.cachedCellShadowOpacity
                    cell.transform = self.cachedCellTransform
            }
        }
    }
    
    override public func collectionView(collectionView: UICollectionView,
        moveItemAtIndexPath sourceIndexPath: NSIndexPath,
        toIndexPath destinationIndexPath: NSIndexPath)
    {
        ignoreControllerChanges = true
        
        guard let o1 = objectForIndexPath(destinationIndexPath) else { return }
        guard let o2 = objectForIndexPath(sourceIndexPath) else { return }
        
        guard let key = fetchRequest?.sortDescriptors?.first?.key else { return }
        
        guard let v1 = o1.valueForKey(key), let v2 = o2.valueForKey(key) else { return }
        
        o2.setValue(v1, forKey: key)
        o1.setValue(v2, forKey: key)
        
        ignoreControllerChanges = false
        
        fetchedResultsController.fetch()
    }
    
}
