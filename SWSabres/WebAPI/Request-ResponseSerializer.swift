//
//  Request-ResponseSerializer.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case objectSerialization(reason: String)
}

extension Alamofire.DataRequest
{
    public func responseObject<T: ResponseJSONObjectSerializable>(_ completionHandler: @escaping (DataResponse<T>) -> Void) -> Self
    {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            guard let responseData = data else {
                return .failure(BackendError.objectSerialization(reason: "Response could not be serialized because input data was nil."))
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            if result.isSuccess
            {
                if let value = result.value
                {
                    let json = SwiftyJSON.JSON(value)
                    if let newObject = T(json: json)
                    {
                        return .success(newObject)
                    }
                }
            }
            
            return .failure(error!)
        }
        
        return response(queue: DispatchQueue.main, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    public func responseArray<T: ResponseJSONObjectSerializable>(_ completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self
    {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let responseData = data else {
                return .failure(BackendError.objectSerialization(reason: "Response could not be serialized because input data was nil."))
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
                
            case .success(let value):
                let json = SwiftyJSON.JSON(value)
                var objects: [T] = []
                for (_, item) in json
                {
                    if let object = T(json: item)
                    {
                        objects.append(object)
                    }
                }
                return .success(objects)
                
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(queue: DispatchQueue.main, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    public func getPostsReponseArray<T: ResponseJSONObjectSerializable>(_ fileName: String? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self
    {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let responseData = data else {
                return .failure(BackendError.objectSerialization(reason: "Response could not be serialized because input data was nil."))
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
                
            case .success(let value):
                
                if let fileName = fileName
                {
                    try? responseData.write(to: URL(fileURLWithPath: fileName), options: [.atomic])
                }
                
                let json = SwiftyJSON.JSON(value)
                
                let posts = json["posts"]
                
                var objects: [T] = []
                for (_, item) in posts
                {
                    if let object = T(json: item)
                    {
                        objects.append(object)
                    }
                }
                return .success(objects)
                
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(queue: DispatchQueue.main, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

}
