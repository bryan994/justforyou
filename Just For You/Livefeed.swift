//
//  Livefeed.swift
//  Just For You
//
//  Created by Bryan Lee on 08/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Livefeed{
    
    var time: Double?
    var text: String?
    var uid:String?
    var userID: String?
    var profileID: String?
    var profileImage: String?
    var userName: String?
    var imageURL: String?
    var identifier: String?
    var commentUID: String?
    var imageID: String?

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
        if let dictImageURL = dict["imageURL"] as? String{
            self.imageURL = dictImageURL
        }else{
            self.imageURL = ""
        }
        if let dictProfileID = dict["profileID"] as? String{
            self.profileID = dictProfileID
        }else{
            self.profileID = ""
        }
        if let dictIdentifier = dict["identifier"] as? String{
            self.identifier = dictIdentifier
        }else{
            self.identifier = ""
        }
        if let dictCommentUID = dict["commentUID"] as? String{
            self.commentUID = dictCommentUID
        }else{
            self.commentUID = ""
        }
        if let dictImageID = dict["imageID"] as? String{
            self.imageID = dictImageID
        }else{
            self.imageID = ""
        }
    }
}
