//
//  CornerRadius.swift
//  Just For You
//
//  Created by Bryan Lee on 24/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class CornerRadius: UIImageView {

    override func awakeFromNib() {
        
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).cgColor
    }

}

class CornerRadiusButton: UIButton {
    
    override func awakeFromNib() {
        
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    
}
