//
//  GamesViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 13/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class GamesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var array: [UIImage] = [UIImage(named: "letter.png")!, UIImage(named: "letter.png")!, UIImage(named: "video.png")!, UIImage(named: "video.png")!]

    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Games"

        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 40, left: 10, bottom: 20, right: 10)
        layout.itemSize = CGSize(width: (width/2) - 15, height: (width/2) - 15)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    
    }
    // Set animation in the cell
    func animateCell(cell: UICollectionViewCell) {
        let anim = CABasicAnimation(keyPath: "transform")
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.duration = 0.8
        anim.repeatCount = 1
        anim.autoreverses = true
        anim.isRemovedOnCompletion = true
        anim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0))
        cell.layer.add(anim, forKey: nil)
    }

    // Perform animation then only segue
    func durationOfCollectionView(segue: String, indexPath: NSIndexPath) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.performSegue(withIdentifier: segue, sender: self)
            
        })
        guard let cell = collectionView.cellForItem(at: indexPath as IndexPath) else { return }
        animateCell(cell: cell)
        
        CATransaction.commit()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GamesCell", for: indexPath) as! GamesCollectionViewCell
        
        cell.gamesImageView.image = array[indexPath.row]
        
        cell.layer.shadowColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
        cell.layer.shadowRadius = 10
        cell.layer.shadowOpacity = 1.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            durationOfCollectionView(segue: "AddSegue", indexPath: indexPath as NSIndexPath)
            
        }else if indexPath.row == 1 {
            
            durationOfCollectionView(segue: "TicSegue", indexPath: indexPath as NSIndexPath)

        }else if indexPath.row == 2 {
            
            durationOfCollectionView(segue: "QuizSegue", indexPath: indexPath as NSIndexPath)

        }else if indexPath.row == 3 {
            
            durationOfCollectionView(segue: "Quiz2Segue", indexPath: indexPath as NSIndexPath)
        }
    }
}
