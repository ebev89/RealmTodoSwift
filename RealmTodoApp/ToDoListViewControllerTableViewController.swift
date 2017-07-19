//
//  ToDoListViewControllerTableViewController.swift
//  RealmTodoApp
//
//  Created by Egor Tarasov on 7/19/17.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewControllerTableViewController: UITableViewController, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    
    // Notifications on item model
    var notificationToken: NotificationToken? = nil
    
    // Realm instance
    let realm = try! Realm()
    
    // Item list
    var todos, sorted, searched: Results<ToDoItem>!
    
    // Selected item
    var selectedItem: ToDoItem!
    
    // Sort method
    enum SortBy {
        case date, priority
    }
    
    // Default sort is date
    var sortMethod = SortBy.date
    
    // Strings for priority values
    var priorityTexts = ["➘", "➙", "➚"]
    
    // Date formatter for item date
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize objects array
        todos = realm.objects(ToDoItem.self)

        // Do sort at load
        doSort()
        
        // back button text should be empty
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Observe Results Notifications
        notificationToken = todos.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial, .update(_, deletions: _, insertions: _, modifications: _):
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
//            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
//                tableView.beginUpdates()
//                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//                                     with: .automatic)
//                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//                                     with: .automatic)
//                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//                                     with: .automatic)
//                tableView.endUpdates()
//                if self!.searchDisplayController!.isActive {
//                    self!.searchDisplayController!.searchResultsTableView.reloadData()
//                }
//                tableView.reloadData()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
        // Initialize search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Set dateformatter style
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
    }
    
    deinit {
        notificationToken?.stop()
    }
    
    func doSort() {
        // conduct sort and reload table
        switch sortMethod {
        case .priority:
            sorted = todos.sorted(by: [SortDescriptor(keyPath: "priority", ascending: false), SortDescriptor(keyPath: "date", ascending: false)])
        default:
            sorted = todos.sorted(byKeyPath: "date", ascending: false)
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    @IBAction func sort(_ sender: Any) {
        // Show actionsheet for sort type
        let alert = UIAlertController(title: "Sort by", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { (action) in
            self.sortMethod = .date
            self.doSort()
        }))
        alert.addAction(UIAlertAction(title: "Priority", style: .default, handler: { (action) in
            self.sortMethod = .priority
            self.doSort()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Helper function
    func isSearching() -> Bool {
        return searchController.isActive && searchController.searchBar.text != ""
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching() {
            return searched.count
        } else {
            return sorted.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TodoCellIdentifier", for: indexPath)

        let item = isSearching() ? searched[indexPath.row] : sorted[indexPath.row]
        cell.textLabel?.text = priorityTexts[item.priority.rawValue] + " " + item.name
        
        cell.detailTextLabel?.text = dateFormatter.string(from: item.date)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editItem", sender: self)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let item = isSearching() ? searched[indexPath.row] : sorted[indexPath.row]
                realm.delete(item)
            }
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItem" {
            let editVC = segue.destination as! EditItemViewController
            
            if searchController.isActive && searchController.searchBar.text != "" {
                selectedItem = searched[tableView!.indexPathForSelectedRow!.row]
            } else {
                selectedItem = sorted[tableView!.indexPathForSelectedRow!.row]
            }

            editVC.item = selectedItem
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searched = todos.filter(NSPredicate(format: "name contains[c] %@", searchController.searchBar.text!))
        tableView.reloadData()
    }
}
