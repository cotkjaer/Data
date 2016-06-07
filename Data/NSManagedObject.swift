//
//  NSManagedObject.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 21/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData
import UIKit

private func typeName(some: Any) -> String {
    return (some is Any.Type) ? "\(some)" : "\(some.dynamicType)"
}

/// localized System UIKit Strings, like "Search", "Cancel", "Done", "Delete"
private func UIKitLocalizedString(key: String) -> String
{
    return NSBundle(identifier: "com.apple.UIKit")?.localizedStringForKey(key, value: nil, table: nil) ?? key
}


extension NSManagedObject
{
    ///returns the class-name 
    public class var entityName: String
    {
        let fullClassName: String = NSStringFromClass(object_getClass(self))
        let classNameComponents: [String] = fullClassName.componentsSeparatedByString(".")
        return classNameComponents.last!
        
//        return typeName(self)
    }
    
    public class func fetchRequest() -> NSFetchRequest
    {
        return NSFetchRequest(entityName: entityName)
    }
    
    public func deleteWithConfirmation(controller: UIViewController, completion: ((deleted:Bool, error: NSError?)->())?)
    {
        if //let realController = controller ?? UIApplication.topViewController(),
            let context = managedObjectContext
        {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Delete"), style: .Destructive, handler: { (action) -> Void in
                
                context.deleteObject(self)
                
                let (saved, error) = context.saveSafely()
                
                completion?(deleted: saved, error: error)
                
            }))
            
            alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Cancel"), style: .Cancel, handler:  { (action) -> Void in
                completion?(deleted: false, error: nil)
            }))
            
            controller.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            completion?(deleted: false, error: nil)
        }
    }
}
