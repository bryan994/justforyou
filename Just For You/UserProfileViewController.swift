//
//  UserProfileViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 25/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit
import SDWebImage

class UserProfileViewController: UIViewController{
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var viewHeight: UIView!
    
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var postsStackView: UIStackView!
    @IBOutlet weak var followersStackView: UIStackView!
    @IBOutlet weak var followingStackView: UIStackView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var collectionContainer: UIView!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    var userProfile: String?
    var select: Bool = true
    
    @IBOutlet weak var segmentButton: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentButton.tintColor =  UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)

        retrieveUserInformation()
        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        let following: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followingTap))
        followingStackView.addGestureRecognizer(following)
        followingStackView.isUserInteractionEnabled = true
        
        let followers: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followersTap))
        followersStackView.addGestureRecognizer(followers)
        followersStackView.isUserInteractionEnabled = true
        
        self.contentViewHeight.constant = self.collectionContainer.bounds.size.height + self.viewHeight.bounds.size.height

    }
    
    func followingTap() {
        
        self.performSegue(withIdentifier: "FollowingSegue", sender: self)
        
    }
    
    func followersTap() {
        
        self.performSegue(withIdentifier: "FollowerSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostedSegue" {
            let nextScene = segue.destination as! PostedViewController
            nextScene.userProfile = self.userProfile
        }else if segue.identifier == "FollowerSegue" {
            let nextScene = segue.destination as! FollowerViewController
            nextScene.userProfile = self.userProfile
        }else if segue.identifier == "FollowingSegue" {
            let nextScene = segue.destination as! FollowingViewController
            nextScene.userProfile = self.userProfile
        }
    }
    
    @IBAction func followingButton(_ sender: Any) {
        if select {
            DataService.usersRef.child(User.currentUserUid()!).child("following").updateChildValues([userProfile!: true])
            DataService.usersRef.child(self.userProfile!).child("followers").updateChildValues([User.currentUserUid()!: true])
            self.followButton.tintColor = UIColor.red
            
            let value = ["created_at":NSDate().timeIntervalSince1970, "userID": User.currentUserUid()!, "profileID": self.userProfile!] as [String : Any]
            let currentUser = DataService.usersRef.child(self.userProfile!).child("livefeed").childByAutoId()
            currentUser.setValue(value)
            
        }else {
            DataService.usersRef.child(User.currentUserUid()!).child("following").child(userProfile!).removeValue()
            DataService.usersRef.child(self.userProfile!).child("followers").child(User.currentUserUid()!).removeValue()
            
            DataService.usersRef.child((self.userProfile)!).child("livefeed").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.hasChildren() {
                    let keyArray = (snapshot.value as AnyObject).allKeys as! [String]
                    for key in keyArray{
                        DataService.usersRef.child((self.userProfile)!).child("livefeed").child(key).observeSingleEvent(of: .value, with: {snapshot2 in
                            if let live = Livefeed(snapshot: snapshot2) {
                                if live.profileID == self.userProfile  && live.userID == User.currentUserUid() {
                                    DataService.usersRef.child((self.userProfile)!).child("livefeed").child(key).removeValue()
                                }
                            }
                        })
                    }
                }
            })

            self.followButton.tintColor = UIColor.black
        }
    }
    func retrieveUserInformation() {
        
        guard let currentUserID = self.userProfile else{
            return
        }
        DataService.usersRef.child(currentUserID).observeSingleEvent(of: .value, with: { userSnapshot in
            if let user = User(snapshot: userSnapshot) {
                if user.profileImage != "" {
                    let url = NSURL(string: user.profileImage!)
                    self.imageView.sd_setImage(with: url! as URL)
                }else {
                    self.imageView.image = UIImage(named: "yin.jpg")
                }
                self.usernameLabel.text = user.username
                self.navigationItem.title = user.username
            }
            
        })
        
        DataService.usersRef.child(User.currentUserUid()!).child("following").observe(.value, with: { userSnapshot in
            
            if userSnapshot.hasChild(self.userProfile!) {
                self.followButton.tintColor = UIColor.black
                self.followButton.setTitle("Following", for: UIControlState.normal)
                self.followButton.backgroundColor = UIColor.clear
                self.followButton.layer.cornerRadius = 5
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor.black.cgColor
                self.select = false
            }else {
                self.followButton.tintColor = UIColor.white
                self.followButton.setTitle("Follow", for: UIControlState.normal)
                self.followButton.backgroundColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
                self.followButton.layer.cornerRadius = 5
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1).cgColor
                self.select = true
            }
        })
        
    /*
         
         cell.followingButton.backgroundColor = UIColor.locusBlueColor()
         cell.followingButton.setTitle("Following", forState: .Normal)
         cell.followingButton.layer.cornerRadius = 5
         cell.followingButton.layer.borderWidth = 1
         cell.checker = true
         
         }else{
         cell.followingButton.backgroundColor = UIColor.clearColor()
         cell.followingButton.setTitle("Follow", forState: .Normal)
         cell.followingButton.layer.cornerRadius = 5
         cell.followingButton.layer.borderWidth = 1
         cell.checker = false
 
 */
        
        DataService.usersRef.child(currentUserID).child("images").observe(.value, with: { userSnapshot in
            var count = 0
            count  += Int(userSnapshot.childrenCount)
            
            self.postsLabel.text = String(count)
        })
        
        DataService.usersRef.child(currentUserID).child("followers").observe(.value, with: { userSnapshot in
            var count = 0
            count  += Int(userSnapshot.childrenCount)
            
            self.followersLabel.text = String(count)
        })
        
        DataService.usersRef.child(currentUserID).child("following").observe(.value, with: { userSnapshot in
            var count = 0
            count  += Int(userSnapshot.childrenCount)
            
            self.followingLabel.text = String(count)
        })
    }
    
    @IBAction func segmentButtonAction(_ sender: Any) {
        
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionContainer.alpha = 1
                self.tableContainer.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionContainer.alpha = 0
                self.tableContainer.alpha = 1
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
    }
}

