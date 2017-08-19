//
//  ViewController.swift
//  ToDoFire
//
//  Created by Yuliia Stelmakhovska on 2017-08-13.
//  Copyright © 2017 Yuliia Stelmakhovska. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = Database.database().reference().child("users")
        
        //keyboard issue 
        NotificationCenter.default.addObserver( self, selector: #selector(kbDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
         NotificationCenter.default.addObserver( self, selector: #selector(kbDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        warnLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
            self.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        }
    }
//Clean email and login when sign out works
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    func kbDidShow(notification: Notification) {
        guard  let userInfo = notification.userInfo else { return }
//        UIKeyboardFrameEndUserInfoKey is the size of the frame when keyboard is on the screen
        let kbFrameSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//     height changes
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size .width, height: self.view.bounds.size.height+kbFrameSize.height)
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
    }
    
    func kbDidHide() {
      (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size .width, height: self.view.bounds.size.height)
    }

    
    func displayWarningLabel(withText text:String){
    warnLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: { [weak self] in //to avoid strong reference
    self?.warnLabel.alpha = 1
        }) { [weak self] (complete) in
            self?.warnLabel.alpha = 0
        }
    }
 

    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
        
        displayWarningLabel(withText: "Wrong info")
            return
        }
        
Auth.auth().signIn(withEmail: email, password: password) { [weak self](user, error) in
    if error != nil {
        self?.displayWarningLabel(withText: "error occured")
        return
    }
    if user != nil {
        self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
        return
    }
    self?.displayWarningLabel(withText: "No such user")
    
        }
        
    }

    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            
            displayWarningLabel(withText: "Wrong info")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
//            if error == nil {
//                if user != nil{
////                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
//                } else {
//                print("user is not created")
//                }
//            } else{
//            
//                print (error!.localizedDescription)
//            
//            }
            guard error == nil,  user != nil else {
                print (error!.localizedDescription)
                return
            }
            
            let userRef = self?.ref.child((user?.uid)!)
            userRef?.setValue(["email": user?.email])
            
            
        }
        
    }
   }

