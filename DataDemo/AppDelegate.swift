//
//  AppDelegate.swift
//  DataDemo
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreData

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


var sharedContext : NSManagedObjectContext!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        do
        {
            sharedContext = try NSManagedObjectContext(modelName: "DemoModel")
            populateDataStore()
        }
        catch let error
        {
            fatalError("Error: \(error)")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func populateDataStore()
    {
        var texts = Set<String>("lorem ipsum", "Camels are almost as cool as bowties", "1 Mississipi", "Hundertwasser", "", "π")
        
        var messages = sharedContext.all(Message.self) ?? []
        
        for message in messages.enumerated()
        {
            let _ = texts.remove(message.element.text)
        }
        
        for text in texts
        {
            let message = sharedContext.insert(Message.self)
            
            message?.text = text
            let _ = messages.append(message)
        }

        messages.sorted(by: { $0.text < $1.text}).enumerated().forEach { $1.sortOrder = Int16($0) }
        
        let _ = sharedContext.saveSafely()
    }
}

