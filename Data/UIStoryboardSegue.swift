//
//  UIStoryboardSegue.swift
//  Data
//
//  Created by Christian Otkjær on 28/11/2017.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import Foundation
import CoreData

extension UIStoryboardSegue
{
    public var managedObjectDetailController: ManagedObjectDetailController?
    {
        if let controller = destination as? ManagedObjectDetailController
        {
            return controller
        }
        
        if let navController = destination as? UINavigationController,
            let controller = navController.managedObjectDetailController
        {
            return controller
        }
        
        return nil
    }
}
