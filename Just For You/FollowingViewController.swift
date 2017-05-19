//
//  FollowingViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 02/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    var userProfile: String?
    
    var listOfUser = [User]()
    
    var filteredListOfUser = [User]()
    
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 54
        tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false
        self.definesPresentationContext = true
        self.navigationItem.title = "Following"
        
        self.searchController = ({
            
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
            
        })()

        guard let currentUserID = self.userProfile else {
            return
        }
        
        DataService.usersRef.child(currentUserID).child("following").observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.hasChildren() {
                
                let keyArray = (snapshot.value as AnyObject).allKeys as! [String]
                for key in keyArray{
                    
                    DataService.usersRef.child(key).observeSingleEvent(of: .value, with: { userSnapshot in
                        
                        if let users = User(snapshot: userSnapshot) {
                            
                            self.listOfUser.append(users)
                            
                            for i in self.listOfUser {
                                
                                if i.uid == User.currentUserUid() {
                                    
                                    i.myself = true
                                    
                                }
                            }
                            
                            self.tableView.reloadData()
                            
                        }
                    })
                }
            }
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredListOfUser.removeAll(keepingCapacity: false)
        
        let array = listOfUser.filter() {
            
            $0.username!.lowercased().range(of: searchController.searchBar.text!.lowercased()) != nil
            
        }
        
        filteredListOfUser = array
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.searchController.isActive) {
            
            return self.filteredListOfUser.count
        }
            
        else {
            
            return self.listOfUser.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell") as! FollowingTableViewCell
        
        let user: User
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredListOfUser[indexPath.row]
            
        }else {
            
            user = listOfUser[indexPath.row]
        }
        
        if let userImageUrl = user.profileImage {
            
            let url = NSURL(string: userImageUrl)
            let frame = cell.profileImage2.frame
            cell.profileImage2.sd_setImage(with: url! as URL)
            cell.profileImage2.frame = frame
            
        }
        
        cell.profileImage2.layer.cornerRadius = cell.profileImage2.frame.size.width/2
        cell.profileImage2.clipsToBounds = true
        cell.profileImage2.layer.borderWidth = 1
        cell.profileImage2.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
        
        let bolded = Font.BoldString(text: user.username!, size: 12)
        cell.label2.attributedText = bolded
        
        DataService.usersRef.child(User.currentUserUid()!).child("following").observe(.value, with: { userSnapshot in
            
            if user.myself {
                
                cell.following.isHidden = true
                
            }else if userSnapshot.hasChild(user.uid!) {
                
                cell.following.tintColor = UIColor.white
                cell.following.setTitle("Following", for: UIControlState.normal)
                cell.following.backgroundColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
                cell.following.layer.cornerRadius = 5
                cell.following.layer.borderWidth = 0.5
                cell.following2 = false
                
            }else {
                
                cell.following.tintColor = UIColor.black
                cell.following.setTitle("Follow", for: UIControlState.normal)
                cell.following.backgroundColor = UIColor.clear
                cell.following.layer.cornerRadius = 5
                cell.following.layer.borderWidth = 0.5
                cell.following2 = true
                
            }
        })
        
        let button: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileSegue))
        button.numberOfTapsRequired = 1
        cell.profileImage2.addGestureRecognizer(button)
        cell.profileImage2.isUserInteractionEnabled = true
        
        cell.userID = user
        return cell
        
    }
    
    func userProfileSegue(recognizer: UIGestureRecognizer){
        
        let position: CGPoint =  recognizer.location(in: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: position)! as NSIndexPath
        
        let user = listOfUser[indexPath.row]
        
        if let userID = user.uid{
            
            if userID == User.currentUserUid() {
                
                self.userProfile = userID
                
                self.performSegue(withIdentifier: "ProfileSegue", sender: self)
                
            }else {
                
                self.userProfile = userID
                
                self.performSegue(withIdentifier: "UserSegue", sender: self)
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "UserSegue" {
            
            let nextScene = segue.destination as! UserProfileViewController
            nextScene.userProfile = self.userProfile
            
        }else if segue.identifier == "ProfileSegue" {
            
            let nextScene = segue.destination as! ProfileViewController
            nextScene.userProfile = self.userProfile
            
        }
    }
}
