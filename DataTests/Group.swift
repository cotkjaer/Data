//
//  Group.swift
//  Data
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import CoreData


class Group: NSManagedObject
{
    func addMember(member: Person?) -> Bool
    {
        guard let member = member else { return false }
        
        guard members?.containsObject(member) != true else { return false }
        
        member.group = self
        
        return true
    }
}
