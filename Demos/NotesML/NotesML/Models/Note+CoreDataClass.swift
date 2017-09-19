//
//  Note+CoreDataClass.swift
//  NotesML
//
//  Created by Michael Thomas on 9/18/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {

    public func preview() -> String {
        guard let body = self.body, !body.isEmpty else {
            return "(empty note)"
        }
        
        if body.count > 64 {
            return body.prefix(64) + " ..."
        }
        
        return String(body.prefix(64))
    }

}
