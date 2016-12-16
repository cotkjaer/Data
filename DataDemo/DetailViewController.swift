//
//  DetailViewController.swift
//  Data
//
//  Created by Christian Otkjær on 16/12/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Data

class DetailViewController: ManagedObjectDetailViewController
{
    var message: Message? { return managedObject as? Message }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        textField?.text = message?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBOutlet weak var textField: UITextField?
    
    @IBAction func handleCancelButton(_ sender: Any)
    {         managedObjectDetailControllerDelegate?.managedObjectDetailControllerDidFinish(self, saved: false)
    }
    
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem)
    {
        guard let message = message, let context = message.managedObjectContext else { return }
        
        sender.isEnabled = false
        
        message.text = textField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let saved = context.saveWithAlert()
        
        managedObjectDetailControllerDelegate?.managedObjectDetailControllerDidFinish(self, saved: saved)
        
        sender.isEnabled = true
    }
    
    @IBAction func handleDeleteButton(_ sender: UIBarButtonItem)
    {
        guard let message = message, let context = message.managedObjectContext else { return }
        
        sender.isEnabled = false
        
        context.delete(message)
        
        let saved = context.saveWithAlert()
        
        managedObjectDetailControllerDelegate?.managedObjectDetailControllerDidFinish(self, saved: saved)
        
        sender.isEnabled = true
    }
}
