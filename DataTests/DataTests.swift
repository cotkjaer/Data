//
//  DataTests.swift
//  DataTests
//
//  Created by Christian Otkjær on 17/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import XCTest
import CoreData
import Nimble
@testable import Data

class DataTests: XCTestCase {
    
    var context : NSManagedObjectContext!
    
    override func setUp()
    {
        super.setUp()
    
        expect(expression: { self.context = try NSManagedObjectContext(modelName: "TestModel", inBundle: NSBundle(forClass: DataTests.self), storeType: .InMemory)}).to(beVoid())
    }

    func group(name: String) -> Group
    {
        let group = context.insert(Group)
        
        group?.name = name
        
        expect(group) != nil
        
        expect(group?.name) == name
        
        return group!
    }
    
    func test_insert_group()
    {
        expect(self.group("g")) != nil
    }
    
    func person(name: String) -> Person
    {
        let person = context.insert(Person)
        
        person?.name = name
        
        expect(person?.name) == name

        return person!
    }
    
    func test_insert_person()
    {
        let staff = group("staff")
        
        let jane = person("Jane")
     
        expect(staff.members).toNot(contain(jane))

        jane.group = staff
        
        expect(staff.members).to(contain(jane))
        
        let joe = person("Joe")
        
        expect(staff.members).toNot(contain(joe))

        expect(staff.addMember(joe)) == true
        
        expect(staff.members).to(contain(joe))
    }
    
    func test_hierarchy()
    {
        let dad = person("dad")
        dad.gender = 1
        
        let mom = person("mom")
        mom.gender = 0
        
        let son = person("son")
        son.gender = 1
        
        let sis = person("sis")
        sis.gender = 0
        
        mom.addChildrenObject(son)
        mom.addChildrenObject(son)
        mom.addChildrenObject(sis)
        
        expect(mom.children).to(contain(son,sis))
        expect(mom.children?.count) == 2
        
        dad.addChildren(mom.children!)
        
        expect(dad.children) == mom.children
        
        expect(mom.children).to(contain(son))
        expect(son.parents).to(contain(mom))
    
        expect(sis.parents).to(contain(dad))
        
        expect(son.dad) == dad
    }
}
