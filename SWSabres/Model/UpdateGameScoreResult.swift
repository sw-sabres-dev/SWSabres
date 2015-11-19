//
//  UpdateGameScoreResult.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/19/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UpdateGameScoreResult: ResponseJSONObjectSerializable
{
    let success: Bool
    
    init?(json: SwiftyJSON.JSON)
    {
        if let successJsonValue = json["success"].number
        {
            self.success = successJsonValue.boolValue
        }
        else
        {
            self.success = false
        }
    }
}

