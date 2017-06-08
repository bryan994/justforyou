//
//  RegisterViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit
import FirebaseAuth
import FBSDKLoginKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddress.delegate = self
        username.delegate = self
        password.delegate = self

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapGesture)

    }
    
    @IBAction func facebookButton(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["public_profile", "email", "user_photos"], from: self, handler: { (result, error) in
            
            if error != nil {
                
                print("There is an error: \(String(describing: error))")
                
            }else if (result?.isCancelled) == true {
                
                print("Facebook cancelled")
                
            }else {
                
                print("Succesfully log in with facebook")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let user = user {
                        
                        UserDefaults.standard.set(user.uid, forKey: "userUID")
                        UserDefaults.standard.synchronize()
                        
                        let currentUserRef = DataService.usersRef.child(user.uid)
                        var userDict: Dictionary<String, String> = [:]
                        
                        if user.providerData[0].displayName != nil {
                            
                            userDict["username"] = user.providerData[0].displayName
                            
                        }
                        
                        if user.providerData[0].email != nil {
                            
                            userDict["email"] = user.providerData[0].email
                            
                        }
                        
                        currentUserRef.setValue(userDict)
                        
                        let appDelegateTemp = UIApplication.shared.delegate!
                        
                        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        // load view controller with the storyboardID of HomeTabBarController
                        let tabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController")
                        
                        appDelegateTemp.window?!.rootViewController = tabBarController
                    }
                }
            }
        
        })
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        guard
            let username = username.text,
            let email = emailAddress.text,
            let password = password.text else {
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            
            if let user = user {
                
                // stores into user defaults under key userUID, the user's
                UserDefaults.standard.set((user.uid), forKey: "userUID")
                User.signIn(uid: user.uid)
                
                self.performSegue(withIdentifier: "HomeSegue", sender: nil)
                
                let currentUserRef = DataService.usersRef.child(user.uid)
                let userDict = ["email": email, "username": username]
                currentUserRef.setValue(userDict)
                
            }else if email == "" || password == "" || username == "" {
                
                let alertController = UIAlertController(title: "Please don't leave the email, username or password empty", message: "Please fill in all column", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }else {
                
                let alert = UIAlertController(title: "Sign Up Failed", message: error?.localizedDescription, preferredStyle: .alert)
                
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                
                alert.addAction(dismissAction)
                
                self.present(alert, animated:true, completion: nil)
            }
        })
    }
    
    func dismissKeyboard() {
        
        emailAddress.resignFirstResponder()
        password.resignFirstResponder()
        username.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}
