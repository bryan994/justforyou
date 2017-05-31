//
//  CommentViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 02/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{

    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var listOfComment = [Comment]()
    
    var userCaption = [Image]()
    
    var imageID: String?
    
    var imageURL: String?
    
    var userUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        
        guard let imageUID = self.imageID else{
            return
        }
        
        DataService.imagesRef.child(imageUID).child("comment").observe(.childAdded, with: { commentSnapshot in
            
            if let comment = Comment(snapshot: commentSnapshot) {
                
                DataService.usersRef.child(comment.userID!).observeSingleEvent(of: .value, with: { userSnapshot in
                    
                    if let user = User(snapshot: userSnapshot) {
                        
                        comment.profileImage = user.profileImage
                        comment.userName = user.username
                        self.listOfComment.append(comment)
                        self.listOfComment.sort {$0.time! < $1.time!}
                        self.tableView.reloadData()
                        
                    }
                })
            }
        })
        
        DataService.imagesRef.child(imageUID).observe(.value, with: { imageSnapshot in
            
            if let image = Image(snapshot: imageSnapshot) {
                
                DataService.usersRef.child(image.userUID!).observeSingleEvent(of: .value, with: { userSnapshot in
                    
                    if let user = User(snapshot: userSnapshot) {
                        
                        image.pImage = user.profileImage
                        image.username = user.username
                        if self.userCaption.count == 0 {
                            
                            self.userCaption.append(image)
                            
                        }else {
                            
                            print("Do nothing")
                            
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                })
            }
        })
        
        DataService.imagesRef.child(self.imageID!).observeSingleEvent(of: .value, with: { imageSnapshot in
            
            let userDict = imageSnapshot.value as! [String: Any]
            self.userUID = userDict["userUID"] as? String
            self.imageURL = userDict["imgurl"] as? String
            
            
        })
        
        
        commentTextView.delegate = self
        
        self.tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        let border = CALayer()
        let width: CGFloat = 0.5
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width + 100, height: width)
        self.containerView.layer.addSublayer(border)
        

    }
    
    func moveTextView(textView: UITextView, moveDistance: Int, up:Bool) {
        
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.containerView.frame = self.containerView.frame.offsetBy(dx:0, dy: movement)
        UIView.commitAnimations()
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        moveTextView(textView: textView, moveDistance: -180, up: true)

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        moveTextView(textView: textView, moveDistance: -180, up: false)

    }
    
    func dismissKeyboard() {
        
        self.commentTextView.resignFirstResponder()
    }
    
    @IBAction func postCommentButton(_ sender: Any) {
        
        if self.commentTextView.text == "" {
            
            let alertController = UIAlertController(title: "Comment cannot be empty!!", message: "Please fill in something in the comment", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else {
            let value = ["text": self.commentTextView.text, "userID": User.currentUserUid()!, "created_at":NSDate().timeIntervalSince1970] as [String : Any]
            let currentUser = DataService.imagesRef.child(self.imageID!).child("comment").childByAutoId()
            currentUser.setValue(value)
            
            if let imageURL = self.imageURL, let currentUserID = User.currentUserUid(), let comment = self.commentTextView.text {
                
                let value2 = ["userID": currentUserID, "created_at":NSDate().timeIntervalSince1970, "text": comment, "identifier": "postComment", "imageURL": imageURL, "imageID": self.imageID!] as [String : Any]
                let currentUser2 = DataService.usersRef.child((self.userUID)!).child("livefeed").childByAutoId()
                currentUser2.setValue(value2)
            }
            
            self.tableView.reloadData()
        }


    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return userCaption.count
            
        }else {
            
            return listOfComment.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell2:CommentTableViewCell2 = tableView.dequeueReusableCell(withIdentifier: "CaptionCell") as! CommentTableViewCell2
            
            let caption = userCaption[indexPath.row]
            
            if let profileImage = caption.pImage{
                
                let url = NSURL(string: profileImage)
                let frame = cell2.imageView2.frame
                cell2.imageView2.sd_setImage(with: url! as URL)
                cell2.imageView2.frame = frame
                
            }
            
            cell2.imageView2.layer.cornerRadius = cell2.imageView2.frame.size.width/2
            cell2.imageView2.clipsToBounds = true
            cell2.imageView2.layer.borderWidth = 1
            cell2.imageView2.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
            
            cell2.label2.text = caption.caption
            
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileID))
            tapGesture.numberOfTapsRequired = 1
            cell2.imageView2.addGestureRecognizer(tapGesture)
            
            
            return cell2
            
        }else {
        
            let cell:CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
            
            let comment = listOfComment[indexPath.row]
            
            if let profileImage = comment.profileImage {
                
                let url = NSURL(string: profileImage)
                let frame = cell.profileImage.frame
                cell.profileImage.sd_setImage(with: url! as URL)
                cell.profileImage.frame = frame
                
            }
            
            let combination = NSMutableAttributedString()
            let boldString = Font.BoldString(text: "\(comment.userName!) ", size: 12)
            let normalString = Font.NormalString(text: comment.text!, size: 12)
            combination.append(boldString)
            combination.append(normalString)
            cell.label.attributedText = combination
                        
            let tapGesture2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileID2))
            tapGesture2.numberOfTapsRequired = 1
            cell.profileImage.addGestureRecognizer(tapGesture2)
            DataService.imagesRef.child(self.imageID!).child("comment").child(comment.uid!).child("likes").observeSingleEvent(of:.value, with: { commentSnapshot2 in
                        
                        if commentSnapshot2.hasChild(User.currentUserUid()!) {
                            
                            let origImage = UIImage(named: "heart2")
                            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                            cell.likeButton.setImage(tintedImage, for: .normal)
                            cell.likeButton.tintColor = .red
                            cell.checker = false
                            
                        }else {
                            
                            let origImage = UIImage(named: "heart2")
                            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                            cell.likeButton.setImage(tintedImage, for: .normal)
                            cell.likeButton.tintColor =  UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
                            cell.checker = true
                        }
                    })
            DataService.imagesRef.child(self.imageID!).child("comment").child(comment.uid!).child("likes").observe(.value, with: { commentSnapshot2 in
                            var count = 0
                            count  += Int(commentSnapshot2.childrenCount)
                
                            if count == 0 {
                                
                                cell.like.isHidden = true
                                
                            }else if count == 1 {
                                
                                cell.like.text = "\(count) like"
                                cell.like.isHidden = false
                                
                            }else {
                                
                                cell.like.text = "\(count) likes"
                                cell.like.isHidden = false
                                
                        }
                    })
            
            let dateFromServer = NSDate(timeIntervalSince1970: comment.time!)
            let dateFormater : DateFormatter = DateFormatter()
            dateFormater.dateFormat = "dd-MMMM-yyyy"
            let date = dateFormater.string(from: dateFromServer as Date)
            
            cell.date.font = UIFont(name: "Baskerville-Italic", size: 10)
            cell.date.textColor = UIColor.lightGray
            cell.date.text = date

                        
            cell.imageID = self.imageID
            cell.commentID = comment.uid
            cell.comment = comment
            return cell
        }
    }
    

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

            if editingStyle == .delete {
                
                DataService.imagesRef.child(self.imageID!).child("comment").observe(.childAdded, with: { imageSnapshot in
                    
                    if let comment = Comment(snapshot: imageSnapshot) {
                        
                        DataService.imagesRef.child(self.imageID!).child("comment").child(comment.uid!).removeValue()
                        self.listOfComment.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.reloadData()
                        
                    }
                })
            }
    }
    
    func userProfileID(reco: UITapGestureRecognizer) {
        
        let position: CGPoint =  reco.location(in: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: position)! as NSIndexPath
        
        let user = userCaption[indexPath.row]
        
        if let userUID = user.userUID{
            
            if userUID == User.currentUserUid() {
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                nextViewController.userProfile = userUID
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
                
            }else {
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                nextViewController.userProfile = userUID
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
    
    func userProfileID2(reco: UITapGestureRecognizer) {
        
        let position: CGPoint =  reco.location(in: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: position)! as NSIndexPath
        
        let user = listOfComment[indexPath.row]
        
        if let userID = user.userID{
            
            if userID == User.currentUserUid() {
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                nextViewController.userProfile = userID
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
                
            }else {
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                nextViewController.userProfile = userID
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
}
