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

public class FetchedResultsTableViewController: UITableViewController, FetchedResultsControllerDelegate, ManagedObjectsController
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
        
        setupGestureRecognizer()
        
        fetchedResultsController.fetch()
    }
    
    // MARK: - UITableViewDataSource
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return fetchedResultsController.numberOfSections()
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchedResultsController.numberOfObjects(section)
    }
    
    public func cellReuseIdentifierForIndexPath(indexPath: NSIndexPath) -> String
    {
        return "Cell"
    }
    
    public func configureCell(cell: UITableViewCell, forObject object: NSManagedObject?, atIndexPath indexPath: NSIndexPath)
    {
        debugPrint("override configureCell")
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
        
        configureCell(cell, forObject: objectForIndexPath(indexPath), atIndexPath: indexPath)
        
        return cell
    }
    
    override public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return fetchedResultsController.titleForSection(section)
    }
    
    // MARK: - Rearranging
    
    var sourceIndexPath : NSIndexPath?
    var snapshot : UIView?
    var draggingOffset : CGPoint?
    
    // MARK: - ManagedObjectDetailControllerDelegate
    
    
    public func managedObjectDetailControllerDidFinish(controller: ManagedObjectDetailController, saved: Bool)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Navigation

extension FetchedResultsTableViewController
{
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        prepareForSegue(segue, sender: sender, cellsView: tableView)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FetchedResultsTableViewController// : FetchedResultsControllerDelegate
{
    func controllerWillChangeContent(controller: FetchedResultsController)
    {
        debugPrint("\(self) will change")
        if !ignoreControllerChanges
        {
            tableView.beginUpdates()
        }
    }
    
    func controllerDidChangeContent(controller: FetchedResultsController)
    {
        debugPrint("\(self) did change")
        if !ignoreControllerChanges
        {
            tableView.endUpdates()
        }
    }
    
    func controller(controller: FetchedResultsController, didInsertSection section: Int)
    {
        tableView.insertSections(NSIndexSet(index: section), withRowAnimation: .Fade)
    }
 
    func controller(controller: FetchedResultsController, didDeleteSection section: Int)
    {
        tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: .Fade)
    }

    func controller(controller: FetchedResultsController, didUpdateSection section: Int)
    {
        tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Fade)
    }
    
    func controller(controller: FetchedResultsController, didInsertObject object: AnyObject, atIndexPath path: NSIndexPath)
    {
        tableView.insertRowsAtIndexPaths([path], withRowAnimation: .Fade)
    }
    
    func controller(controller: FetchedResultsController, didDeleteObject object: AnyObject, atIndexPath path: NSIndexPath)
    {
        tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
    }
    
    func controller(controller: FetchedResultsController, didUpdateObject object: AnyObject, atIndexPath path: NSIndexPath)
    {
        tableView.reloadRowsAtIndexPaths([path], withRowAnimation: .Fade)
//        if  let cell = tableView.cellForRowAtIndexPath(path),
//            let object = objectForIndexPath(path)
//        {
//            debugPrint("\(self) did update: \(path)")
//            configureCell(cell, forObject: object, atIndexPath: path)
//        }
    }
    
    func controller(controller: FetchedResultsController, didMoveObject object: AnyObject, atIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    {
        debugPrint("\(self) did move: \(atIndexPath) -> \(toIndexPath)")
        
        tableView.deleteRowsAtIndexPaths([atIndexPath], withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: .Fade)
    }
}

/*
// MARK: - NSFetchedResultsControllerDelegate

extension FetchedResultsTableViewController : NSFetchedResultsControllerDelegate
{
    public func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        debugPrint("\(self) will change")
        if !ignoreControllerChanges
        {
            tableView.beginUpdates()
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        debugPrint("\(self) did change")
        if !ignoreControllerChanges
        {
            tableView.endUpdates()
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {

        if !ignoreControllerChanges
        {
            switch type
            {
            case .Insert:
                
                if let insertIndexPath = newIndexPath
                {
                    debugPrint("\(self) did insert: \(insertIndexPath)")
                    tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            case .Delete:
                
                if let deleteIndexPath = indexPath
                {
                    debugPrint("\(self) did delete: \(deleteIndexPath)")
                    tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            case .Update:
                
                if let updatedIndexPath = indexPath,
                    let cell = self.tableView.cellForRowAtIndexPath(updatedIndexPath),
                    let object = objectForIndexPath(updatedIndexPath)
                {
                    debugPrint("\(self) did update: \(updatedIndexPath)")
                    configureCell(cell, forObject: object, atIndexPath: updatedIndexPath)
                }
                
            case .Move:
                
                if let deleteIndexPath = indexPath, let insertIndexPath = newIndexPath
                {
                    debugPrint("\(self) did move: \(deleteIndexPath) -> \(insertIndexPath)")
                    
                    tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        if !ignoreControllerChanges
        {
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            
            switch type
            {
            case .Insert:
                tableView.insertSections(sectionIndexSet, withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteSections(sectionIndexSet, withRowAnimation: .Fade)
                
            default:
                debugPrint("Odd change-type for section \(sectionIndex): \(type)")
            }
        }
    }
    
    public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
    {
        return sectionName
    }
}
*/

// MARK: - Rearrange

extension FetchedResultsTableViewController
{
    func customSnapshotFromView(inputView: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext()
        {
            inputView.layer.renderInContext(context)
            
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
    
    func longPressGestureRecognized(longPress :UILongPressGestureRecognizer)
    {
        let location = longPress.locationInView(tableView)
        
        switch longPress.state
        {
        case .Began:
            
            ignoreControllerChanges = true
            if let indexPath = tableView.indexPathForLocation(location)
                , let cell = tableView.cellForRowAtIndexPath(indexPath)
            {
                sourceIndexPath = indexPath
                
                // Take a snapshot of the selected row using helper method.
                let snapshot = customSnapshotFromView(cell)
                
                // Add the snapshot as subview, centered at cell's center...
                
                snapshot.center = cell.center
                snapshot.alpha = 0
                
                draggingOffset =  location - cell.center
                
                self.snapshot = snapshot
                
                tableView.addSubview(snapshot)
                
                UIView.animateWithDuration(0.25,
                    animations:
                    {
                        snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
                        snapshot.center.y = location.y - (self.draggingOffset?.y ?? 0)
                        snapshot.alpha = 1
                        
                        // Fade out.
                        cell.alpha = 0
                        
                    },
                    completion:
                    { _ in
                        
                        cell.hidden = true
                })
            }
            
        case .Changed:
            
            if let indexPath = tableView.indexPathForLocation(location),
                let sourceIndexPath = self.sourceIndexPath,
                let snapshot = self.snapshot,
                let offset = draggingOffset
            {
                UIView.animateWithDuration(0.25) { snapshot.center.y = location.y - offset.y }
                
                if indexPath != sourceIndexPath
                {
                    
                    ignoreControllerChanges = true; defer { ignoreControllerChanges = false }
                    
                    guard let o1 = objectForIndexPath(indexPath) else { return }
                    guard let o2 = objectForIndexPath(sourceIndexPath) else { return }
                    
                    guard let key = fetchRequest?.sortDescriptors?.first?.key else { return }
                    
                    guard let v1 = o1.valueForKey(key), let v2 = o2.valueForKey(key) else { return }
                    
                    o2.setValue(v1, forKey: key)
                    o1.setValue(v2, forKey: key)
                    
//                    fetchedResultsController.fetch()
//
//                    // ... update data source.
//                    if let o1 = fetchedResultsController.objectForIndexPath(indexPath), let
//                        o2 = fetchedResultsController.objectForIndexPath(sourceIndexPath)
//                    {
//                        if let v1 = o1.valueForKey("sortOrder"), let v2 = o2.valueForKey("sortOrder")
//                        {
//                            o2.setValue(v1, forKey: "sortOrder")
//                            o1.setValue(v2, forKey: "sortOrder")
//                        }
//                    }
                    
                    // ... move the rows.
                    tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: indexPath)
                    
                    // ... and update source so it is in sync with UI changes.
                    self.sourceIndexPath = indexPath
                }
            }
            
        default:
            if let currentIndexPath = sourceIndexPath,
                let cell = tableView.cellForRowAtIndexPath(currentIndexPath),
                let snapshot = self.snapshot
            {
                cell.hidden = false
                cell.alpha = 0
                
                UIView.animateWithDuration(0.25,
                    animations:
                    {
                        snapshot.center = cell.center
                        snapshot.transform = CGAffineTransformIdentity;
                    },
                    completion:
                    { (completed) -> Void in
                        
                        cell.alpha = 1
                        
                        UIView.animateWithDuration(0.25,
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
