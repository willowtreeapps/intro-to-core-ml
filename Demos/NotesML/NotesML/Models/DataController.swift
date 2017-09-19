//
//  DataController.swift
//  NotesML
//
//  Created by Michael Thomas on 9/17/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    init(completion: ((DataController) -> Void)?) {
        persistentContainer = NSPersistentContainer(name: "NotesModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            
            // Update the viewContext with background updates
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            
            completion?(self)
        }
    }

}
