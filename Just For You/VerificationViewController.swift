//
//  ViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit
import FirebaseAuth
import FBSDKLoginKit


class VerificationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!

    var counter = 0
    
    var number = "(855)(0)86592888"

    var array = ["Please Ask A","Please Ask B","Please Ask C","Please Ask D","Please Ask E"]
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let button: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonFunc))
        button.numberOfTapsRequired = 1
        self.label.addGestureRecognizer(button)
        self.label.isUserInteractionEnabled = true
        self.textField.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VerificationViewController.dismissKeyboard)))
        self.view.backgroundColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        
    }
    
    func dismissKeyboard() {
        
        self.textField.resignFirstResponder()
        
    }
    
    @IBAction func submitButton(_ sender: Any) {
                
        if self.textField.text == "" {
            
            self.performSegue(withIdentifier: "HomeSegue", sender: self)
            
        }else if (self.textField.text?.isEmpty)! {
            
            let alert2 = UIAlertController(title: "Enter Password", message: "Please enter password to proceed", preferredStyle: .alert)
            let dismissButton = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            
            alert2.addAction(dismissButton)
            self.present(alert2, animated: true, completion: nil)
            
        }else {
            
            let alert = UIAlertController(title: "You have entered a wrong password.", message: "The screen is lock for 5 seconds", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
                
            }
        }
    }

    func buttonFunc() {
        
        guard let number = URL(string: "telprompt://" + number) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func onPressedButton(_ sender: Any) {
        
        self.label.text = array[self.counter]
        
        if self.counter == 4{
            
            counter = 4
            
        }else{
            
            counter += 1

        }
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        
        try! FIRAuth.auth()?.signOut()
        UserDefaults.standard.removeObject(forKey: "userUID")
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        goBackToLogin()
        
    }
    
    func goBackToLogin() {
        
        let appDelegateTemp = UIApplication.shared.delegate!
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let LogInViewController = storyboard.instantiateInitialViewController()
        appDelegateTemp.window?!.rootViewController = LogInViewController
        
    }
}

