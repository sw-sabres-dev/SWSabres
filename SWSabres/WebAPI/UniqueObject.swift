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
    static func loadObjectMap<T>(_ fileName: String) -> [String: T] where T: ResponseJSONObjectSerializable, T: UniqueObject
    {
        var objectMap: [String: T] = [String: T]()
        
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
                        objectMap[object.uniqueId] = object
                    }
                }
            }
        }
        
        return objectMap
    }
}
