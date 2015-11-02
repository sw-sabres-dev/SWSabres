//
//  ResponseJSONObjectSerializable.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol ResponseJSONObjectSerializable
{
    init?(json: SwiftyJSON.JSON)
}