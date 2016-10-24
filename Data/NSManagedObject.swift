//
//  NSManagedObject.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 21/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData
import UIKit
import SwiftPlus

extension NSManagedObject
{
    /// entityName
    public class var entityName: String
    {
        let fullClassName: String = NSStringFromClass(object_getClass(self))
        let classNameComponents: [String] = fullClassName.components(separatedBy: ".")
        return classNameComponents.last!
    }
    
//    public class func fetchRequest() -> NSFetchRequest<NSManagedObject>
//    {
//        return NSFetchRequest(entityName: entityName)
//    }
    
    public func deleteWithConfirmation(_ controller: UIViewController, completion: ((_ deleted:Bool, _ error: NSError?)->())?)
    {
        if //let realController = controller ?? UIApplication.topViewController(),
            let context = managedObjectContext
        {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Delete"), style: .destructive, handler: { (action) -> Void in
                
                context.delete(self)
                
                let (saved, error) = context.saveSafely()
                
                completion?(saved, error)
                
            }))
            
            alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Cancel"), style: .cancel, handler:  { (action) -> Void in
                completion?(false, nil)
            }))
            
            controller.present(alertController, animated: true, completion: nil)
        }
        else
        {
            completion?(false, nil)
        }
    }
}
