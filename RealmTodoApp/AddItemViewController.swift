//
//  AddItemViewController.swift
//  RealmTodoApp
//
//  Created by Egor Tarasov on 7/19/17.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit
import RealmSwift

class AddItemViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) {
        if nameTextField.text!.characters.count > 0 {
            let realm = try! Realm()
            let newTodoItem = ToDoItem()
            newTodoItem.name = nameTextField.text!
            newTodoItem.priority = TodoPriority(rawValue: prioritySegmentedControl.selectedSegmentIndex)!
            
            try! realm.write({
                realm.add(newTodoItem)
            })
            
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Name cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
