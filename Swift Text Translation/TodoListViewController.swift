//
//  ViewController.swift
//  Comp Sci Culminating
//
//  Created by Teach
//  Copyright © 2019Teach. All rights reserved.
//

import UIKit

var taskList = [TodoList]()
var filterTaskList = [TodoList]()

class TodoListViewController: UIViewController, UITableViewDelegate , UITableViewDataSource , UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var todoListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todoListTableView.delegate = self
        todoListTableView.dataSource = self
        searchBar.delegate = self
        todoListTableView.rowHeight = UITableView.automaticDimension
        todoListTableView.estimatedRowHeight = 50
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        saveData()
        todoListTableView.reloadData()
    }
    
    
    /// This function saves the custom Tasklist object into userDefaults
    func saveData() {
        taskList.sort() {
            $0.isImportant && !$1.isImportant
        }
        let savedData = taskList.map {
            ["title": $0.title,
             "details": $0.details!,
             "isComplete": $0.isComplete,
             "isImportant": $0.isImportant]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(savedData, forKey: "items")
        userDefaults.synchronize()
    }
    
    
    /// This function loads the data that is already present in userDefaults
    func loadData() {
        let userDefaults = UserDefaults.standard
        guard let savedData = userDefaults.object(forKey: "items") as? [[String: AnyObject]] else {
            return
        }
        //This takes the data present in userDefaults and adds it to the array of Todo tasks.
        taskList = savedData.map {
            let title = $0["title"] as? String
            let details = $0["details"] as? String
            let isComplete = $0["isComplete"] as? Bool
            let isImportant = $0["isImportant"] as? Bool
            return TodoList(title: title!, isComplete: isComplete!, details: details! , isImportant: isImportant!)
        }
        taskList.sort() {
            $0.isImportant && !$1.isImportant
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //This takes care of adding the task to the tableView.
        if taskList[indexPath.row].isImportant == true {
        cell.textLabel?.text =  "❗\(taskList[indexPath.row].title)"
        } else {
        cell.textLabel?.text = taskList[indexPath.row].title
        }
        cell.detailTextLabel?.text = taskList[indexPath.row].details
        
        if taskList[indexPath.row].isComplete {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //This allows the user to delete a task by swiping on it.
        taskList.remove(at: indexPath.row)
        todoListTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This part invokes when the user marks a task as completed and it presents and alert.
        guard !taskList[indexPath.row].isComplete else {
            return
        }
        taskList[indexPath.row].isComplete = true
        let taskCompletionAlert = UIAlertController(title: "Task Marked as Completed", message: "Task Done.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        taskCompletionAlert.addAction(dismissAction)
        self.present(taskCompletionAlert, animated: true, completion: nil)
        saveData()
        todoListTableView.reloadData()
    }
}

