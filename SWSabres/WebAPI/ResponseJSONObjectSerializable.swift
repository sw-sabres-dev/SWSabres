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

extension ResponseJSONObjectSerializable
{
    static func loadObjects<T: ResponseJSONObjectSerializable>(fileName: String) -> [T]
    {
        var objects: [T] = [T]()
        
        if let data: NSData = NSData(contentsOfFile: fileName)
        {
            if let JSONObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            {
                let json = SwiftyJSON.JSON(JSONObject)
                
                let posts = json["posts"]
                
                for (_, item) in posts
                {
                    if let object = T(json: item)
                    {
                        objects.append(object)
                    }
                }
            }
        }
        
        return objects
    }
}