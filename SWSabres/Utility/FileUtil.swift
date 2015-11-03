//
//  FileUtil.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/3/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation

public final class FileUtil
{
    public class func ensureFolder(folderPath: String) throws
    {
        let fileManager: NSFileManager = NSFileManager()
        
        if (fileManager.fileExistsAtPath(folderPath) == false)
        {
            try fileManager.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    public class func deleteFolder(folderPath: String) throws
    {
        let fileManager: NSFileManager = NSFileManager()
        
        if (fileManager.fileExistsAtPath(folderPath))
        {
            try fileManager.removeItemAtPath(folderPath)
        }
    }
    
    public class func ensureFileFolder(fileName: String) throws
    {
        return try FileUtil.ensureFolder(fileName.stringByDeletingLastPathComponent)
    }
    
    public class func contentsOfFolderSortedAscendingByFileModificationDate(folderPath: String) throws -> [String]
    {
        let fileManager: NSFileManager = NSFileManager()
        
        var filesArray: [String] = try fileManager.contentsOfDirectoryAtPath(folderPath)
        
        
        filesArray.sortInPlace { (string1: String, string2: String) -> Bool in
            
            let fullFileName1 = folderPath.stringByAppendingPathComponent(string1)
            let fullFileName2 = folderPath.stringByAppendingPathComponent(string2)
            
            do
            {
                // Sort the paths by the file modification date.
                let file1Attributes =  try fileManager.attributesOfItemAtPath(fullFileName1) as NSDictionary
                let file2Attributes =  try fileManager.attributesOfItemAtPath(fullFileName2) as NSDictionary
                
                if let file1ModDate = file1Attributes.fileModificationDate(), file2ModDate = file2Attributes.fileModificationDate()
                {
                    return file1ModDate.compare(file2ModDate) == .OrderedAscending
                }
                else
                {
                    return false
                }
            }
            catch
            {
                return false
            }
        }
        
        return filesArray
    }
    
    public class func getFreeSpace() throws -> UInt64
    {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let fileManager: NSFileManager = NSFileManager()
        
        let attributes = try fileManager.attributesOfFileSystemForPath(documentFolder) as NSDictionary
        
        if let fileSystemSizeInBytes: NSNumber = attributes.objectForKey(NSFileSystemFreeSize) as? NSNumber
        {
            return fileSystemSizeInBytes.unsignedLongLongValue
        }
        
        return 0
    }
    
    public class func getFreeSpaceAsMegaBytes() throws -> UInt64
    {
        return try self.getFreeSpace() / 1024 / 1024
    }
}