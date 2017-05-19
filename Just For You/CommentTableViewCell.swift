//
//  CommentTableViewCell.swift
//  Just For You
//
//  Created by Bryan Lee on 02/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    var checker: Bool = true
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var like: UILabel!
    var imageID: String?
    var commentID: String?
    var comment: Comment?
    @IBOutlet weak var likeButton: UIButton!
    
    
    @IBAction func likeButton(_ sender: UIButton) {

        if self.checker {
            DataService.imagesRef.child(self.imageID!).child("comment").child(self.commentID!).child("likes").updateChildValues([User.currentUserUid()!: true])
            
            if comment?.userID == User.currentUserUid() {
                print ("Do nothing")
            }else {
                DataService.imagesRef.child(self.imageID!).observeSingleEvent(of:.value, with: { imageSnapshot in
                    
                    if let image = Image(snapshot: imageSnapshot) {
                        
                        let value = ["userID":User.currentUserUid()!, "created_at":NSDate().timeIntervalSince1970, "imageURL": (image.imgurl)!, "text": (self.comment?.text)!, "commentUID": self.commentID!, "identifier": "likeComment","imageID": self.imageID!] as [String : Any]
                        let currentUser = DataService.usersRef.child((self.comment?.userID)!).child("livefeed").childByAutoId()
                        currentUser.setValue(value)
                    }
                })
            }

        }else {
        DataService.imagesRef.child(self.imageID!).child("comment").child(self.commentID!).child("likes").child(User.currentUserUid()!).removeValue()
            DataService.usersRef.child((self.comment?.userID)!).child("livefeed").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.hasChildren() {
                    let keyArray = (snapshot.value as AnyObject).allKeys as! [String]
                    for key in keyArray {
                        DataService.usersRef.child((self.comment?.userID)!).child("livefeed").child(key).observeSingleEvent(of: .value, with: {snapshot2 in
                            if let live = Livefeed(snapshot: snapshot2) {
                                if live.commentUID == self.commentID && live.userID == User.currentUserUid() {
                                    DataService.usersRef.child((self.comment?.userID)!).child("livefeed").child(key).removeValue()
                                }
                            }
                        })
                    }
                }
                
            })
        }
    }

}
