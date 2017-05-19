//
//  PostedViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 24/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class PostedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var listOfImage = [Image]()
    var imageUID: String?
    var userProfile: String?
        
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: (width/3) - 1, height: (width/3) - 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
        guard let currentUserID = self.userProfile else {
            return
        }

        DataService.usersRef.child(currentUserID).child("images").observe(.childAdded, with: {userSnapshot in
            DataService.imagesRef.child(userSnapshot.key).observeSingleEvent(of: .value, with: {imagesSnpashot in
                if let image = Image(snapshot: imagesSnpashot) {
                    self.listOfImage.append(image)
                    self.listOfImage.sort {$0.time! > $1.time!}
                    self.collectionView.reloadData()
                }
            })
            
        })

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostedCell", for: indexPath) as! PostedCollectionViewCell
        
        let image = listOfImage[indexPath.row]
        
        if let userImageUrl = image.imgurl {
            
            let url = NSURL(string: userImageUrl)
            let frame = cell.imageView.frame
            cell.imageView.sd_setImage(with: url! as URL)
            cell.imageView.frame = frame
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SingleSegue" {
            let nextScene =  segue.destination as! SingleViewController
            nextScene.imageUID = self.imageUID
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image = listOfImage[indexPath.row]
        
        self.imageUID = image.uid
        self.performSegue(withIdentifier: "SingleSegue", sender: self)
        
    }

}
