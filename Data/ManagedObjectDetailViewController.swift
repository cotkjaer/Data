//
//  ManagedObjectDetailViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

// MARK: - ManagedObjectDetailController

import UIKit
import CoreData
import Collections
import UserInterface

public protocol ManagedObjectDetailController: class
{
    var managedObjectContext : NSManagedObjectContext? { set get }
    
    var managedObjectID : NSManagedObjectID? { set get }
    
    ///NB! it is in a child context
    var managedObject: NSManagedObject? { get }
    
    var managedObjectDetailControllerDelegate: ManagedObjectDetailControllerDelegate? { set get }
}

public protocol ManagedObjectDetailControllerDelegate
{
    func managedObjectDetailControllerDidFinish(_ controller: ManagedObjectDetailController, saved: Bool)
}

// MARK: - ManagedObjectDetailController

extension UINavigationController
{
    public var managedObjectDetailController: ManagedObjectDetailController? { return viewControllers.find(ManagedObjectDetailController.self) }
}

open class ManagedObjectDetailViewController: UIViewController, ManagedObjectDetailController
{
    open var managedObjectDetailControllerDelegate: ManagedObjectDetailControllerDelegate?
    
    open var managedObjectContext: NSManagedObjectContext? { didSet { updateObject() } }
    
    open var managedObjectID: NSManagedObjectID? { didSet { updateObject() } }
    
    open var managedObject: NSManagedObject?
    
    fileprivate func updateObject()
    {
        if let id = managedObjectID, let context = managedObjectContext
        {
            managedObject = context.object(with: id)
        }
        else if managedObject != nil
        {
            managedObject = nil
        }
    }
}
