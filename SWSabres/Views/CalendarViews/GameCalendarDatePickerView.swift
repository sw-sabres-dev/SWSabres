//
//  GameCalendarDatePickerView.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/11/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import RSDayFlow

class GameCalendarDatePickerView: RSDFDatePickerView
{

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func collectionViewClass() -> AnyClass
    {
        return GameCalendarDatePickerCollectionView.self
    }
    
    override func dayCellClass() -> AnyClass
    {
        return GameCalendarDatePickerDayCell.self
    }
}
