//
//  AppDelegate.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()

        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GMSPlacesClient.provideAPIKey("AIzaSyDreArLvZND6vYGBql1bGmkPcVPShkwm-g")
        
//         if this key exist in userDefault
        if let _ = UserDefaults.standard.object(forKey: "userUID") as? String{
            
            // load storyboard
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            // load view controller with the storyboardID of HomeViewController
            let viewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController")
            
            self.window?.rootViewController = viewController
            
        }
        
        FIRDatabase.database().persistenceEnabled = true

        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1), NSFontAttributeName: UIFont(name: "Baskerville-Italic", size: 28)!]
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:UIBarMetrics.default)

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {

            if(GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])){
                
                return true
                
            }else if (FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])){
    
                return true
            }
    
            return false
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,accessToken: (authentication?.accessToken)!)

        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            UserDefaults.standard.set(user?.uid, forKey: "userUID")
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController")

            self.window?.rootViewController = viewController

            if let user = user{

                let firebaseRef = FIRDatabase.database().reference()

                let currentUserRef = firebaseRef.child("users").child(user.uid)

                let userEmail = user.providerData[0].email ?? ""
                let userDict = [ "username": user.providerData[0].displayName!, "email": userEmail]
                currentUserRef.setValue(userDict)

            }

        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        FBSDKAppEvents.activateApp()

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

