//
//  DiaryTableViewCell.swift
//  Just For You
//
//  Created by Bryan Lee on 11/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

protocol CommentDelegate: class{
    
    func commentOnButtonPressed(cell: DiaryTableViewCell)
    
}

protocol MessageDelegate: class{
    
    func messageOnButtonPressed(cell: DiaryTableViewCell)
    
}

class DiaryTableViewCell: UITableViewCell {
    
    var likes: Bool = true

    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var numberOfLikes: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    var imageUID: Image?
    
    @IBOutlet weak var userNameL: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    var check: Bool = true

    @IBOutlet weak var postImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    
    var delegate: CommentDelegate?
    
    var delegate2: MessageDelegate?
                
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
        newImageView.center = CGPoint(x: tappedImage.bounds.width/2, y: tappedImage.bounds.height/2)
        
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
        anim.duration = 0.5
        anim.repeatCount = 1
        anim.autoreverses = true
        anim.isRemovedOnCompletion = true
        anim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0))
        newImageView.layer.add(anim, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    @IBAction func onPressedLikeButton(_ sender: Any) {

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
    
    @IBAction func messageOnButtonPressed(_ sender: Any) {
        
        self.delegate2?.messageOnButtonPressed(cell:self)
        
    }
    
}
