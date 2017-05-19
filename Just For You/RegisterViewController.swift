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

class RegisterViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var googleLogin: GIDSignInButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var fbLogin: FBSDKLoginButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        fbLogin.delegate = self
        let titleText = NSAttributedString(string: "Sign in with Facebook")
        fbLogin.setAttributedTitle(titleText, for: .normal)
        fbLogin.readPermissions = ["public_profile", "email", "user_photos"]
        buttonDesign()
        
        emailAddress.delegate = self
        username.delegate = self
        password.delegate = self
        
        self.emailAddress.backgroundColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        self.emailAddress.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        self.username.backgroundColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        self.username.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        self.password.backgroundColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        self.password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        
        self.view.backgroundColor = UIColor.darkGray

        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
//        
//        self.view.addGestureRecognizer(tapGesture)

    }
    
    func moveTextField(textField: UITextField, moveDistance: Int, up:Bool) {
        
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx:0, dy: movement)
        UIView.commitAnimations()

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        moveTextField(textField: textField, moveDistance: -90, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        moveTextField(textField: textField, moveDistance: -90, up: false)
    }


    
    func buttonDesign() {
        
        fbLogin.layer.cornerRadius = 5
//        googleLogin.layer.cornerRadius = 5
        registerButton.layer.cornerRadius = 5
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if (error != nil) {
            
            print(error.localizedDescription)
            
        }else if (result.isCancelled) {
            
            print("Facebook cancelled")
            
        }else {
            
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
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
//                    if user.providerData[0].uid != "" {
//                        let profileURL = "https://graph.facebook.com/\(user.providerData[0].uid)/picture?type=large"
//                        let imgURL = NSURL(string: profileURL)
//                        let imageData = NSData.init(contentsOf: imgURL! as URL)
//                        let image = UIImage(data: imageData! as Data)
//                        userDict["facebookImage"] = image
//                    }

                    currentUserRef.setValue(userDict)
                    
                    let appDelegateTemp = UIApplication.shared.delegate!
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    // load view controller with the storyboardID of HomeTabBarController
                    let tabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController")
                    
                    appDelegateTemp.window?!.rootViewController = tabBarController
                }
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        guard
            let name = username.text,
            let email = emailAddress.text,
            let password = password.text else {
                return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {(user, error) in
            if let user = user {
                
                // stores into user defaults under key userUID, the user's
                UserDefaults.standard.set((user.uid), forKey: "userUID")
                User.signIn(uid: user.uid)
                
                self.performSegue(withIdentifier: "HomeSegue", sender: nil)
                
                let currentUserRef = DataService.usersRef.child(user.uid)
                let userDict = ["email": email, "username": name]
                currentUserRef.setValue(userDict)
                
            }else if self.emailAddress.text == "" || self.password.text == "" || self.username.text == "" {
                
                let alertController = UIAlertController(title: "Please don't leave the email or password empty", message: "Please enter your password again", preferredStyle: .alert)
                
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
