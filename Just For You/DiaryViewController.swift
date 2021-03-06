//
//  DiaryViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 11/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import FirebaseStorage
import GooglePlaces


class DiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentDelegate, MessageDelegate {

    @IBOutlet var tableView: UITableView!
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var listOfImage = [Image]()
        
    var imageID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Yinstagram"
    
        DataService.imagesRef.observe(.childAdded, with: { imageSnapshot in
            
            if let image = Image(snapshot: imageSnapshot){
                
                DataService.usersRef.child(image.userUID!).observeSingleEvent(of:.value, with: { userSnapshot in
                    
                    if let user = User(snapshot: userSnapshot){
                        
                        image.username = user.username
                        image.pImage = user.profileImage
                        self.listOfImage.append(image)
                        self.listOfImage.sort {$0.time! > $1.time!}
                        
                        self.tableView.reloadData()
                        
                    }
                })
            }
        })
    }
    
    @IBAction func camera(_ sender: Any) {
        
        self.performSegue(withIdentifier: "CameraSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return listOfImage.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func commentOnButtonPressed(cell: DiaryTableViewCell) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        let user = listOfImage[indexPath.section]
        self.imageID = user.uid
        
        self.performSegue(withIdentifier: "CommentSegue", sender: self)
    }
    
    func messageOnButtonPressed(cell: DiaryTableViewCell) {
        
        self.performSegue(withIdentifier: "MessageSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:DiaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell") as! DiaryTableViewCell
        
        let user = listOfImage[indexPath.section]
        
        if user.caption != "" {
            if let username = user.username, let caption = user.caption {
                let combination = NSMutableAttributedString()
                let transformCaption = Font.NormalString(text: caption, size: 14)
                let boldUsername = Font.BoldString(text: "\(username) ", size: 14)
                combination.append(boldUsername)
                combination.append(transformCaption)
                cell.captionLabel.attributedText = combination
                cell.captionLabel.isHidden = false
            }
            
        }else {
            
            cell.captionLabel.isHidden = true
            
        }
        
        if let userImageUrl = user.imgurl {
            
            let url = NSURL(string: userImageUrl)
            let frame = cell.postImageView.frame
            cell.postImageView.sd_setImage(with: url! as URL)
            cell.postImageView.frame = frame
            
        }
        
        if user.location == "" {
            
            cell.userName.text = user.username
            cell.stackView.isHidden = true
            cell.userName.isHidden = false
            
        }else {
            
            cell.userNameL.text = user.username
            let arrow = ">"
            let addFontArrow = Font.italicLocation(text: arrow)
            let italicLocation = Font.italicLocation(text: user.location!)
            let combination = NSMutableAttributedString()
            combination.append(italicLocation)
            combination.append(addFontArrow)
            cell.location.textColor = UIColor.lightGray
            cell.location.attributedText = combination
            cell.userName.isHidden = true
            cell.stackView.isHidden = false
        }
       
        if let profileImage = user.pImage {
            
                let url = NSURL(string: profileImage)
                let frame = cell.profileImage.frame
                cell.profileImage.sd_setImage(with: url! as URL)
                cell.profileImage.frame = frame
            
        }
        
        if user.pImage != "" {
            
            let url = NSURL(string: user.pImage!)
            let frame = cell.profileImage.frame
            cell.profileImage.sd_setImage(with: url! as URL)
            cell.profileImage.frame = frame
            
        }else {
            
            cell.profileImage.image = UIImage(named: "yin.jpg")
            
        }
        
        DataService.imagesRef.child(user.uid!).child("likes").observe(.value, with: { snapshot in
            if snapshot.hasChild(User.currentUserUid()!) {
                
                let origImage = UIImage(named: "heart2")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                cell.likeButton.setImage(tintedImage, for: .normal)
                cell.likeButton.tintColor = .red
                cell.likes = false
                cell.check = false
                
            }else {
                
                let origImage = UIImage(named: "heart2")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                cell.likeButton.setImage(tintedImage, for: .normal)
                cell.likeButton.tintColor =  UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
                cell.likes = true
                cell.check = true
            }
        })
        
        DataService.imagesRef.child(user.uid!).child("likes").observe(.value, with: {likesSnapshot in
            
            var count = 0
            count += Int(likesSnapshot.childrenCount)
            
            if count == 0 {
                
                cell.numberOfLikes.attributedText = Font.NormalString(text: "Kelian no people like ", size: 14)

            }else if count == 1 {
                
                cell.numberOfLikes.attributedText = Font.NormalString(text: "\(count) like", size: 14)

            }else {
                
                cell.numberOfLikes.attributedText = Font.NormalString(text: "\(count) likes", size: 14)

            }
            
        })


        
        let dateFromServer = NSDate(timeIntervalSince1970: user.time!)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd-MMMM-yyyy"
        let date = dateFormater.string(from: dateFromServer as Date)
        
        cell.timeLabel.font = UIFont(name: "Baskerville-Italic", size: 14)
        cell.timeLabel.textColor = UIColor.lightGray
        cell.timeLabel.text = date
        
        let button: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileSegue))
        button.numberOfTapsRequired = 1
        cell.profileImage.addGestureRecognizer(button)
        cell.profileImage.isUserInteractionEnabled = true 
            
        cell.postImageHeight.constant  = (screenSize.height/2)
        cell.postImageWidth.constant = (screenSize.width/2)

        cell.imageUID = user
        cell.delegate = self
        cell.delegate2 = self

        return cell
        
    }
    
    
    func userProfileSegue(recognizer: UIGestureRecognizer){
        
        let position: CGPoint =  recognizer.location(in: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: position)! as NSIndexPath
        
        let user = listOfImage[indexPath.section]
        
        if let userProfile = user.userUID {
            
            if userProfile == User.currentUserUid() {
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                nextViewController.userProfile = userProfile
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
                
            }else {
            
                let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                nextViewController.userProfile = userProfile
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "CommentSegue"{
            let nextScene = segue.destination as! CommentViewController
            nextScene.imageID = self.imageID
        }
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
    }

    
}




//let border = CALayer()
//let width: CGFloat = 1
//border.backgroundColor = UIColor.lightGray.cgColor
//border.frame = CGRect(x: 0, y: cell.containerView.frame.height - width, width: cell.containerView.frame.width, height: width)
//cell.containerView.layer.addSublayer(border)
