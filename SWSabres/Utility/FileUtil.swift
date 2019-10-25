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
    public class func ensureFolder(_ folderPath: String) throws
    {
        let fileManager: FileManager = FileManager()
        
        if (fileManager.fileExists(atPath: folderPath) == false)
        {
            try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    public class func deleteFolder(_ folderPath: String) throws
    {
        let fileManager: FileManager = FileManager()
        
        if (fileManager.fileExists(atPath: folderPath))
        {
            try fileManager.removeItem(atPath: folderPath)
        }
    }
    
    public class func ensureFileFolder(_ fileName: String) throws
    {
        return try FileUtil.ensureFolder(fileName.stringByDeletingLastPathComponent)
    }
    
    public class func contentsOfFolderSortedAscendingByFileModificationDate(_ folderPath: String) throws -> [String]
    {
        let fileManager: FileManager = FileManager()
        
        var filesArray: [String] = try fileManager.contentsOfDirectory(atPath: folderPath)
        
        
        filesArray.sort { (string1: String, string2: String) -> Bool in
            
            let fullFileName1 = folderPath.stringByAppendingPathComponent(string1)
            let fullFileName2 = folderPath.stringByAppendingPathComponent(string2)
            
            do
            {
                // Sort the paths by the file modification date.
                let file1Attributes =  try fileManager.attributesOfItem(atPath: fullFileName1) as NSDictionary
                let file2Attributes =  try fileManager.attributesOfItem(atPath: fullFileName2) as NSDictionary
                
                if let file1ModDate = file1Attributes.fileModificationDate(), let file2ModDate = file2Attributes.fileModificationDate()
                {
                    return file1ModDate.compare(file2ModDate) == .orderedAscending
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
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager: FileManager = FileManager()
        
        let attributes = try fileManager.attributesOfFileSystem(forPath: documentFolder) as NSDictionary
        
        if let fileSystemSizeInBytes: NSNumber = attributes.object(forKey: FileAttributeKey.systemFreeSize) as? NSNumber
        {
            return fileSystemSizeInBytes.uint64Value
        }
        
        return 0
    }
    
    public class func getFreeSpaceAsMegaBytes() throws -> UInt64
    {
        return try self.getFreeSpace() / 1024 / 1024
    }
}
