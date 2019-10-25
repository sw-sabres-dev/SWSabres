//
//  StringPathExtensions.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/3/15.
//  Copyright © 2015 Proscape Technologies. All rights reserved.
//

import Foundation

public extension String
{
    public func stringByAppendingPathComponent(_ path: String) -> String
    {
        return (self as NSString).appendingPathComponent(path)
    }
    
    public var lastPathComponent: String
    {
        get
        {
            return (self as NSString).lastPathComponent
        }
    }
    
    public var pathExtension: String
    {
        get
        {
            return (self as NSString).pathExtension
        }
    }
    
    public var stringByDeletingLastPathComponent: String
    {
        get
        {
            return (self as NSString).deletingLastPathComponent
        }
    }
    
    public func stringByAppendingPathExtension(_ ext: String) -> String?
    {
        return (self as NSString).appendingPathExtension(ext)
    }
    
    public var stringByDeletingPathExtension: String
    {
        get
        {
            return (self as NSString).deletingPathExtension
        }
    }
}
