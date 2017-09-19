//
//  AppDelegate.swift
//  NotesML
//
//  Created by Michael Thomas on 9/17/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataController: DataController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        dataController = DataController() { controller in
            let notesVC = NotesViewController.build(using: controller)
            let navVC = UINavigationController(rootViewController: notesVC)
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navVC
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

}

