//
//  ProfileViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 12/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit
import Fusuma
import FirebaseStorage
import SDWebImage
import FirebaseAuth
import FBSDKLoginKit

protocol ChangeProfileImage{
    
    func changeImage(profileImage:UIImage)
}

class ProfileViewController: UIViewController, FusumaDelegate{
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var videoImageView: UIImageView!
    
    @IBOutlet var letterImageView: UIImageView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var postsLabel: UILabel!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var postsStackView: UIStackView!
    
    @IBOutlet weak var followersStackView: UIStackView!
    
    @IBOutlet weak var followingStackView: UIStackView!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    var buttonImages = [UIImageView]()
    
    var profileImage: UIImage?
    
    var facebookImage: UIImage?
    
    @IBOutlet weak var tableContainer: UIView!
    
    @IBOutlet weak var collectionContainer: UIView!
    
    @IBOutlet weak var segmentButton: UISegmentedControl!
    
    var userProfile =  User.currentUserUid()
    
    var delegate: ChangeProfileImage?
    
    var select: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.segmentButton.tintColor =  UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(changePicture(reco:))))

        buttonImages = [letterImageView, videoImageView]
        
        for imageView in buttonImages {
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClicked(reco:))))
            
        }
        
        retrieveUserInformation()
        
        if User.currentUserUid() == "cVCOcp4lbtZKJlzecrruZfrTkqC2" {
            
            self.videoImageView.isHidden = false
            self.letterImageView.isHidden = false
            
        }else {
            
            self.videoImageView.isHidden = true
            self.letterImageView.isHidden = true
            
        }
        
        let following: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followingTap))
        followingStackView.addGestureRecognizer(following)
        followingStackView.isUserInteractionEnabled = true
        
        let followers: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followersTap))
        followersStackView.addGestureRecognizer(followers)
        followersStackView.isUserInteractionEnabled = true
        
        automaticallyAdjustsScrollViewInsets = false

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if select {
            
            
            self.contentViewHeight.constant = self.collectionContainer.bounds.size.height + self.containerView.bounds.size.height - 108
            
            
        }else {
            
            self.contentViewHeight.constant = self.tableContainer.bounds.size.height + self.containerView.bounds.size.height
        }
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
    
    func retrieveUserInformation() {
        
        guard let currentUserID = self.userProfile else{
            return
        }
        DataService.usersRef.child(currentUserID).observeSingleEvent(of: .value, with: { userSnapshot in
            
            if let user = User(snapshot: userSnapshot) {
                
                if user.profileImage != "" {
                    
                    let url = NSURL(string: user.profileImage!)
                    self.imageView.sd_setImage(with: url! as URL)
                    self.usernameLabel.text = user.username
                    self.navigationItem.title = user.username
                    
                }else {
                    
                    self.imageView.image = UIImage(named: "yin.jpg")
                    
                }
                
                self.usernameLabel.text = user.username
                self.navigationItem.title = user.username
                
            }
        })
        
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
                self.select = false
            })
            
        } else {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionContainer.alpha = 0
                self.tableContainer.alpha = 1
                self.select = true
            })
        }
    }

    func changePicture(reco: UITapGestureRecognizer) {
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true // If you want to let the users allow to use video.
        self.present(fusuma, animated: true, completion: nil)
        
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        self.imageView.image = image
        self.delegate?.changeImage(profileImage: image)
        let uniqueImageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(uniqueImageName).png")
        
        let selectedImage = UIImageJPEGRepresentation((self.imageView.image)!, 0.5)!
        storageRef.putData(selectedImage, metadata: nil, completion: { (metadata, error) in
        
            if error != nil {
                
                print(error!)
                return
                
            }
            
            if let imageURL = metadata?.downloadURL()?.absoluteString, let user = User.currentUserUid() {
                
                SDImageCache.shared().store(self.imageView.image, forKey: imageURL)
                DataService.usersRef.child(user).updateChildValues(["profileImage":imageURL])
            }
        })
    }

    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
        
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
    }
    
    func fusumaClosed() {
        
    }
    
    func enableButton() {
        
        self.letterImageView.isUserInteractionEnabled = true
        self.videoImageView.isUserInteractionEnabled = true
        
    }
    
    func imageClicked(reco: UITapGestureRecognizer) {
        
        let imageViewTapped = reco.view as! UIImageView
        
        let alertController = UIAlertController(title: "Verification", message: "Please enter the verification code:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            if let field = alertController.textFields?[0] {
    
                if field.text == "123456"{
                    
                    if imageViewTapped.tag == 1 {
                        
                        self.performSegue(withIdentifier: "LetterSegue", sender: self)
                        
                    }else if imageViewTapped.tag == 2 {
                        
                        self.performSegue(withIdentifier: "VideoSegue", sender: self)
                    }
                    
                }else {
                    
                    self.letterImageView.isUserInteractionEnabled = false
                    self.videoImageView.isUserInteractionEnabled = false
                    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ProfileViewController.enableButton), userInfo: nil, repeats: false)
                    
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Verification Code"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutOnButtonPressed(_ sender: Any) {
        
        try! Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "userUID")
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        goBackToLogin()
        
    }
    
    func goBackToLogin() {
        
        let appDelegateTemp = UIApplication.shared.delegate!
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let LogInViewController = storyboard.instantiateInitialViewController()
        appDelegateTemp.window?!.rootViewController = LogInViewController
        
    }
}
