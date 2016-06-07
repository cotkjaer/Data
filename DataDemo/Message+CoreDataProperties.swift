//
//  Message+CoreDataProperties.swift
//  Data
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var text: String?
    @NSManaged var sortOrder: Int16

}
