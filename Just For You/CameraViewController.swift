//
//  CameraViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 10/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit
import Fusuma

class CameraViewController: UIViewController, FusumaDelegate {
    
    var base64String: NSString!
    var cameraShown:Bool = false
    var tempImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !cameraShown{
            let fusuma = FusumaViewController()
            fusuma.delegate = self
            fusuma.hasVideo = true // If you want to let the users allow to use video.
            self.present(fusuma, animated: true, completion: {
                self.cameraShown = true
            })
        }
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        self.tempImage = image
        
        performSegue(withIdentifier: "CaptionSegue", sender: self)
        self.cameraShown = false

    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func fusumaClosed() {
        
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
        
        self.cameraShown = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CaptionSegue") {
            let nextScene =  segue.destination as! CaptionViewController
            nextScene.takenImage = self.tempImage
        }
    }



}
