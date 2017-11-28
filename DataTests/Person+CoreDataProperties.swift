//
//  Person+CoreDataProperties.swift
//  DataTests
//
//  Created by Christian Otkjær on 28/11/2017.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var birthDate: NSDate?
    @NSManaged public var gender: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var children: NSSet?
    @NSManaged public var group: Group?
    @NSManaged public var parents: NSSet?

}

// MARK: Generated accessors for children
extension Person {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Person)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Person)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

// MARK: Generated accessors for parents
extension Person {

    @objc(addParentsObject:)
    @NSManaged public func addToParents(_ value: Person)

    @objc(removeParentsObject:)
    @NSManaged public func removeFromParents(_ value: Person)

    @objc(addParents:)
    @NSManaged public func addToParents(_ values: NSSet)

    @objc(removeParents:)
    @NSManaged public func removeFromParents(_ values: NSSet)

}
