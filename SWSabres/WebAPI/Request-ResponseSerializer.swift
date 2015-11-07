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

extension Alamofire.Request
{
    public func responseObject<T: ResponseJSONObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self
    {
        let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            if result.isSuccess
            {
                if let value = result.value
                {
                    let json = SwiftyJSON.JSON(value)
                    if let newObject = T(json: json)
                    {
                        return .Success(newObject)
                    }
                }
            }
            
            let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: "JSON could not be converted to object")
            return .Failure(error)
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    public func responseArray<T: ResponseJSONObjectSerializable>(completionHandler: Response<[T], NSError> -> Void) -> Self
    {
        let responseSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
            
            guard error == nil else
            {
                return .Failure(error!)
            }
            
            guard let responseData = data else
            {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
                
            case .Success(let value):
                let json = SwiftyJSON.JSON(value)
                var objects: [T] = []
                for (_, item) in json
                {
                    if let object = T(json: item)
                    {
                        objects.append(object)
                    }
                }
                return .Success(objects)
                
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    public func getPostsReponseArray<T: ResponseJSONObjectSerializable>(fileName: String? = nil, completionHandler: Response<[T], NSError> -> Void) -> Self
    {
        let responseSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
            
            guard error == nil else
            {
                return .Failure(error!)
            }
            
            guard let responseData = data else
            {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
                
            case .Success(let value):
                
                if let fileName = fileName
                {
                    responseData.writeToFile(fileName, atomically: true)
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
                return .Success(objects)
                
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

}