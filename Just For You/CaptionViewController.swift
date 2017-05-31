//
//  CaptionViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 14/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class CaptionViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, writeValueBackDelegate{
    
    @IBOutlet weak var addLocation: DesignableTextField!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    var takenImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = takenImage
        self.captionTextView.layer.borderWidth = 1
        self.captionTextView.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.8).cgColor
        self.captionTextView.layer.cornerRadius = 5
        self.captionTextView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        self.addLocation.delegate = self
        addLocation.addTarget(self, action: #selector(CaptionViewController.textFieldShouldBeginEditing(_:)), for: UIControlEvents.editingDidBegin)

    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == self.addLocation) {
            
            self.performSegue(withIdentifier: "LocationSegue", sender: self)

            return false
        }
        
        return true

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LocationSegue" {
            
            let locationController = segue.destination as! LocationViewController
            locationController.delegate = self
            
        }
    }
    
    func writeValueBack(value: String) {
        
        self.addLocation.text = value
        
    }
    
    func dismissKeyboard() {
        
        self.captionTextView.resignFirstResponder()
        
    }
    

    @IBAction func shareButton(_ sender: Any) {
        
        if self.captionTextView.text == "" {
            
            let alertController = UIAlertController(title: "Caption empty!!", message: "Please fill in the caption", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else {
        
            let uniqueImageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("\(uniqueImageName).png")
            
            let postImage = UIImageJPEGRepresentation((self.takenImage),0.5)!
            storageRef.put(postImage, metadata: nil, completion: { metadata, error in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                    return
                    
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString, let user = User.currentUserUid(), let caption = self.captionTextView.text, let location = self.addLocation.text {
                    
                    let value = ["imgurl":imageURL, "userUID":user, "created_at":NSDate().timeIntervalSince1970, "caption":caption, "location": location] as [String : Any]
                    let currentUser = DataService.imagesRef.childByAutoId()
                    currentUser.setValue(value)
                    
                    
                    FIRDatabase.database().reference().child("users").child(user).child("images").updateChildValues([currentUser.key: true])
                    
                    SDImageCache.shared().store(self.takenImage, forKey: imageURL)
                    
                }
            })
            
            self.performSegue(withIdentifier: "HomeSegue", sender: self)
            
        }
    }

}


