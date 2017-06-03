//
//  TableView.swift
//  Just For You
//
//  Created by Bryan Lee on 02/06/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class TableView: UITableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.separatorStyle = UITableViewCellSeparatorStyle.none
        self.allowsSelection = false
        self.estimatedRowHeight = 570
        self.rowHeight = UITableViewAutomaticDimension
        
    }
    
    
}
