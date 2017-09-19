//
//  Sentiment.swift
//  NotesML
//
//  Created by Michael Thomas on 9/18/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import UIKit

enum Sentiment: Int16 {
    case neutral = 1, positive, negative
    
    var emoji: String {
        switch self {
        case .neutral:
            return "😐"
        case .positive:
            return "😃"
        case .negative:
            return "😔"
        }
    }
    
    var color: UIColor? {
        switch self {
        case .neutral:
            return .blue
        case .positive:
            return .green
        case .negative:
            return .red
        }
    }
}
