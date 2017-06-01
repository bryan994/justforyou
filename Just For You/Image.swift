//
//  Image.swift
//  Just For You
//
//  Created by Bryan Lee on 14/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Image{
    
    var time: Double?
    var uid:String?
    var imgurl: String?
    var username: String?
    var userUID:String?
    var caption: String?
    var pImage: String?
    var numberOfLike: Int?
    var location:String?
    
    init?(snapshot: DataSnapshot){
        
        self.uid = snapshot.key
        
        guard let dict = snapshot.value as? [String: AnyObject] else { return nil }
        
        if let dictTime = dict["created_at"] as? Double{
            self.time = dictTime
        }else{
            self.time = 0.0
        }
        
        if let dictImgurl = dict["imgurl"] as? String{
            self.imgurl = dictImgurl
        }else{
            self.imgurl = ""
        }
        
        if let dictUserUID = dict["userUID"] as? String{
            self.userUID = dictUserUID
        }else{
            self.userUID = ""
        }
        
        if let dictCaption = dict["caption"] as? String{
            self.caption = dictCaption
        }else{
            self.caption = ""
        }
        if let dictLocation = dict["location"] as? String{
            self.location = dictLocation
        }else{
            self.location = ""
        }
    }
}

