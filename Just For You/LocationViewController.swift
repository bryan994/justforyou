//
//  LocationViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 21/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit
import GooglePlaces

protocol writeValueBackDelegate {
    
    func writeValueBack(value: String)
    
}

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var placesClient: GMSPlacesClient!
    
    var likeHoodList: GMSPlaceLikelihoodList?
    
    var delegate: writeValueBackDelegate?
    
    var placeName: String?
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            placesClient = GMSPlacesClient.shared()
            self.nearbyPlaces()
            
        } else if status == .denied || status == .restricted || status == .notDetermined {
            
            manager.requestWhenInUseAuthorization()
            
        }
    }
    
    func nearbyPlaces() {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            
            if let error = error {
                
                print("Pick Place error: \(error.localizedDescription)")
                return
                
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                
                self.likeHoodList = placeLikelihoodList
                self.tableView.reloadData()
                
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let likeHoodList = likeHoodList {
            
            return likeHoodList.likelihoods.count
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let place = likeHoodList?.likelihoods[indexPath.row].place
        cell.textLabel?.text = place?.name
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = likeHoodList?.likelihoods[indexPath.row].place
        
        self.placeName = place?.name
        
        self.delegate?.writeValueBack(value: self.placeName!)
        
        self.navigationController?.popViewController(animated: true)
        
    }
}
