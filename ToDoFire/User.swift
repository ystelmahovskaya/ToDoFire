//
//  User.swift
//  ToDoFire
//
//  Created by Yuliia Stelmakhovska on 2017-08-17.
//  Copyright © 2017 Yuliia Stelmakhovska. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email:String
    
    init(user: Firebase.User){
    self.uid = user.uid
        self.email = user.email!
    }
    
}
