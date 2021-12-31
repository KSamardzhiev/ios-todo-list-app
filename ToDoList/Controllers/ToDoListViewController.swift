//
//  ViewController.swift
//  ToDoList
//
//  Created by Kostadin Samardzhiev on 31.12.21.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var items = [
        "Buy milk",
        "Go for a walk",
        "Call friend"
    ]
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let safeItems = defaults.array(forKey: "ToDoListItems") as? [String] {
            items = safeItems
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new ToDo List Item", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Please add an item"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            self.items.append(textField.text!)
            self.defaults.set(self.items, forKey: "ToDoListItems")
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - UITableViewController

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToListReuseableCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = items[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
