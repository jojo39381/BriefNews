//
//  UITableViewCell.swift
//  BriefNews
//
//  Created by Joseph Yeh on 3/30/18.
//  Copyright © 2018 Joseph Yeh. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descn: UILabel!

    @IBOutlet weak var author: UILabel!
    
    
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var titleWidth: NSLayoutConstraint!
    @IBOutlet weak var descriptionWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var img: UIImageView!
    override func layoutSubviews() {
        super.layoutSubviews()
        title.sizeToFit()
    }
   
}
