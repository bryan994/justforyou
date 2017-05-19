//
//  Font.swift
//  Just For You
//
//  Created by Bryan Lee on 25/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import Foundation

class Font{
    class func BoldString(text:String, size: Int) -> NSMutableAttributedString{
        
        let att = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: CGFloat(size))]
        let boldText = NSMutableAttributedString(string:text, attributes:att)
        
        return boldText
    }
    
    class func NormalString(text:String, size: Int) -> NSMutableAttributedString{
        
        let att = [NSFontAttributeName : UIFont.systemFont(ofSize: CGFloat(size), weight: UIFontWeightLight)]
        let normalText = NSMutableAttributedString(string:text, attributes:att)
        
        return normalText
    }
    

    class func italicLocation(text:String) -> NSMutableAttributedString{
        
        let att2 = [NSFontAttributeName:  UIFont.italicSystemFont(ofSize: 12)]
        let italicText = NSMutableAttributedString(string:text, attributes: att2)
        
        return italicText
    }
    
    
}
