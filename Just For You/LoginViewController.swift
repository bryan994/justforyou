//
//  LoginViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit
import Firebase
import FBSDKLoginKit


class LoginViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate{

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var googleLogin: GIDSignInButton!
    
    @IBOutlet weak var fbLogin: FBSDKLoginButton!
    
    @IBOutlet weak var userLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        
        fbLogin.delegate = self
        let titleText = NSAttributedString(string: "Sign in with Facebook")
        fbLogin.setAttributedTitle(titleText, for: .normal)
        
        email.delegate = self
        password.delegate = self
        
        buttonDesign()

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
        googleLogin.layer.cornerRadius = 5
        userLoginButton.layer.cornerRadius = 5
        
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
        
    }

    @IBAction func loginButton(_ sender: Any) {
        
        guard let email = email.text, let password = password.text else {
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let person = user {
                
                UserDefaults.standard.set((user!.uid), forKey: "userUID")
                User.signIn(uid: person.uid)
                self.performSegue(withIdentifier: "HomeSegue", sender: nil)
                
            }else if self.email.text == "" || self.password.text == "" {
                
                //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
                
                let alertController = UIAlertController(title: "Please don't leave the email or password empty", message: "Please enter your password again", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }else {
                
                let controller = UIAlertController(title: "Your email or password is incorrect?", message: "Please enter again", preferredStyle: .alert)
                let dismissButton = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                
                controller.addAction(dismissButton)
                
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton) {
                
    }
    
    func dismissKeyboard() {
        
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
}
