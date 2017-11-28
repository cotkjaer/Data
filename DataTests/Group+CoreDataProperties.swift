//
//  Group+CoreDataProperties.swift
//  DataTests
//
//  Created by Christian Otkjær on 28/11/2017.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var name: String?
    @NSManaged public var members: NSSet?

}

// MARK: Generated accessors for members
extension Group {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: Person)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: Person)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}
