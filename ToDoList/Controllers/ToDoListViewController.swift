//
//  ViewController.swift
//  ToDoList
//
//  Created by Kostadin Samardzhiev on 31.12.21.
//

import UIKit
import RealmSwift
import DynamicColor

class ToDoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var items:Results<Item>?
    var category:Category? {
        didSet {
            loadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let hexColourString = category?.colour {
            let dynamicColour = DynamicColor(hexString: hexColourString)
            self.navigationController?.navigationBar.backgroundColor = dynamicColour
            searchBar.barTintColor = dynamicColour
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
 
            if let safeCategory = self.category {
                do {
                    try self.realm.write {
                        let item = Item()
                        item.text = textField.text!
                        item.dateCreated = Date().timeIntervalSince1970
                        safeCategory.items.append(item)
                    }
                } catch {
                    print("Unable to save the item: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UITableViewController

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var config = cell.defaultContentConfiguration()
        var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
        
        if let item = items?[indexPath.row] {
            config.text = item.text
            config.textProperties.color = .white
            cell.accessoryType = item.checked ? .checkmark : .none
            backgroundConfig.backgroundColor = DynamicColor(hexString: category!.colour).darkened(amount: CGFloat(indexPath.row)/CGFloat(items!.count*2))
        } else {
            config.text = "No Items Added"
        }
        cell.contentConfiguration = config
        cell.backgroundConfiguration = backgroundConfig
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    item.checked = !item.checked
                })
                tableView.reloadData()
            } catch {
                print("Unable to change state of item: \(error)")
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Data Manipulation
    
    func loadData() {
        items = category?.items.sorted(byKeyPath: "text", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let safeItem = items?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(safeItem)
                })
            } catch {
                print("Unable to delete item: \(error)")
            }
        }
    }
}

//MARK: - Search Bar Delegate methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func performSearch(with sq: String) {
        items = items?.filter("text CONTAINS[cd] %@", sq).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(with: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            performSearch(with: searchText)
        }
    }
}
