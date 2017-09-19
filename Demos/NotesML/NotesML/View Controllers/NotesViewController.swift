//
//  NotesViewController.swift
//  NotesML
//
//  Created by Michael Thomas on 9/17/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import UIKit
import CoreData

typealias NotesProtocol = UITableViewDataSource & UITableViewDelegate & NSFetchedResultsControllerDelegate

class NotesViewController: UIViewController, NotesProtocol {
    
    // MARK: Properties & Initialization
    
    @IBOutlet private weak var tableView: UITableView!
    var dataController: DataController! {
        didSet {
            fetchedResultsController = self.notesManager.createNotesFetchedResultsController()
        }
    }
    var fetchedResultsController: NSFetchedResultsController<Note>! {
        didSet {
            fetchedResultsController.delegate = self
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }
    var notesManager: NotesService!
    var filteredNotes = [Note]()
    
    class func build(using dataController: DataController) -> NotesViewController {
        let storyboard = UIStoryboard(name: "Notes", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! NotesViewController
        controller.notesManager = NotesService(with: dataController)
        controller.dataController = dataController
        
        return controller
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Toolbar
        let segmentedControl = UISegmentedControl(items: ["All", "😐", "😃", "😔"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(NotesViewController.sentimentValueChanged(_:)), for: .valueChanged)

        let item = UIBarButtonItem(customView: segmentedControl)
        self.setToolbarItems([item], animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: Actions
    @IBAction func addAction(sender: Any) {
        try! notesManager.createNote()
    }
    
    @objc func sentimentValueChanged(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        let littleValue = Int16(sender.selectedSegmentIndex)
        let sentiment = Sentiment(rawValue: littleValue)
        if let predicate = self.notesManager.createNotesFetchRequestPredicate(with: sentiment) {
            self.fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            self.fetchedResultsController.fetchRequest.predicate = nil
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListCell", for: indexPath)
        let note = self.fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = note.preview()
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = self.fetchedResultsController.object(at: indexPath)
        let detailVC = DetailViewController.build(using: notesManager, note: selectedNote)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete Note") {_, _ , completionHandler in
            let note = self.fetchedResultsController.object(at: indexPath)
            do {
                try self.notesManager.delete(note, from: self.dataController.persistentContainer.viewContext)
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            }
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // MARK: NotesManagerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            
            // TODO: Update cell here, move doesn't refresh the cell
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

