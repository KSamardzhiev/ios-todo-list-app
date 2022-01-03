//
//  CategoryTableViewController.swift
//  ToDoList
//
//  Created by Kostadin Samardzhiev on 1.01.22.
//

import UIKit
import RealmSwift

class CategoryTableViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories:Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        tableView.rowHeight = 80.0
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField:UITextField = UITextField()
        
        let alertController = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertController.addTextField { alertTextField in
            alertTextField.placeholder = "Please enter Category name"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newCat = Category()
            newCat.name = textField.text!
            self.saveData(category: newCat)
        }
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }

    //MARK: - TableView Datasource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        var config = cell.defaultContentConfiguration()
        
        config.text = categories?[indexPath.row].name ?? "No categories added"

        cell.contentConfiguration = config

        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! ToDoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.category = categories?[indexPath.row]
            }
            
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func saveData(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Unable to save data: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryToDelete = self.categories?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(categoryToDelete)
                })
            } catch {
                print("Unable to delete category: \(error)")
            }
        }
    }
    
}
