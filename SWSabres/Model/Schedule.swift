//
//  Schedule.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Schedule: ResponseJSONObjectSerializable, UniqueObject
{
    static let endpoint: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_schedule&count=-1&include=slug,title,modified,custom_fields&custom_fields=schedule_team"
    
    let scheduleId: String
    let title: String
    let scheduleTeamId: String
    let modified: Date
    
    init?(coder aDecoder: NSCoder)
    {
        guard let scheduleId = aDecoder.decodeObject(forKey: "scheduleId") as? String else
        {
            return nil
        }
        self.scheduleId = scheduleId
        
        guard let title = aDecoder.decodeObject(forKey: "title") as? String else
        {
            return nil
        }
        self.title = title
        
        guard let scheduleTeamId = aDecoder.decodeObject(forKey: "scheduleTeamId") as? String else
        {
            return nil
        }
        self.scheduleTeamId = scheduleTeamId
        
        guard let decodedModified: Date = aDecoder.decodeObject(forKey: "modified") as? Date else
        {
            return nil
        }
        self.modified = decodedModified
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(scheduleId, forKey: "scheduleId")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(scheduleTeamId, forKey: "scheduleTeamId")
        aCoder.encode(modified, forKey: "modified")
    }
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let schedule_slug = json["slug"].string else
        {
            return nil
        }
        
        guard let schedule_title = json["title"].string else
        {
            return nil
        }
        
        guard let schedule_team = json["custom_fields"]["schedule_team"][0].string else
        {
            return nil
        }
        
        guard let schedule_modified = json["modified"].string else // 2015-11-01 00:40:53
        {
            return nil
        }
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH:mm:ss"
        
        guard let parsedModified: Date = dateFormatter.date(from: schedule_modified) else
        {
            return nil
        }
        
        self.modified = parsedModified
        
        guard let encodedTitle = schedule_title.data(using: String.Encoding.utf8) else
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
        
        self.scheduleId = schedule_slug
        self.scheduleTeamId = schedule_team
    }
    
    var uniqueId: String
    {
        get
        {
            return scheduleId
        }
    }

    static func getSchedules(_ completionHandler: @escaping (Result<[Schedule]>) -> Void)
    {
        Alamofire.request(Schedule.endpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
    
    @objc(_TtCV8SWSabres8Schedule6Helper)class Helper: NSObject, NSCoding
    {
        var schedule: Schedule?
        
        init(schedule: Schedule)
        {
            self.schedule = schedule
        }
        
        required init(coder aDecoder: NSCoder)
        {
            schedule = Schedule(coder: aDecoder)
        }
        
        func encode(with aCoder: NSCoder)
        {
            schedule?.encodeWithCoder(aCoder)
        }
    }
}
