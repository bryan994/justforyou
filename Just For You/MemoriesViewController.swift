//
//  MemoriesViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit

class MemoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    var array = ["Singapore", "Melaka", "High School", "Ipoh"]
    
    var image: [UIImage] = [UIImage(named: "image1.jpg")!,UIImage(named: "image2.jpg")!,UIImage(named: "image3.jpg")!,UIImage(named: "image4.jpg")!]
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (width/2) - 15, height: (width/2) - 15)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoriesCell", for: indexPath) as! MemoriesCollectionViewCell
        
        cell.imageView.image = image[indexPath.row]
        
        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height/2
        cell.imageView.layer.masksToBounds = true

//        cell.layer.borderWidth = 1
//        cell.layer.cornerRadius = 8
        
        return cell
    }
}
