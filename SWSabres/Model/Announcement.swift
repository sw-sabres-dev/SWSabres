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
    static let endpoint: String = "http://www.southwakesabres.org/?json=get_posts&count=-1&include=slug,title,content,date,modified&orderby=date&order=DESC"
    
    let announcementId: String
    let title: String
    let content: String
    let date: Date
    let modified: Date
    
    init?(coder aDecoder: NSCoder)
    {
        guard let decodedAnnouncementId: String = aDecoder.decodeObject(forKey: "announcementId") as? String else
        {
            return nil
        }
        self.announcementId = decodedAnnouncementId
        
        guard let decodedTitle: String = aDecoder.decodeObject(forKey: "title") as? String else
        {
            return nil
        }
        self.title = decodedTitle
        
        guard let decodedContent: String = aDecoder.decodeObject(forKey: "content") as? String else
        {
            return nil
        }
        self.content = decodedContent
        
        guard let decodedDate: Date = aDecoder.decodeObject(forKey: "date") as? Date else
        {
            return nil
        }
        self.date = decodedDate
        
        guard let decodedModified: Date = aDecoder.decodeObject(forKey: "modified") as? Date else
        {
            return nil
        }
        self.modified = decodedModified
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(announcementId, forKey: "announcementId")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(modified, forKey: "modified")
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
        
        guard let announcement_modified = json["modified"].string else // 2015-11-01 00:40:53
        {
            return nil
        }
        
        self.announcementId = announcement_slug
        self.content = announcement_content

        let dateFormatter: DateFormatter = DateFormatter()
        //dateFormatter.timeZone = NSTimeZone(name: "EST")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH:mm:ss"
        guard let parsedDate:Date = dateFormatter.date(from: announcement_date) else
        {
            return nil
        }
        
        self.date = parsedDate
        
        guard let parsedModified: Date = dateFormatter.date(from: announcement_modified) else
        {
            return nil
        }
        
        self.modified = parsedModified
        
        guard let encodedTitle = announcement_title.data(using: String.Encoding.utf8) else
        {
            return nil
        }

        let attributedOptions : [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType : NSAttributedString.DocumentType.html
        ]
        
        if let attributedString = try? NSAttributedString(data: encodedTitle, options: attributedOptions, documentAttributes: nil)
        {
            self.title = attributedString.string
        }
        else
        {
            return nil
        }
    }
    
    static func getAnnouncements(_ completionHandler: @escaping (Result<[Announcement]>) -> Void)
    {
        Alamofire.request(Announcement.endpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
    
    @objc(_TtCV8SWSabres12Announcement6Helper)class Helper: NSObject, NSCoding
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
        
        func encode(with aCoder: NSCoder)
        {
            announcement?.encodeWithCoder(aCoder)
        }
    }
}
