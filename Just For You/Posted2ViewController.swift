//
//  Posted2ViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 12/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class Posted2ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentDelegate2 {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listOfPost = [Image]()
    
    var likedUser = String()
    
    let screenSize: CGRect = UIScreen.main.bounds

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 570
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        DataService.imagesRef.observe(.childAdded, with: { imageSnapshot in
            
            if let image = Image(snapshot: imageSnapshot) {
                
                DataService.usersRef.child(image.userUID!).observeSingleEvent(of:.value, with: { userSnapshot in
                    
                    if let user = User(snapshot: userSnapshot) {
                        
                        image.username = user.username
                        image.pImage = user.profileImage
                        
                        if image.userUID == User.currentUserUid() {
                            
                            self.listOfPost.append(image)
                            self.listOfPost.sort {$0.time! > $1.time!}
                            
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                })
            }
        })
    }
    
    func commentOnButtonPressed(cell: Posted2TableViewCell) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        let user = listOfPost[indexPath.section]
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        nextViewController.imageID = user.uid
            
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.listOfPost.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Posted2TableViewCell = tableView.dequeueReusableCell(withIdentifier: "PostedCell2") as! Posted2TableViewCell
        
        let user = listOfPost[indexPath.section]
        
        if user.caption != "" {
            
            if let username = user.username, let caption = user.caption{
                
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
            
            cell.userNameLocation.text = user.username
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
            let frame = cell.profileImageView.frame
            cell.profileImageView.sd_setImage(with: url! as URL)
            cell.profileImageView.frame = frame
            
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
            count  += Int(likesSnapshot.childrenCount)
            if count == 0 {
                
                cell.numberOfLikes.attributedText = Font.NormalString(text: "Kelian NO PEOPLE LIKE", size: 14)
                
            }else if count == 1 {
                
                DataService.imagesRef.child(user.uid!).child("likes").observe(.childAdded, with: {likesSnapshot in
                    
                    DataService.usersRef.child(likesSnapshot.key).observeSingleEvent(of: .value, with: {userSnapshot in
                        
                        if let likedUser = User(snapshot: userSnapshot) {
                            
                            cell.numberOfLikes.font = UIFont(name: "Baskerville-Italic", size: 16)
                            cell.numberOfLikes.text = "Liked By \(String(describing: likedUser.username!))"
                            self.likedUser = likedUser.username!
                            
                        }
                    })
                })
                
            }else if count == 2 {
                
                cell.numberOfLikes.attributedText = Font.NormalString(text: "\(count) likes", size: 14)
                
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
                cell.numberOfLikes.attributedText = combination
                
            }
        })
        
        let dateFromServer = NSDate(timeIntervalSince1970: user.time!)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd-MMMM-yyyy"
        let date = dateFormater.string(from: dateFromServer as Date)
        
        cell.timeLabel.font = UIFont(name: "Baskerville-Italic", size: 14)
        cell.timeLabel.textColor = UIColor.lightGray
        cell.timeLabel.text = date
        
        cell.postImageHeight.constant = (screenSize.height/2)
        cell.postImageWidth.constant = (screenSize.width/2)
        
        cell.imageUID = user
        cell.delegate = self
        return cell
        
    }
}
