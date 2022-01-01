//
//  ViewController.swift
//  ToDoList
//
//  Created by Kostadin Samardzhiev on 31.12.21.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var items:[Item] = []
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new ToDo List Item", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Please add an item"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
 
            let item = Item(context: self.context)
            item.text = textField.text!
            item.checked = false
    
            self.items.append(item)
            self.saveData()
            
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
        config.text = items[indexPath.row].text
        
        cell.accessoryType = items[indexPath.row].checked ? .checkmark : .none
        
        cell.contentConfiguration = config
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].checked = !items[indexPath.row].checked
        
        saveData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Data Manipulation
    
//    func saveData() {
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(items)
//            try data.write(to: dataFilePath!)
//        } catch {
//            print("Problem with encoding data: \(error)")
//        }
//    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
//    func loadData() {
//
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                items = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Unable to decode data: \(error)")
//            }
//
//        }
//    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            items = try context.fetch(request)
        } catch {
            print("Unable to fetch data: \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search Bar Delegate methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func performSearch(with sq: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", sq)
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
       
        loadData(with: request)
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
