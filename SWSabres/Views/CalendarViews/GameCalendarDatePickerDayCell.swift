//
//  GameCalendarDatePickerDayCell.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/13/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import RSDayFlow

class GameCalendarDatePickerDayCell: RSDFDatePickerDayCell {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func selectedDayImageColor() -> UIColor
    {
        return AppTintColors.backgroundTintColor
    }
}
