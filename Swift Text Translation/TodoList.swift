

import Foundation

/// This is the todolist class that contains all the data for the tasks.
class TodoList {
    var title: String = ""
    var isComplete: Bool = false
    var details: String?
    var isImportant: Bool = false
    
    init(title: String, isComplete: Bool = false, details: String? , isImportant: Bool = false) {
        self.title = title
        self.isComplete = isComplete
        self.details = details
        self.isImportant = isImportant
    }
}
