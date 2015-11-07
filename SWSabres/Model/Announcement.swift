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
    
    init?(coder aDecoder: NSCoder)
    {
        guard let decodedAnnouncementId = aDecoder.decodeObjectForKey("announcementId") as? String else
        {
            return nil
        }
        self.announcementId = decodedAnnouncementId
        
        guard let decodedTitle = aDecoder.decodeObjectForKey("title") as? String else
        {
            return nil
        }
        self.title = decodedTitle
        
        guard let decodedContent = aDecoder.decodeObjectForKey("content") as? String else
        {
            return nil
        }
        self.content = decodedContent
        
        guard let decodedDate = aDecoder.decodeObjectForKey("date") as? NSDate else
        {
            return nil
        }
        self.date = decodedDate
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(announcementId, forKey: "announcementId")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(content, forKey: "content")
        aCoder.encodeObject(date, forKey: "date")
    }
    
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
        self.content = announcement_content

        let dateFormatter: NSDateFormatter = NSDateFormatter()
        //dateFormatter.timeZone = NSTimeZone(name: "EST")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH:mm:ss"
        guard let parsedDate:NSDate = dateFormatter.dateFromString(announcement_date) else
        {
            return nil
        }
        
        self.date = parsedDate
        
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        
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
    
    static func getAnnouncements(completionHandler: (Result<[Announcement], NSError>) -> Void)
    {
        Alamofire.request(.GET, Announcement.endpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
    
    class Helper: NSObject, NSCoding
    {
        var announcement: Announcement?
        
        init(announcement: Announcement)
        {
            self.announcement = announcement
        }
        
        required init(coder aDecoder: NSCoder)
        {
            announcement = Announcement(coder: aDecoder)
        }
        
        func encodeWithCoder(aCoder: NSCoder)
        {
            announcement?.encodeWithCoder(aCoder)
        }
    }
}