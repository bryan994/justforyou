//
//  FollowerTableViewCell.swift
//  Just For You
//
//  Created by Bryan Lee on 04/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class FollowerTableViewCell: UITableViewCell {

    @IBOutlet weak var follow: UIButton!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var followerImage: UIImageView!
    
    var followed: Bool = true
    
    var userID: User?
    
    @IBAction func followButton(_ sender: Any) {
        
        if followed {
            
            DataService.usersRef.child((userID?.uid)!).child("followers").updateChildValues([User.currentUserUid()!: true])
            DataService.usersRef.child(User.currentUserUid()!).child("following").updateChildValues([(userID?.uid)!: true])
            
            let value = ["userID":User.currentUserUid()!, "created_at":NSDate().timeIntervalSince1970, "profileID": (userID?.uid)!] as [String : Any]
            let currentUser = DataService.usersRef.child((userID?.uid)!).child("livefeed").childByAutoId()
            currentUser.setValue(value)
            
        }else {
            DataService.usersRef.child((userID?.uid)!).child("followers").child(User.currentUserUid()!).removeValue()
            DataService.usersRef.child(User.currentUserUid()!).child("following").child((userID?.uid!)!).removeValue()
            DataService.usersRef.child((userID?.uid)!).child("livefeed").observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.hasChildren() {
                    
                    let keyArray = (snapshot.value as AnyObject).allKeys as! [String]
                    for key in keyArray {
                        DataService.usersRef.child((self.userID?.uid)!).child("livefeed").child(key).observeSingleEvent(of: .value, with: {snapshot2 in
                            
                            if let live = Livefeed(snapshot: snapshot2) {
                                
                                if live.profileID == (self.userID?.uid)!  && live.userID == User.currentUserUid() {
                                    DataService.usersRef.child((self.userID?.uid)!).child("livefeed").child(key).removeValue()
                                    
                                }
                            }
                        })
                    }
                }
            })
        }
    }
}
