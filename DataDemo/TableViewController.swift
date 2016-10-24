//
//  ViewController.swift
//  DataDemo
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Data
import CoreData

class TableViewController: FetchedResultsTableViewController
{
    override func viewDidLoad()
    {
        managedObjectContext = sharedContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>()
        
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Message", in: sharedContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        fetchRequest.predicate = nil
        
        self.fetchRequest = fetchRequest

        super.viewDidLoad()
    }

    override func configureCell(_ cell: UITableViewCell, forObject object: NSManagedObject?, atIndexPath indexPath: IndexPath)
    {
        guard let message = object as? Message else { return }
        
        cell.textLabel?.text = message.text
    }
    
}

