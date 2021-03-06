//
//  FetchedResultsCollectionViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreData
import UserInterface

open class FetchedResultsCollectionViewController: UICollectionViewController, FetchedResultsControllerDelegate, ManagedObjectsController
{
    fileprivate lazy var fetchedResultsController : FetchedResultsController = { let c = FetchedResultsController(); c.delegate = self; return c }()
    
    /// Set this if you are updating the data "manually" (e.g. when rearranging)
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
    
    open func object(at optionalIndexPath: IndexPath?) -> NSManagedObject?
    {
        return fetchedResultsController.object(at: optionalIndexPath)
    }
    
    open func indexPath(forObject optionalObject: NSManagedObject?) -> IndexPath?
    {
        return fetchedResultsController.indexPath(forObject: optionalObject)
    }
    
    open func indexPath(forObjectID optionalID: NSManagedObjectID?) -> IndexPath?
    {
        return fetchedResultsController.indexPath(forObjectID: optionalID)
    }
    
    open func numberOfObjects(_ inSection: Int? = nil) -> Int
    {
        return fetchedResultsController.numberOfObjects(inSection: inSection)
    }
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        fetchedResultsController.fetch()
        
        //        setupRearranging()
    }
    
    open override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        guard let collectionView = collectionView else { return }
        
        guard !collectionView.indexPathsForVisibleItems.isEmpty else { return }
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    // MARK: UICollectionViewDataSource
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.numberOfSections()
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchedResultsController.numberOfObjects(inSection: section)
    }
    
    open func cellReuseIdentifier(for indexPath: IndexPath) -> String
    {
        return "Cell"
    }
    
    open func configure(cell: UICollectionViewCell, for object: NSManagedObject?, at indexPath: IndexPath)
    {
        debugPrint("override configureCell")
    }
    
    final override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier(for: indexPath), for: indexPath)
        
        configure(cell: cell, for: object(at: indexPath), at: indexPath)
        
        return cell
    }
    
    // MARK: - ManagedObjectDetailControllerDelegate
    
    open func managedObjectDetailControllerDidFinish(_ controller: ManagedObjectDetailController, saved: Bool)
    {
        /*
         guard let controller = controller as? UIViewController else { return }
         
         guard navigationController?.popToViewController(self, animated: true)?.contains(controller) == false else { return }
         
         controller.presentingViewController?.dismiss(animated: true, completion: nil)
         */
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
            collectionView.performBatchUpdates(blockOperation.start, completion: { _ in
            
                if !collectionView.indexPathsForVisibleItems.isEmpty
                {
                    collectionView.performBatchUpdates { collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems) }
                }
            })
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
    
    func controller(_ controller: FetchedResultsController, didInsertObject object: Any, at path: IndexPath)
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
    
    func controller(_ controller: FetchedResultsController, didDeleteObject object: Any, at path: IndexPath)
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
    
    func controller(_ controller: FetchedResultsController, didUpdateObject object: Any, at path: IndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
                return;
        blockOperation?.addExecutionBlock { collectionView.reloadItems( at: [ path ] ) }
    }
    
    func controller(_ controller: FetchedResultsController, didMoveObject object: Any, at: IndexPath, to: IndexPath)
    {
        guard !ignoreControllerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.moveItem(at: at, to: to ) }
    }
    
    override open func collectionView(_ collectionView: UICollectionView,
                                      moveItemAt sourceIndexPath: IndexPath,
                                      to destinationIndexPath: IndexPath)
    {
        ignoreControllerChanges = true

        defer {
            
            ignoreControllerChanges = false
            
            fetchedResultsController.fetch()
        }
        
        guard sourceIndexPath.section == destinationIndexPath.section else { return }
        guard sourceIndexPath.item != destinationIndexPath.item else { return }
        
        if sourceIndexPath.item > destinationIndexPath.item
        {
            guard let key = fetchRequest?.sortDescriptors?.first?.key else { return }

            guard let movedObject = object(at: sourceIndexPath) else { return }
            guard let value = movedObject.value(forKey: key) else { return }
            var lastObject = movedObject
            
            for item in (destinationIndexPath.item..<sourceIndexPath.item)
            {
                guard let o = object(at: IndexPath(item: item, section: sourceIndexPath.section)) else { continue }
                
                guard let value = o.value(forKey: key) else { continue }
                
                lastObject.setValue(value, forKey: key)
                lastObject = o
            }
            
            lastObject.setValue(value, forKey: key)
        }
        
        if sourceIndexPath.item < destinationIndexPath.item
        {
            guard let key = fetchRequest?.sortDescriptors?.first?.key else { return }
            
            guard let movedObject = object(at: sourceIndexPath) else { return }
            guard let value = movedObject.value(forKey: key) else { return }
            var lastValue = value
            
            for item in ((sourceIndexPath.item + 1)...destinationIndexPath.item)
            {
                guard let o = object(at: IndexPath(item: item, section: sourceIndexPath.section)) else { continue }
                
                guard let value = o.value(forKey: key) else { continue }
                
                o.setValue(lastValue, forKey: key)
                lastValue = value
            }
            
            movedObject.setValue(lastValue, forKey: key)
        }

        /*
        guard let o1 = object(at: destinationIndexPath) else { return }
            guard let o2 = object(at: sourceIndexPath) else { return }
            
            guard let key = fetchRequest?.sortDescriptors?.first?.key else { return }
            
            guard let v1 = o1.value(forKey: key), let v2 = o2.value(forKey: key) else { return }
            
            o2.setValue(v1, forKey: key)
            o1.setValue(v2, forKey: key)
        */
        
        

        
        
    }
}
