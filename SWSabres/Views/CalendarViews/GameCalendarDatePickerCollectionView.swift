//
//  GameCalendarDatePickerCollectionView.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/11/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import RSDayFlow

class GameCalendarDatePickerCollectionView: RSDFDatePickerCollectionView
{

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func selfBackgroundColor() -> UIColor
    {
        return UIColor(red: 248.0/255, green:248.0/255, blue:248.0/255, alpha:1.0)
    }
}
