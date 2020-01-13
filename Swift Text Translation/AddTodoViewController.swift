

import UIKit

class AddTodoViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    var isImportant:Bool = false
    
    /// This switch adjusts the boolean for determining if the task is important or not.
    ///
    /// - Parameter sender: This button function gets called by the sender(UISwitch in this case), managed by the storyboad.
    @IBAction func importanceSwitch(_ sender: UISwitch) {
        if sender.isOn == true {
            isImportant = true
        } else {
            isImportant = false
        }
    }
    
    /// This function adds the task the user has created to the array of tasks
    ///
    /// - Parameter sender: This button function gets called by the sender(UIButton in this case), managed by the storyboard.
    @IBAction func addListItemAction(_ sender: Any) {
  
        let details = contentTextView.text ?? ""
        let title = titleTextField.text!
        
    
        let task: TodoList = TodoList(title: title, details: details , isImportant: isImportant)
        taskList.append(task)
        self.navigationController?.popViewController(animated: true)
    }
    
    /// allows user to cancel adding a task
    ///
    /// - Parameter sender: This button function gets called by the sender(UIButton in this case), managed by the storyboard.
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
}
