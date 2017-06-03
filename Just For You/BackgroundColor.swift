//
//  BackgroundColor.swift
//  Just For You
//
//  Created by Bryan Lee on 02/06/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class BackgroundColor: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let color =  UIColor(red: 255.0/255.0, green: 111.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        let color2 = UIColor(red: 255.0/255.0, green: 182.0/255.0, blue: 193.0/255.0, alpha: 1.0).cgColor
        let color3 = UIColor(red: 255.0/255.0, green: 209.0/255.0, blue: 220.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        let deviceScale = UIScreen.main.scale
        gradientLayer.colors = [color, color2, color3]
        gradientLayer.locations = [0.0, 0.3, 0.8]
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width * deviceScale, height: self.frame.size.width * deviceScale)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }

}
