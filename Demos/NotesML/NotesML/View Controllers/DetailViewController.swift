//
//  DetailViewController.swift
//  NotesML
//
//  Created by Michael Thomas on 9/17/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet private weak var textView: UITextView!
    weak var note: Note?
    var notesManager: NotesService!
    
    class func build(using manager: NotesService, note: Note?) -> DetailViewController {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! DetailViewController
        controller.notesManager = manager
        controller.note = note
        return controller
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Damn keyboards getting in the way
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DetailViewController.keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DetailViewController.keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        textView.text = note?.body
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Display Sentiment in the Navigation Bar
        if let sentimentValue = note?.sentiment,
            let sentiment = Sentiment(rawValue: sentimentValue) {
            self.title = sentiment.emoji
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let note = note {
            note.body = textView.text
            notesManager.update(note: note)
        }
    }

    // MARK: Keyboard Notifications
    
    @objc func keyboardWillShow(notification: Notification) {
        if let info = notification.userInfo,
            let rect = info[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.size.height, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.scrollIndicatorInsets = textView.contentInset
    }
    
}
