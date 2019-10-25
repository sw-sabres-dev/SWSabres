//
//  LogoTitleView.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import THLabel

extension UIView
{
    @objc class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView?
    {
        return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

class LogoTitleView: UIView {

    @IBOutlet weak var titleLabel: THLabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        titleLabel.gradientStartColor = UIColor(red: 219/255, green: 221/255, blue: 222/255, alpha: 1)
        titleLabel.gradientEndColor = UIColor(red: 137/255, green: 140/255, blue: 144/255, alpha: 1)//137,140,144
        titleLabel.shadowColor = UIColor.black
        titleLabel.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
