//
//  PreviewViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit
import GooglePlaces

class PreviewViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    var timer = Timer()
    
    var counter = 0
    
    var counter2 = 0
    
    var locationManager: CLLocationManager!

    
    var array = ["Hello", "Hi", "Bye", "Love", "Congratulation"]
    var image: [UIImage] = [UIImage(named: "image1.jpg")!,UIImage(named: "image2.jpg")!,UIImage(named: "image3.jpg")!,UIImage(named: "image4.jpg")!,UIImage(named: "image5.jpg")!,UIImage(named: "image6.jpg")!,UIImage(named: "image7.jpg")!]


    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()


        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(PreviewViewController.updateCounter), userInfo: nil, repeats: true)
        
        self.view.bringSubview(toFront: label);
        label.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        let button: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        button.numberOfTapsRequired = 1
        self.label.addGestureRecognizer(button)
        self.label.isUserInteractionEnabled = true

    }
    
    
    func tapGesture() {
        
        self.label.text = array[self.counter2]
        
        if self.counter2 == 4{
            counter2 = 0
        }else{
            counter2 += 1
        }
    }

    func updateCounter() {

        counter += 1

        if counter == 7{
            counter = 1
        }
        imageView.image = image[self.counter]
    }

}
