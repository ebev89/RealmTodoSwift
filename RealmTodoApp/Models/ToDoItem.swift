//
//  ToDoItem.swift
//  RealmTodoApp
//
//  Created by Egor Tarasov on 7/19/17.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit
import RealmSwift

@objc enum TodoPriority: Int {
    case Low = 0, Medium, High
}

class ToDoItem: Object {
    // Item name
    dynamic var name = ""
    
    // Completed: Not used
    dynamic var completed = false
    
    // Great number is high priority
    dynamic var priority = TodoPriority.Low
    
    dynamic var date = Date()
}
