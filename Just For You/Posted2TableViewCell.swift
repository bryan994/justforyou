//
//  Posted2TableViewCell.swift
//  Just For You
//
//  Created by Bryan Lee on 12/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

protocol CommentDelegate2: class{
    func commentOnButtonPressed(cell: Posted2TableViewCell)
}

class Posted2TableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userNameLocation: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var numberOfLikes: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    var check: Bool = true
    var likes: Bool = true
    var imageUID: Image?
    var delegate: CommentDelegate2?
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    @IBOutlet weak var postImageWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePosted))
        tapGesture.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(tapGesture)
        postImageView.isUserInteractionEnabled = true
        
    }
    
    func imagePosted(recognizer: UIGestureRecognizer) {
        
        let tappedImage = recognizer.view as! UIImageView
        let newImageView = UIImageView(image: #imageLiteral(resourceName: "filledheart"))
        newImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        newImageView.center = tappedImage.center
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            newImageView.removeFromSuperview()
            
            DataService.imagesRef.child((self.imageUID?.uid!)!).child("likes").updateChildValues([User.currentUserUid()!: true])
            
            self.checkLiveFeed()
        })
        tappedImage.addSubview(newImageView)
        tappedImage.bringSubview(toFront: newImageView)
        
        let anim = CABasicAnimation(keyPath: "transform")
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.duration = 0.8
        anim.repeatCount = 1
        anim.autoreverses = true
        anim.isRemovedOnCompletion = true
        anim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0))
        newImageView.layer.add(anim, forKey: nil)
        
        CATransaction.commit()
        
    }

    
    @IBAction func likeOnButtonPressed(_ sender: Any) {
        if self.likes {
            
            DataService.imagesRef.child((imageUID?.uid!)!).child("likes").updateChildValues([User.currentUserUid()!: true])
            
            self.checkLiveFeed()
            
        }else {
            DataService.imagesRef.child((imageUID?.uid!)!).child("likes").child(User.currentUserUid()!).removeValue()
            DataService.usersRef.child((imageUID?.userUID)!).child("livefeed").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.hasChildren() {
                    let keyArray = (snapshot.value as AnyObject).allKeys as! [String]
                    for key in keyArray {
                        DataService.usersRef.child((self.imageUID?.userUID)!).child("livefeed").child(key).observeSingleEvent(of: .value, with: {snapshot2 in
                            if let live = Livefeed(snapshot: snapshot2) {
                                if live.imageID == self.imageUID?.uid && live.userID == User.currentUserUid() {
                                    DataService.usersRef.child((self.imageUID?.userUID)!).child("livefeed").child(key).removeValue()
                                    self.check = true
                                }
                            }
                        })
                    }
                }
                
            })
        }
    }
    
    func checkLiveFeed() {
        
        if check && imageUID?.userUID != User.currentUserUid() {
            let value = ["userID":User.currentUserUid()!, "created_at":NSDate().timeIntervalSince1970, "imageURL": (imageUID?.imgurl)!, "imageID": (self.imageUID?.uid)!] as [String : Any]
            let currentUser = DataService.usersRef.child((imageUID?.userUID)!).child("livefeed").childByAutoId()
            currentUser.setValue(value)
            self.check = false
        }
        
        
    }
    
    @IBAction func commentOnButtonPressed(_ sender: Any) {
        
        self.delegate?.commentOnButtonPressed(cell: self)
    }
    
    @IBAction func shareOnButtonPressed(_ sender: Any) {
    }
    
    
}
