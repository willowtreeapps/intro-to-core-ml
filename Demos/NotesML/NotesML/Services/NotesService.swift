//
//  NotesService.swift
//  NotesML
//
//  Created by Michael Thomas on 9/18/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import Foundation
import CoreData

class NotesService: NSObject {

    var dataController: DataController! {
        didSet {
            writeContext = dataController.persistentContainer.newBackgroundContext()
            
            // TODO: Add a better way to handle demo data
            // Comment out if you don't want lots of Hugh Jackman reviews
            setupDemo()
        }
    }
        
    var writeContext: NSManagedObjectContext?
    let mlService = MLService()
    
    init(with dataController: DataController) {
        super.init()
        
        // Defer the properties after initialization so `didSet` gets called. /shrug
        defer {
            self.dataController = dataController
        }
    }
}

// MARK: Notes Demo Data

extension NotesService {
    
    func setupDemo() {
        guard let context = writeContext else {
            fatalError("Expected a writeContext when creating a note!")
        }
        
        let reviews = ["WillowTree is such a great place to work. I feel the company strikes the perfect balance of pushing you to always improve, having an environment of safety to try new things and emphasizing great work life balance. This is on top of having fun afterwork events all year round and of course beer on tap at the office! I feel that I am learning so much while also doing meaningful and enjoyable work. I couldn't ask for more.", "WillowTree is a very welcoming place and great for developing one's career. There are many opportunities to challenge yourself and pursue short-term and long-term goals. The people here are so friendly and willing to help and there is a good balance of work and social life. The projects are interesting and it is a great feeling knowing you're working on something for a client who will use the product and distribute it to its users. I highly recommend working here!", "Packed high with explosive action and loaded with high-stakes jeopardy, Con Air charts a generally sound narrative course, although it hits some story turbulence before it hits its climactic jackpot.", "Jerry Bruckheimer should be thankful for the modern audience's short attention span.", "Adrenaline-pumping action drama with some special surprizes.", "The movie is essentially a series of quick setups, brisk dialogue and elaborate action sequences.", "This movie is a fortune wasted.", "Not only safe for Junior and Grandma but also pretty entertaining.", "A big, overblown wazoo of absurdity.", "National Treasure may be dumb and relatively short on action scenes, but it's still a lot of fun, largely thanks to Cage and Bartha.", "Make no mistake, Logan earns its tears. If Jackman and Stewart are serious about this being their mutual X-Men swan song, they could not have crafted a more heartfelt valedictory.", "Jackman gives Logan a withering rage that seems heartfelt, not hammy; Stewart is touching in his enraged befuddlement; and Keen, who resembles here what Katie Holmes might look like if she were Carrie, has a feral intensity.", "How does Armageddon, a movie obsessed with countdowns and countdown clocks, manage to redefine -- downward -- the standard for summer stupidity? Let me count the ways.", "Armageddon peels your eyelids back and blows your eardrums out until rational analysis is moot.", "The film is never less than engaging, though considering that the title The Prestige refers to the moment in a magic act that gives it its 'wow' factor, it's kind of a shame that the ultimate 'reveal' in the movie is a little too tricky for its own good."]

        DispatchQueue.global(qos: .utility).async {
            // Calculate Sentiment
            var sentiment = Sentiment.neutral
            
            for review in reviews {
                let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
                note.created = Date.init()
                note.lastUpdated = note.created
                note.body = review
                sentiment = self.mlService.predictSentiment(from: review)
                note.sentiment = sentiment.rawValue
                
                print("Sentiment: \(sentiment)")
            }
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
}

// MARK: Note Helper Methods

extension NotesService {
    
    func createNotesFetchedResultsController() -> NSFetchedResultsController<Note> {
        let moc = dataController.persistentContainer.viewContext
        let request = NSFetchRequest<Note>(entityName: "Note")
        let dateSort = NSSortDescriptor(key: "lastUpdated", ascending: true)
        request.sortDescriptors = [dateSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }
    
    func createNotesFetchRequestPredicate(with filter: Sentiment?) -> NSPredicate? {
        if let filter = filter {
            return NSPredicate(format: "sentiment == %i", filter.rawValue)
        }
        
        return nil
    }
    
    func createNote(body: String? = nil) throws {
        guard let context = writeContext else {
            fatalError("Expected a writeContext when creating a note!")
        }
        
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
        note.created = Date.init()
        note.lastUpdated = note.created
        note.body = body
        
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func update(note: Note) {
        // Update keywords & sentiment entry
        guard let context = writeContext, note.hasPersistentChangedValues else {
            return
        }
        
        
        DispatchQueue.global(qos: .utility).async {
            // Calculate Sentiment
            var sentiment = Sentiment.neutral
            
            if let body = note.body {
                sentiment = self.mlService.predictSentiment(from: body)
            }
            
            print("Sentiment: \(sentiment)")
            
            do {
                let backgroundNote = try context.existingObject(with: note.objectID) as? Note
                backgroundNote?.body = note.body
                backgroundNote?.lastUpdated = Date()
                backgroundNote?.sentiment = sentiment.rawValue
                
                try context.save()
            } catch {
                fatalError("Failed to save writeContext while updating note!")
            }
        }
    }
    
    func delete(_ note: Note, from: NSManagedObjectContext) throws {
        from.delete(note)
        
        do {
            try from.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
}
