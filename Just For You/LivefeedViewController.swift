//
//  LivefeedViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 08/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class LivefeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var listOfLivefeed = [Livefeed]()
    var refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 60
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.title = "Activity"
        
        guard let currentUserID = User.currentUserUid() else {
            return
        }
        
        DataService.usersRef.child(currentUserID).child("livefeed").observe(.childAdded, with: { liveSnapshot in
            if let livefeed = Livefeed(snapshot: liveSnapshot) {
                DataService.usersRef.child(livefeed.userID!).observeSingleEvent(of: .value, with: { userSnapshot in
                    if let user = User(snapshot: userSnapshot) {
                        livefeed.userName = user.username
                        livefeed.profileImage = user.profileImage
                        self.listOfLivefeed.append(livefeed)
                        self.listOfLivefeed.sort {$0.time! > $1.time!}
                        
                        self.tableView.reloadData()
        
                    }
                })
            }
        })
        
        DataService.usersRef.child(currentUserID).child("livefeed").observe(.value, with: { liveSnapshot in
            if liveSnapshot.hasChildren() {
                let keyArray = (liveSnapshot.value as AnyObject).allKeys as! [String]
                    for key in keyArray {
                        DataService.usersRef.child(currentUserID).child("livefeed").child(key).observe(.childRemoved, with: { liveSnapshot2 in
                            for (index,i) in self.listOfLivefeed.enumerated() {
                                if i.uid == key {
                                    self.listOfLivefeed.remove(at: index)
                                    self.tableView.reloadData()
                                    
                                }
                            }
                        })
                }
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Activity"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.listOfLivefeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LivefeedCell") as! LivefeedTableViewCell
        
        let livefeed = listOfLivefeed[indexPath.row]
        
        if livefeed.imageURL == "" {
            let url = NSURL(string: livefeed.profileImage!)
            let frame = cell.userImage.frame
            cell.userImage.sd_setImage(with: url! as URL)
            cell.userImage.frame = frame
            
            let combination = NSMutableAttributedString()
            let boldString = Font.BoldString(text: livefeed.userName!, size: 12)
            let normalString = Font.NormalString(text: " started following you.", size: 12)
            combination.append(boldString)
            combination.append(normalString)
            
            cell.userCaption.attributedText = combination
            
            DataService.usersRef.child(User.currentUserUid()!).child("following").observe(.value, with: { userSnapshot in
                
                if userSnapshot.hasChild(livefeed.userID!) {
                    
                    cell.followButton.tintColor = UIColor.white
                    cell.followButton.setTitle("Following", for: UIControlState.normal)
                    cell.followButton.backgroundColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
                    cell.followButton.layer.cornerRadius = 5
                    cell.followButton.layer.borderWidth = 0.5
                    cell.followed = false
                }else {
                    
                    cell.followButton.tintColor = UIColor.black
                    cell.followButton.setTitle("Follow", for: UIControlState.normal)
                    cell.followButton.backgroundColor = UIColor.clear
                    cell.followButton.layer.cornerRadius = 5
                    cell.followButton.layer.borderWidth = 0.5
                    cell.followed = true
                }
            })
            
            cell.postedImage.isHidden = true
            cell.followButton.isHidden = false
            
        }else if livefeed.identifier == "likeComment"  {
            let url = NSURL(string: livefeed.profileImage!)
            let frame = cell.userImage.frame
            cell.userImage.sd_setImage(with: url! as URL)
            cell.userImage.frame = frame
            
            let url2 = NSURL(string: livefeed.imageURL!)
            let frame2 = cell.postedImage.frame
            cell.postedImage.sd_setImage(with: url2! as URL)
            cell.postedImage.frame = frame2
            
            let combination = NSMutableAttributedString()
            let boldString = Font.BoldString(text: livefeed.userName!, size: 12)
            let normalString = Font.NormalString(text: " liked your comment: \(livefeed.text!)", size: 12)
            combination.append(boldString)
            combination.append(normalString)
            cell.userCaption.attributedText = combination
            
            cell.postedImage.isHidden = false
            cell.followButton.isHidden = true
            
        }else if livefeed.identifier == "postComment" {
            
            let url = NSURL(string: livefeed.profileImage!)
            let frame = cell.userImage.frame
            cell.userImage.sd_setImage(with: url! as URL)
            cell.userImage.frame = frame
            
            let url2 = NSURL(string: livefeed.imageURL!)
            let frame2 = cell.postedImage.frame
            cell.postedImage.sd_setImage(with: url2! as URL)
            cell.postedImage.frame = frame2
            
            let combination = NSMutableAttributedString()
            let boldString = Font.BoldString(text: livefeed.userName!, size: 12)
            let normalString = Font.NormalString(text: " commented: \(String(describing: livefeed.text!))", size: 12)
            combination.append(boldString)
            combination.append(normalString)
            cell.userCaption.attributedText = combination
            
            cell.postedImage.isHidden = false
            cell.followButton.isHidden = true
            
        }else {
            
            let url = NSURL(string: livefeed.profileImage!)
            let frame = cell.userImage.frame
            cell.userImage.sd_setImage(with: url! as URL)
            cell.userImage.frame = frame
            
            let url2 = NSURL(string: livefeed.imageURL!)
            let frame2 = cell.postedImage.frame
            cell.postedImage.sd_setImage(with: url2! as URL)
            cell.postedImage.frame = frame2
            
            let combination = NSMutableAttributedString()
            let boldString = Font.BoldString(text: livefeed.userName!, size: 12)
            let normalString = Font.NormalString(text: " liked your post.", size: 12)
            combination.append(boldString)
            combination.append(normalString)
            cell.userCaption.attributedText = combination
            
            cell.postedImage.isHidden = false
            cell.followButton.isHidden = true
        }
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.clipsToBounds = true
        cell.userImage.layer.borderWidth = 1
        cell.userImage.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
        
        let button: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileSegue))
        button.numberOfTapsRequired = 1
        cell.postedImage.addGestureRecognizer(button)
        cell.postedImage.isUserInteractionEnabled = true
        
        let image2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileSegue2))
        image2.numberOfTapsRequired = 1
        cell.userImage.addGestureRecognizer(image2)
        cell.userImage.isUserInteractionEnabled = true
        
        cell.livefeed = livefeed
        return cell
    }
    
    func userProfileSegue(recognizer: UIGestureRecognizer) {
        
        let position: CGPoint =  recognizer.location(in: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: position)! as NSIndexPath
        
        let live = listOfLivefeed[indexPath.row]
        
        if let imageID = live.imageID{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SingleViewController") as! SingleViewController
            nextViewController.imageUID = imageID
            
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func userProfileSegue2(recognizer: UIGestureRecognizer) {
        
        let position: CGPoint =  recognizer.location(in: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: position)! as NSIndexPath
        
        let live = listOfLivefeed[indexPath.row]
        
        if let userID = live.userID {
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            nextViewController.userProfile = userID
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }

    }
    
}
