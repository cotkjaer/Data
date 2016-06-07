//
//  Person.swift
//  Data
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import CoreData


class Person: NSManagedObject
{

    @NSManaged func addChildrenObject(child: Person)
    @NSManaged func removeChildrenObject(child: Person)
    @NSManaged func addChildren(children: NSSet)
    @NSManaged func removeChildren(children: NSSet)
    
    var dad: Person? { return parents?.filteredSetUsingPredicate(NSPredicate(format: "gender == 1")).first as? Person }
}
