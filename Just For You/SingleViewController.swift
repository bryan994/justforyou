//
//  SingleViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 25/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class SingleViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userNameL: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var likes: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var likeButton2: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var postedImage: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var postImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentButton: UIButton!
    
    var imageUID: String?
    
    var userProfile: String?
    
    var likedUser = String()
    
    var likes2: Bool = true
    
    let screenSize: CGRect = UIScreen.main.bounds

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Photo"

        guard let currentImageID = self.imageUID else {
           
            return
        }
        DataService.imagesRef.child(currentImageID).observeSingleEvent(of: .value, with: {imageSnapshot in
            
            if let image = Image(snapshot: imageSnapshot) {
                
                DataService.usersRef.child(User.currentUserUid()!).observeSingleEvent(of:.value, with: {userSnapshot in
                    
                    if let user = User(snapshot: userSnapshot) {
                        
                        image.pImage = user.profileImage
                        
                        if image.caption != "" {
                            
                            if let username = user.username, let caption = image.caption {
                                
                                let combination = NSMutableAttributedString()
                                let transformCaption = Font.NormalString(text: caption, size: 14)
                                let boldUsername = Font.BoldString(text: "\(username) ", size: 14)
                                combination.append(boldUsername)
                                combination.append(transformCaption)
                                self.captionLabel.attributedText = combination
                                self.captionLabel.isHidden = false
                                
                            }
                            
                        }else {
                            
                            self.captionLabel.isHidden = true
                            
                        }
                        
                        if let userImageUrl = image.imgurl {
                            
                            let url = NSURL(string: userImageUrl)
                            let frame = self.postedImage.frame
                            self.postedImage.sd_setImage(with: url! as URL)
                            self.postedImage.frame = frame
                        
                        }
                        
                        if image.location == "" {
                            
                            self.userName.text = user.username
                            self.stackView.isHidden = true
                            self.userName.isHidden = false
                            
                        }else {
                            
                            self.userNameL.text = user.username
                            let arrow = ">"
                            let addFontArrow = Font.italicLocation(text: arrow)
                            let italicLocation = Font.italicLocation(text: image.location!)
                            let combination = NSMutableAttributedString()
                            combination.append(italicLocation)
                            combination.append(addFontArrow)
                            self.location.textColor = UIColor.lightGray
                            self.location.attributedText = combination
                            self.userName.isHidden = true
                            self.stackView.isHidden = false
                            
                        }
                        
                        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                        self.profileImage.clipsToBounds = true
                        self.profileImage.layer.borderWidth = 1
                        self.profileImage.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
                        
                        if let profileImage = image.pImage {
                            
                            let url = NSURL(string: profileImage)
                            let frame = self.profileImage.frame
                            self.profileImage.sd_setImage(with: url! as URL)
                            self.profileImage.frame = frame
                            
                        }
                        
                        DataService.imagesRef.child(self.imageUID!).child("likes").observe(.value, with: {likesSnapshot in
                            
                            var count = 0
                            count  += Int(likesSnapshot.childrenCount)
                            if count == 0 {
                                
                                self.likes.attributedText = Font.NormalString(text: "Kelian NO PEOPLE LIKE", size: 14)
                                
                            }else if count == 1 {
                                
                                DataService.imagesRef.child(self.imageUID!).child("likes").observe(.childAdded, with: {likesSnapshot in
                                    DataService.usersRef.child(likesSnapshot.key).observeSingleEvent(of: .value, with: {userSnapshot in
                                        
                                        if let likedUser = User(snapshot: userSnapshot) {
                                            
                                            let combination = NSMutableAttributedString()
                                            let boldString = Font.BoldString(text:  likedUser.username!, size: 14)
                                            let likeBy = Font.NormalString(text: "Liked By ", size: 14)
                                            combination.append(likeBy)
                                            combination.append(boldString)
                                            self.likes.attributedText = combination
                                            self.likedUser = likedUser.username!
                                            
                                        }
                                    })
                                })
                                
                            }else if count == 2 {
                                
                                self.likes.attributedText = Font.NormalString(text: "\(count) likes", size: 14)
                                
                            }else {
                                
                                let likesCount = String(count - 1)
                                let combination = NSMutableAttributedString()
                                let boldUsername = Font.BoldString(text: self.likedUser, size: 14)
                                let countOthers = Font.BoldString(text: "\(likesCount) others", size: 14)
                                let likeBy = Font.NormalString(text: "Liked By ", size: 14)
                                let and = Font.NormalString(text: " and ", size: 14)
                                combination.append(likeBy)
                                combination.append(boldUsername)
                                combination.append(and)
                                combination.append(countOthers)
                                self.likes.attributedText = combination
                                
                            }
                        })
                        
                        let dateFromServer = NSDate(timeIntervalSince1970: image.time!)
                        let dateFormater : DateFormatter = DateFormatter()
                        dateFormater.dateFormat = "dd-MMMM-yyyy"
                        let date = dateFormater.string(from: dateFromServer as Date)
                        
                        self.dateLabel.font = UIFont(name: "Baskerville-Italic", size: 14)
                        self.dateLabel.textColor = UIColor.lightGray
                        self.dateLabel.text = date
                        
                        self.userProfile = image.userUID
                    
                    }
                })
            }
        })
        
        DataService.imagesRef.child(self.imageUID!).child("likes").observe(.value, with: { snapshot in
            
            if snapshot.hasChild(User.currentUserUid()!) {
                
                let origImage = UIImage(named: "heart2")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                self.likeButton2.setImage(tintedImage, for: .normal)
                self.likeButton2.tintColor = .red
                self.likes2 = false
                
            }else {
                
                let origImage = UIImage(named: "heart2")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                self.likeButton2.setImage(tintedImage, for: .normal)
                self.likeButton2.tintColor =  UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
                self.likes2 = true
                
            }
        })
        
        let origImage2 = UIImage(named: "share")
        let tintedImage2 = origImage2?.withRenderingMode(.alwaysTemplate)
        self.shareButton.setImage(tintedImage2, for: .normal)
        self.shareButton.tintColor =  UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
        
        let origImage3 = UIImage(named: "comment")
        let tintedImage3 = origImage3?.withRenderingMode(.alwaysTemplate)
        self.commentButton.setImage(tintedImage3, for: .normal)
        self.commentButton.tintColor =  UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
        
        postImageHeight.constant = (screenSize.height/2)
        postImageWidth.constant = (screenSize.width/2)
        
        let button: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userID))
        button.numberOfTapsRequired = 1
        self.profileImage.addGestureRecognizer(button)
        self.profileImage.isUserInteractionEnabled = true

    }
    
    func userID() {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        nextViewController.userProfile = userProfile
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func likeButton(_ sender: Any) {
        
        if self.likes2 {
            
            DataService.imagesRef.child((self.imageUID)!).child("likes").updateChildValues([User.currentUserUid()!: true])
            self.likes2 = false
            
        }else {
            DataService.imagesRef.child((self.imageUID)!).child("likes").child(User.currentUserUid()!).removeValue()
            
            self.likes2 = true
        }
    }

    @IBAction func commentButton(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        nextViewController.imageID = self.imageUID
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
}
