//
//  LoginViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit
import Firebase


class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var userLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.delegate = self
        password.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapGesture)

    }
    

    @IBAction func loginButton(_ sender: Any) {
        
        guard let email = email.text, let password = password.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
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
    
    func dismissKeyboard() {
        
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
}
