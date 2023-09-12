//
//  ResponseJSONObjectSerializable.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import os.log

public protocol ResponseJSONObjectSerializable
{
    init?(json: SwiftyJSON.JSON)
}

extension ResponseJSONObjectSerializable
{
    static func loadObjectsFromData<T: ResponseJSONObjectSerializable>(_ data: Data) -> [T] {
        var objects: [T] = [T]()
        
        let json = SwiftyJSON.JSON(data)
        
        for (_, item) in json
        {
            if let object = T(json: item) {
                objects.append(object)
            } else {
                os_log("Unable to parse object: %@", String(describing: item))
            }
        }
        
        return objects
    }
    
    static func getObjects<T: ResponseJSONObjectSerializable>(_ urlBase: String) async -> [T]? {
        do {
            var allObjects: [T] = []
            var totalPages = -1
            var curPage = 0
            repeat {
                curPage = curPage + 1
                guard var urlComp = URLComponents(string: urlBase) else {
                    return nil
                }
                urlComp.queryItems = [
                    URLQueryItem(name: "per_page", value: "100"),
                    URLQueryItem(name: "page", value: String(curPage))
                ]
                guard let url = urlComp.url else {
                    return nil
                }
                os_log("Fetching from %@", String(describing: url))
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let response = response as? HTTPURLResponse else {
                    return nil
                }
                
                guard response.statusCode == 200 else {
                    return nil
                }
                
                allObjects += T.loadObjectsFromData(data)
                
                if let value = response.allHeaderFields["x-wp-totalpages"] as? String,
                   let totalPagesInt = Int(value)
                {
                    os_log("Using TotalPages = %d", totalPagesInt)
                    totalPages = totalPagesInt
                }
            } while (curPage < totalPages)
            
            return allObjects
        } catch {
            return nil
        }
    }
}
