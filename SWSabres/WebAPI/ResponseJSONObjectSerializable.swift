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
    static func loadObjects<T: ResponseJSONObjectSerializable>(_ fileName: String) -> [T]
    {
        var objects: [T] = [T]()
        
        if let data: Data = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        {
            if let JSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
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
