//
//  UniqueObject.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/3/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol UniqueObject
{
    var uniqueId: String { get }
}

extension UniqueObject
{
    static func loadObjectMap<T where T: ResponseJSONObjectSerializable, T: UniqueObject>(fileName: String) -> [String: T]
    {
        var objectMap: [String: T] = [String: T]()
        
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
                        objectMap[object.uniqueId] = object
                    }
                }
            }
        }
        
        return objectMap
    }
}