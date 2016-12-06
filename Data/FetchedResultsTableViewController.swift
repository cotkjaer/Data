//
//  FetchedResultsTableViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreData
import Graphics

open class FetchedResultsTableViewController: UITableViewController, FetchedResultsControllerDelegate, ManagedObjectsController
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
    
    open func numberOfObjects(inSection: Int? = nil) -> Int
    {
        return fetchedResultsController.numberOfObjects(inSection: inSection)
    }

    // MARK: - Lifecycle
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupGestureRecognizer()
        
        fetchedResultsController.fetch()
    }
    
    // MARK: - UITableViewDataSource
    
    override open func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController.numberOfSections()
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchedResultsController.numberOfObjects(inSection: section)
    }
    
    open func cellReuseIdentifier(for indexPath: IndexPath) -> String
    {
        return "Cell"
    }
    
    open func configure(cell: UITableViewCell, for object: NSManagedObject?, at indexPath: IndexPath)
    {
        debugPrint("override configureCell")
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier(for: indexPath), for: indexPath)
        
        configure(cell: cell, for: object(at: indexPath), at: indexPath)
        
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return fetchedResultsController.title(forSection: section)
    }
    
    // MARK: - Rearranging
    
    var sourceIndexPath : IndexPath?
    var snapshot : UIView?
    var draggingOffset : CGPoint?
    
    // MARK: - ManagedObjectDetailControllerDelegate
    
    
    open func managedObjectDetailControllerDidFinish(_ controller: ManagedObjectDetailController, saved: Bool)
    {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Navigation

extension FetchedResultsTableViewController
{
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        prepareForSegue(segue, sender: sender as Any?, cellsView: tableView)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FetchedResultsTableViewController// : FetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: FetchedResultsController)
    {
        guard !ignoreControllerChanges else { return }

        debugPrint("\(self) will change")
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: FetchedResultsController)
    {
        debugPrint("\(self) did change")

        guard !ignoreControllerChanges else { return }
        
        tableView.endUpdates()
    }
    
    func controller(_ controller: FetchedResultsController, didInsertSection section: Int)
    {
        tableView.insertSections(IndexSet(integer: section), with: .fade)
    }
 
    func controller(_ controller: FetchedResultsController, didDeleteSection section: Int)
    {
        tableView.deleteSections(IndexSet(integer: section), with: .fade)
    }

    func controller(_ controller: FetchedResultsController, didUpdateSection section: Int)
    {
        tableView.reloadSections(IndexSet(integer: section), with: .fade)
    }
    
    func controller(_ controller: FetchedResultsController, didInsertObject object: Any, at path: IndexPath)
    {
        tableView.insertRows(at: [path], with: .fade)
    }
    
    func controller(_ controller: FetchedResultsController, didDeleteObject object: Any, at path: IndexPath)
    {
        tableView.deleteRows(at: [path], with: .fade)
    }
    
    func controller(_ controller: FetchedResultsController, didUpdateObject object: Any, at path: IndexPath)
    {
        tableView.reloadRows(at: [path], with: .fade)
    }
    
    func controller(_ controller: FetchedResultsController, didMoveObject object: Any, at: IndexPath, to: IndexPath)
    {
        debugPrint("\(self) did move: \(at) -> \(to)")
        
        tableView.deleteRows(at: [at], with: .fade)
        tableView.insertRows(at: [to], with: .fade)
    }
}

// MARK: - Rearrange

extension FetchedResultsTableViewController
{
    func customSnapshotFromView(_ inputView: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext()
        {
            inputView.layer.render(in: context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            let snapshot = UIImageView(image: image)
            snapshot.layer.masksToBounds = false
            snapshot.layer.cornerRadius = 0
            snapshot.layer.shadowOffset = CGSize(width: 0, height: 5)
            snapshot.layer.shadowRadius = 5
            snapshot.layer.shadowOpacity = 0.4
            
            return snapshot
        }
        
        return UIView()
    }
    
    func setupGestureRecognizer()
    {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(FetchedResultsTableViewController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    func longPressGestureRecognized(_ longPress :UILongPressGestureRecognizer)
    {
        let location = longPress.location(in: tableView)
        
        switch longPress.state
        {
        case .began:
            
            ignoreControllerChanges = true
            if let indexPath = tableView.indexPathForLocation(location)
                , let cell = tableView.cellForRow(at: indexPath)
            {
                sourceIndexPath = indexPath
                
                // Take a snapshot of the selected row using helper method.
                let snapshot = customSnapshotFromView(cell)
                
                // Add the snapshot as subview, centered at cell's center...
                
                snapshot.center = cell.center
                snapshot.alpha = 0
                
                draggingOffset = location - cell.center
                
                self.snapshot = snapshot
                
                tableView.addSubview(snapshot)
                
                UIView.animate(withDuration: 0.25,
                    animations:
                    {
                        snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        snapshot.center.y = location.y - (self.draggingOffset?.y ?? 0)
                        snapshot.alpha = 1
                        
                        // Fade out.
                        cell.alpha = 0
                        
                    },
                    completion:
                    { _ in
                        
                        cell.isHidden = true
                })
            }
            
        case .changed:
            
            if let indexPath = tableView.indexPathForLocation(location),
                let sourceIndexPath = self.sourceIndexPath,
                let snapshot = self.snapshot,
                let offset = draggingOffset
            {
                UIView.animate(withDuration: 0.25, animations: { snapshot.center.y = location.y - offset.y }) 
                
                if indexPath != sourceIndexPath
                {
                    ignoreControllerChanges = true; defer { ignoreControllerChanges = false }
                    
                    guard let o1 = object(at: indexPath) else { return }
                    guard let o2 = object(at: sourceIndexPath) else { return }
                    
                    guard let key = fetchRequest?.sortDescriptors?.first?.key else { return }
                    
                    guard let v1 = o1.value(forKey: key), let v2 = o2.value(forKey: key) else { return }
                    
                    o2.setValue(v1, forKey: key)
                    o1.setValue(v2, forKey: key)
                
                    // ... move the rows.
                    tableView.moveRow(at: sourceIndexPath, to: indexPath)
                    
                    // ... and update source so it is in sync with UI changes.
                    self.sourceIndexPath = indexPath
                }
            }
            
        default:
            if let currentIndexPath = sourceIndexPath,
                let cell = tableView.cellForRow(at: currentIndexPath),
                let snapshot = self.snapshot
            {
                cell.isHidden = false
                cell.alpha = 0
                
                UIView.animate(withDuration: 0.25,
                    animations:
                    {
                        snapshot.center = cell.center
                        snapshot.transform = CGAffineTransform.identity;
                    },
                    completion:
                    { (completed) -> Void in
                        
                        cell.alpha = 1
                        
                        UIView.animate(withDuration: 0.25,
                            animations:
                            {
                                //fade out shadow
                                snapshot.alpha = 0
                            },
                            completion:
                            { (completed) -> Void in
                                self.sourceIndexPath = nil
                                snapshot.removeFromSuperview()
                                self.snapshot = nil
                                self.ignoreControllerChanges = false
                        })
                })
            }
        }
    }
}
