//
//  TintColor.swift
//  Just For You
//
//  Created by Bryan Lee on 31/05/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class TintColor: UIButton{

    override func awakeFromNib() {
        
        self.tintColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)

    }

}

class TintColor2: UIBarButtonItem{
    
    override func awakeFromNib() {
        
        self.tintColor = UIColor(red: 255/255, green: 102/255, blue: 203/255, alpha: 1)
        
    }
    
}
