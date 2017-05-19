//
//  LivefeedTableViewCell.swift
//  Just For You
//
//  Created by Bryan Lee on 08/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class LivefeedTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userCaption: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var postedImage: UIImageView!
    var followed: Bool = true
    var livefeed: Livefeed?
    
    @IBAction func followOnButtonPressed(_ sender: Any) {
        
        if followed {
            DataService.usersRef.child((livefeed?.userID)!).child("followers").updateChildValues([User.currentUserUid()!: true])
            DataService.usersRef.child(User.currentUserUid()!).child("following").updateChildValues([(livefeed?.userID)!: true])
            
            let value = ["userID":User.currentUserUid()!, "created_at":NSDate().timeIntervalSince1970, "profileID": (livefeed?.userID)!] as [String : Any]
            let currentUser = DataService.usersRef.child((livefeed?.userID)!).child("livefeed").childByAutoId()
            currentUser.setValue(value)
            
        }else {
            DataService.usersRef.child((livefeed?.userID)!).child("followers").child(User.currentUserUid()!).removeValue()
            DataService.usersRef.child(User.currentUserUid()!).child("following").child((livefeed?.userID)!).removeValue()
            
            DataService.usersRef.child((livefeed?.userID)!).child("livefeed").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.hasChildren() {
                    let keyArray = (snapshot.value as AnyObject).allKeys as! [String]
                    for key in keyArray {
                        DataService.usersRef.child((self.livefeed?.userID)!).child("livefeed").child(key).observeSingleEvent(of: .value, with: {snapshot2 in
                            if let live = Livefeed(snapshot: snapshot2) {
                                if live.profileID == self.livefeed?.userID!  && live.userID == User.currentUserUid() {
                                    DataService.usersRef.child((self.livefeed?.userID)!).child("livefeed").child(key).removeValue()
                                }
                            }
                        })
                    }
                }
                
            })
            
        }
    }
    
    
}
