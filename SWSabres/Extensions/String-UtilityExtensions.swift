//
//  String-UtilityExtensions.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation

extension String
{
    static func isNilOrEmpty(string: String?) -> Bool
    {
        return string == nil || string!.isEmpty
    }
}