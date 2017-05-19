//
//  Comment.swift
//  Just For You
//
//  Created by Bryan Lee on 03/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Comment{
    
    var time: Double?
    var text: String?
    var uid:String?
    var userID: String?
    var profileImage: String?
    var userName: String?
    
    init?(snapshot: FIRDataSnapshot){
        
        self.uid = snapshot.key
        
        guard let dict = snapshot.value as? [String: AnyObject] else { return nil }
        
        if let dictTime = dict["created_at"] as? Double{
            self.time = dictTime
        }else{
            self.time = 0.0
        }
        if let dictUserID = dict["userID"] as? String{
            self.userID = dictUserID
        }else{
            self.userID = ""
        }
        if let dictText = dict["text"] as? String{
            self.text = dictText
        }else{
            self.text = ""
        }
    }
}
