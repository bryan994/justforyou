//
//  TextfieldBorder.swift
//  Just For You
//
//  Created by Bryan Lee on 02/06/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit


class BorderLine: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let border = CALayer()
        let width: CGFloat = 1
        border.backgroundColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width + 50, height: width)
        self.layer.addSublayer(border)
        
        self.tintColor = .white
        self.textColor = .white
    }
}
