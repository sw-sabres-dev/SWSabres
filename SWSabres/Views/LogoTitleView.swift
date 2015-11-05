//
//  LogoTitleView.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

extension UIView
{
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView?
    {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

class LogoTitleView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
