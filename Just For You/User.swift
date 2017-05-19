//
//  User.swift
//  Just For You
//
//  Created by Bryan Lee on 30/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase


class User{
    
    var uid: String?
    var username: String?
    var profileImage: String?
    var backgroundImage: String?
    var follower: String?
    var following: String?
    var facebookImage: String?
    var location:String?
    var myself: Bool = false
    
    init?(snapshot: FIRDataSnapshot){
        
        self.uid = snapshot.key
        
        guard let dict = snapshot.value as? [String: AnyObject] else { return nil }
        
        if let dictCaption = dict["username"] as? String{
            self.username = dictCaption
        }else{
            self.username = ""
        }
        if let dictProfile = dict["profileImage"] as? String{
            self.profileImage = dictProfile
        }else{
            self.profileImage = ""
        }
        if let dictFollower = dict["follower"] as? String{
            self.follower = dictFollower
        }else{
            self.follower = ""
        }
        if let dictFollowing = dict["following"] as? String{
            self.following = dictFollowing
        }else{
            self.following = ""
        }
        if let dictFacebookImage = dict["facebookImage"] as? String{
            self.facebookImage = dictFacebookImage
        }else{
            self.facebookImage = ""
        }

        
    }
    
    class func signIn (uid: String){
        //storing the uid of the person in the phone's default settings.
        UserDefaults.standard.setValue(uid, forKeyPath: "userUID")
        
    }
    
    class func isSignedIn() -> Bool {
        
        if let _ = UserDefaults.standard.value(forKey: "userUID") as? String{
            return true
        }else {
            return false
        }
        
    }
    class func currentUserUid() -> String? {
        return UserDefaults.standard.value(forKey: "userUID") as? String
    }
}
