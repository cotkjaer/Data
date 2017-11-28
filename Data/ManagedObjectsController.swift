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
    
    func object(at optionalIndexPath: IndexPath?) -> NSManagedObject?
    
    func indexPath(forObject optionalObject: NSManagedObject?) -> IndexPath?
    
    func indexPath(forObjectID optionalID: NSManagedObjectID?) -> IndexPath?
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
        else if let cell = sender as? CV.Cell,
            let indexPath = cellsView?.path(forCell: cell)
        {
            object = self.object(at: indexPath)
        }
        else if let indexPath = sender as? IndexPath
        {
            object = self.object(at: indexPath)
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


