//
//  DataService.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct DataService{
    static var rootRef = FIRDatabase.database().reference()
    static var usersRef = FIRDatabase.database().reference().child("users")
    static var imagesRef = FIRDatabase.database().reference().child("images")

}
