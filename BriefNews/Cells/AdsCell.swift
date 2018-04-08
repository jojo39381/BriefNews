//
//  AdsCell.swift
//  BriefNews
//
//  Created by Joseph Yeh on 4/3/18.
//  Copyright © 2018 Joseph Yeh. All rights reserved.
//

import Foundation
class AdsCell: UITableViewCell {
    @IBOutlet weak var adTitle:UILabel!
    @IBOutlet weak var descript:UILabel!
    @IBOutlet weak var actionButton:UIButton!
    @IBOutlet weak var adImg:UIImageView!



    override func prepareForReuse() {
        super.prepareForReuse()
        self.adTitle.text = nil
        self.descript.text = nil
        
        self.adImg.image = nil // or set a placeholder image
    }
}
