//
//  GameLogoTableViewCell.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/4/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

class GameLogoTableViewCell: UITableViewCell
{
    @IBOutlet weak var firstLogo: UIImageView!
    @IBOutlet weak var firstLogoLabel: UILabel!
    @IBOutlet weak var secondLogo: UIImageView!
    @IBOutlet weak var secondLogoLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
