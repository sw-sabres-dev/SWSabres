//
//  Announcement.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Announcement: ResponseJSONObjectSerializable
{
    static let endpoint: String = "http://www.southwakesabres.org/?json=1"
    
    let announcementId: String
    let title: String
    let content: String
    let date: NSDate
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let announcement_slug = json["slug"].string else
        {
            return nil
        }
        
        guard let announcement_title = json["title"].string else
        {
            return nil
        }
        
        guard let announcement_content = json["content"].string else
        {
            return nil
        }
        
        guard let announcement_date = json["date"].string else // 2015-11-01 00:40:53
        {
            return nil
        }
        
        self.announcementId = announcement_slug

        let dateFormatter: NSDateFormatter = NSDateFormatter()
        //dateFormatter.timeZone = NSTimeZone(name: "EST")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH:mm:ss"
        guard let parsedDate:NSDate = dateFormatter.dateFromString(announcement_date) else
        {
            return nil
        }
        
        self.date = parsedDate
        
        guard let encodedContent = announcement_content.dataUsingEncoding(NSUTF8StringEncoding) else
        {
            return nil
        }
        
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        
        if let attributedString = try? NSAttributedString(data: encodedContent, options: attributedOptions, documentAttributes: nil)
        {
            self.content = attributedString.string
        }
        else
        {
            return nil
        }
        
        guard let encodedTitle = announcement_title.dataUsingEncoding(NSUTF8StringEncoding) else
        {
            return nil
        }
        
        if let attributedString = try? NSAttributedString(data: encodedTitle, options: attributedOptions, documentAttributes: nil)
        {
            self.title = attributedString.string
        }
        else
        {
            return nil
        }
    }
    
    static func getAnnouncements(fileName: String, completionHandler: (Result<[Announcement], NSError>) -> Void)
    {
        Alamofire.request(.GET, Announcement.endpoint).getPostsReponseArray(fileName) { response in
            completionHandler(response.result)
        }
    }
}