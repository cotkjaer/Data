//
//  FetchedResultsCollectionViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreData
import Plus
import UserInterface

open class FetchedResultsCollectionViewController: UICollectionViewController, FetchedResultsControllerDelegate, ManagedObjectsController
{
    fileprivate lazy var fetchedResultsController : FetchedResultsController = { let c = FetchedResultsController(); c.delegate = self; return c }()
    
    /// Set this if you are updating the tabledata "manually" (e.g. when rearranging)
    open var ignoreControllerChanges: Bool = false
    
    open var managedObjectContext : NSManagedObjectContext?
        {
        set { fetchedResultsController.managedObjectContext = newValue }
        get { return fetchedResultsController.managedObjectContext }
    }
    open var sectionNameKeyPath : String?
        {
        set { fetchedResultsController.sectionNameKeyPath = newValue }
        get { return fetchedResultsController.sectionNameKeyPath }
    }
    open var fetchRequest : NSFetchRequest<NSManagedObject>?
        {
        set { fetchedResultsController.fetchRequest = newValue }
        get { return fetchedResultsController.fetchRequest }
    }
    
    // MARK: - Objects
    
    open func objectForIndexPath(_ optionalIndexPath: IndexPath?) -> NSManagedObject?
    {
        return fetchedResultsController.objectForIndexPath(optionalIndexPath)
    }
    
    open func indexPathForObject(_ optionalObject: NSManagedObject?) -> IndexPath?
    {
        return fetchedResultsController.indexPathForObject(optionalObject)
    }
    
    open func indexPathForObjectWithID(_ optionalID: NSManagedObjectID?) -> IndexPath?
    {
        return fetchedResultsController.indexPathForObjectWithID(optionalID)
    }
    
    open func numberOfObjects(_ inSection: Int? = nil) -> Int
    {
        return fetchedResultsController.numberOfObjects(inSection)
    }
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        fetchedResultsController.fetch()
        
        setupRearranging()
    }
    
    // MARK: UICollectionViewDataSource
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.numberOfSections()
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchedResultsController.numberOfObjects(section)
    }
    
    open func cellReuseIdentifierForIndexPath(_ indexPath: IndexPath) -> String
    {
        return "Cell"
    }
    
    open func configureCell(_ cell: UICollectionViewCell, forObject object: NSManagedObject?, atIndexPath indexPath: IndexPath)
    {
        debugPrint("override configureCell")
    }
    
    final override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifierForIndexPath(indexPath), for: indexPath)
        
        configureCell(cell, forObject: objectForIndexPath(indexPath), atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - ManagedObjectDetailControllerDelegate
    
    open func managedObjectDetailControllerDidFinish(_ controller: ManagedObjectDetailController, saved: Bool)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        prepareForSegue(segue, sender: sender, cellsView: collectionView)
    }
    
    // MARK: - FetchedResultsControllerDelegate
    
    var blockOperation : BlockOperation?
    var shouldReloadCollectionView = false { didSet { if shouldReloadCollectionView { blockOperation = nil } } }
    
    
    func controllerWillChangeContent(_ controller: FetchedResultsController)
    {
        guard !ignoreControllerChanges else { return }
        
        shouldReloadCollectionView = false
        blockOperation = BlockOperation()
    }

    func controllerDidChangeContent(_ controller: FetchedResultsController)
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

    func controller(_ controller: FetchedResultsController, didInsertSection section: Int)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.insert(sectionAt: section) }
    }
    
    func controller(_ controller: FetchedResultsController, didDeleteSection section: Int)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.delete(sectionAt: section) }
    }
    
    func controller(_ controller: FetchedResultsController, didUpdateSection section: Int)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.reload(sectionAt: section) }
    }
    
    func controller(_ controller: FetchedResultsController, didInsertObject object: AnyObject, atIndexPath path: IndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        if collectionView.numberOfSections > 0
        {
            if collectionView.numberOfItems( inSection: (path as NSIndexPath).section ) == 0
            {
                shouldReloadCollectionView = true
            }
            else
            {
                blockOperation?.addExecutionBlock { collectionView.insert(itemAt: path ) }
            }
        }
        else
        {
            shouldReloadCollectionView = true
        }
    }
    
    func controller(_ controller: FetchedResultsController, didDeleteObject object: AnyObject, atIndexPath path: IndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        if collectionView.numberOfItems( inSection: (path as NSIndexPath).section ) == 1
        {
            shouldReloadCollectionView = true
        }
        else
        {
            blockOperation?.addExecutionBlock { collectionView.delete(itemAt: path) }
        }
    }
    
    func controller(_ controller: FetchedResultsController, didUpdateObject object: AnyObject, atIndexPath path: IndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.reloadItems( at: [ path ] ) }
        
    }
    
    func controller(_ controller: FetchedResultsController, didMoveObject object: AnyObject, atIndexPath: IndexPath, toIndexPath: IndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }

        blockOperation?.addExecutionBlock { collectionView.moveItem(at: atIndexPath, to: toIndexPath ) }
    }
    
    // MARK: - Rearranging
    
    var cellBeingDragged : UICollectionViewCell?
    var cachedCellMasksToBounds = false
    var cachedCellCornerRadius = CGFloat(0)
    var cachedCellShadowOffset = CGSize(width: 0, height: 5)
    var cachedCellShadowRadius = CGFloat(5)
    var cachedCellShadowOpacity = Float(0.4)
    var cachedCellTransform = CGAffineTransform.identity
    
    func setupRearranging()
    {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FetchedResultsCollectionViewController.handleLongGesture(_:)))
        collectionView?.addGestureRecognizer(longPressGesture)
    }
    
    @available(iOS 9.0, *)
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer)
    {
        if let collectionView = self.collectionView
        {
            let location = gesture.location(in: collectionView)
            
            switch(gesture.state)
            {
            case .began:
                
                collectionView.superview?.bringSubview(toFront: collectionView)
                
                if let indexPathForPressedItem = collectionView.indexPathForItem(at: location)
                {
                    if let cell = collectionView.cellForItem(at: indexPathForPressedItem)
                    {
                        cellBeingDragged = cell
                        cachCell(cell)
                    }
                    collectionView.beginInteractiveMovementForItem(at: indexPathForPressedItem)
                }
                
            case .changed:
                
                debugPrint(gesture.view)
                
                collectionView.updateInteractiveMovementTargetPosition(location)
                
            case .ended:
                restoreCellBeingDragged()
                collectionView.endInteractiveMovement()
                
            default:
                restoreCellBeingDragged()
                collectionView.cancelInteractiveMovement()
            }
        }
    }
    
    func cachCell(_ cell: UICollectionViewCell)
    {
        cellBeingDragged = cell
        
        cachedCellCornerRadius = cell.layer.cornerRadius
        cachedCellMasksToBounds = cell.layer.masksToBounds
        cachedCellShadowOffset = cell.layer.shadowOffset
        cachedCellShadowOpacity = cell.layer.shadowOpacity
        cachedCellShadowRadius = cell.layer.shadowRadius
        cachedCellTransform = cell.transform
        
        UIView.animate(withDuration: 0.25, animations: {
                cell.layer.masksToBounds = false
                cell.layer.cornerRadius = 0
                cell.layer.shadowOffset = CGSize(width: 0, height: 5)
                cell.layer.shadowRadius = 5
                cell.layer.shadowOpacity = 0.4
                cell.transform = cell.transform.scaledBy(x: 1.05, y: 1.05)
        })
            
    }
    
    func restoreCellBeingDragged()
    {
        if let cell = cellBeingDragged
        {
            UIView.animate(withDuration: 0.25, animations: {
                    cell.layer.masksToBounds = self.cachedCellMasksToBounds
                    cell.layer.cornerRadius = self.cachedCellCornerRadius
                    cell.layer.shadowOffset = self.cachedCellShadowOffset
                    cell.layer.shadowRadius = self.cachedCellShadowRadius
                    cell.layer.shadowOpacity = self.cachedCellShadowOpacity
                    cell.transform = self.cachedCellTransform
            })
                
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath)
    {
        ignoreControllerChanges = true
        
        guard let o1 = objectForIndexPath(destinationIndexPath) else { return }
        guard let o2 = objectForIndexPath(sourceIndexPath) else { return }
        
        guard let key = fetchRequest?.sortDescriptors?.first?.key else { return }
        
        guard let v1 = o1.value(forKey: key), let v2 = o2.value(forKey: key) else { return }
        
        o2.setValue(v1, forKey: key)
        o1.setValue(v2, forKey: key)
        
        ignoreControllerChanges = false
        
        fetchedResultsController.fetch()
    }
    
}
