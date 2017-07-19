//
//  EditItemViewController.swift
//  RealmTodoApp
//
//  Created by Egor Tarasov on 7/20/17.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit
import RealmSwift

class EditItemViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    
    var item: ToDoItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set control values
        nameTextField.text = item.name
        prioritySegmentedControl.selectedSegmentIndex = item.priority.rawValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    @IBAction func save(_ sender: Any) {
        if nameTextField.text!.characters.count > 0 {
            let realm = try! Realm()
            
            try! realm.write({
                item.name = nameTextField.text!
                item.priority = TodoPriority(rawValue: prioritySegmentedControl.selectedSegmentIndex)!
            })
            
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Name cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
        }
    }
    
}
