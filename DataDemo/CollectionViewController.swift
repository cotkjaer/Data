//
//  CollectionViewController.swift
//  Data
//
//  Created by Christian Otkjær on 05/12/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Data
import CoreData

class CollectionViewController: FetchedResultsCollectionViewController
{

    @IBAction func save(_ sender: UIBarButtonItem)
    {
        managedObjectContext?.saveWithAlert()
    }
    
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
    
    override func configure(cell: UICollectionViewCell, for object: NSManagedObject?, at indexPath: IndexPath)
    {
        guard let message = object as? Message, let cell = cell as? CollectionViewCell else { return }
        
        cell.textLabel?.text = message.text
    }
}
