//
//  FollowerViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 02/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class FollowerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

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
        definesPresentationContext = true
        self.navigationItem.title = "Followers"
        
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        
        guard let currentUserID = self.userProfile else{
            return
        }
        
        DataService.usersRef.child(currentUserID).child("followers").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChildren() {
                let keyArray = (snapshot.value as AnyObject).allKeys as! [String]
                for key in keyArray {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell") as! FollowerTableViewCell
        
        let user: User
        
        if searchController.isActive && searchController.searchBar.text != "" {

            user = filteredListOfUser[indexPath.row]
            
        }else {
            
            user = listOfUser[indexPath.row]
        }
        
        if let userImageUrl = user.profileImage {
            
            let url = NSURL(string: userImageUrl)
            let frame = cell.followerImage.frame
            cell.followerImage.sd_setImage(with: url! as URL)
            cell.followerImage.frame = frame
        }
        
        cell.followerImage.layer.cornerRadius = cell.followerImage.frame.size.width/2
        cell.followerImage.clipsToBounds = true
        cell.followerImage.layer.borderWidth = 1
        cell.followerImage.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
        
        let bolded = Font.BoldString(text: user.username!, size: 12)
        cell.label.attributedText = bolded
        
        DataService.usersRef.child(User.currentUserUid()!).child("following").observe(.value, with: { userSnapshot in
            
            if user.myself {
                cell.follow.isHidden = true
            }else if userSnapshot.hasChild(user.uid!) {
                cell.follow.tintColor = UIColor.white
                cell.follow.setTitle("Following", for: UIControlState.normal)
                cell.follow.backgroundColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
                cell.follow.layer.cornerRadius = 5
                cell.follow.layer.borderWidth = 0.5
                cell.followed = false
            }else {
                cell.follow.tintColor = UIColor.black
                cell.follow.setTitle("Follow", for: UIControlState.normal)
                cell.follow.backgroundColor = UIColor.clear
                cell.follow.layer.cornerRadius = 5
                cell.follow.layer.borderWidth = 0.5
                cell.followed = true
            }
        })
        
        let button: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileSegue))
        button.numberOfTapsRequired = 1
        cell.followerImage.addGestureRecognizer(button)
        cell.followerImage.isUserInteractionEnabled = true

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
