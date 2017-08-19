//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by Yuliia Stelmakhovska on 2017-08-13.
//  Copyright © 2017 Yuliia Stelmakhovska. All rights reserved.
//

import UIKit
import Firebase

class TasksViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var user:User!
    var ref: DatabaseReference!
    var tasks = Array<Task>()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference().child("users").child(user.uid).child("tasks")
    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
//    get data as snapshot from db, parse it, observer
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { [weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
            let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        })
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        which was created in viewWillAppear
    ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        let task = tasks[indexPath.row]
        cell.textLabel?.textColor = .white
        
        let taskTitle = task.title
          cell.textLabel?.text = taskTitle
        toggleCompletion(cell, isCompleted: task.completed)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
let isCompleted = !task.completed
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed" : isCompleted])
        
    }
    
    func toggleCompletion(_ cell:UITableViewCell, isCompleted: Bool){
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    
    
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch  {
            print(error.localizedDescription)
        }// exit
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "new task", message: "add new task", preferredStyle: .alert)
        alertController.addTextField()
        let save = UIAlertAction(title: "save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, textField.text != "" else { return }

            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
            
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)

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
