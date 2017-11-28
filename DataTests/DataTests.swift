//
//  DataTests.swift
//  DataTests
//
//  Created by Christian Otkjær on 17/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import XCTest
import CoreData
@testable import Data

//public extension Person
//{
//    var mom: Person? { return parents?.cast(Person.self).first(where: { $0.gender == 0 })}
//
//    var dad: Person? { return parents?.cast(Person.self).first(where: { $0.gender == 1 })}
//}

class DataTests: XCTestCase {
    
    var context : NSManagedObjectContext!
    
    override func setUp()
    {
        super.setUp()
        
        context = try! NSManagedObjectContext(modelName: "TestModel", inBundle: Bundle(for: DataTests.self), storeType: .inMemory)
    }

    func group(name: String) -> Group
    {
        guard let group = Group(in: context) else { XCTFail("No group created"); fatalError() }
        
        group.name = name

        XCTAssertEqual(group.name, name)
        
        return group
    }
    
    func test_insert_group()
    {
        XCTAssertNotNil(group(name: "g"))
    }
    
    func person(name: String) -> Person
    {
        let person = Person(in: context)
        
        person?.name = name

        XCTAssertEqual(person?.name, name)
        
        return person!
    }
    
    func test_insert_person()
    {
        let staff = group(name: "staff")
        
        let jane = person(name: "Jane")

        XCTAssertEqual(staff.members?.contains(jane), false)
        
        jane.group = staff
        
        XCTAssertEqual(staff.members?.contains(jane), true)

        let joe = person(name: "Joe")

        XCTAssertEqual(staff.members?.contains(joe), false)

        staff.addToMembers(joe)
        
        XCTAssertEqual(staff.members?.contains(joe), true)
    }
    
    func test_hierarchy()
    {
        let dad = person(name: "dad")
        dad.gender = 1
        
        let mom = person(name: "mom")
        mom.gender = 0
        
        let son = person(name: "son")
        son.gender = 1
        
        let sis = person(name: "sis")
        sis.gender = 0
        
        mom.addToChildren(son)
        mom.addToChildren(son)
        mom.addToChildren(sis)
        
        XCTAssertEqual(mom.children?.count, 2)
        
        XCTAssertEqual(mom.children?.contains(son), true)
        XCTAssertEqual(mom.children?.contains(sis), true)

        dad.addToChildren(mom.children!)
        
        XCTAssertEqual(mom.children, dad.children)

        XCTAssertEqual(son.parents?.contains(dad), true)
        XCTAssertEqual(son.parents?.contains(mom), true)
        XCTAssertEqual(son.parents?.contains(sis), false)

//        XCTAssertEqual(sis.dad, dad)
    }
}
