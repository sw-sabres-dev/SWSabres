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
    static let endpoint: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_schedule"
    
    let scheduleId: String
    let title: String
    let scheduleTeamId: String
    
    init?(coder aDecoder: NSCoder)
    {
        guard let scheduleId = aDecoder.decodeObjectForKey("scheduleId") as? String else
        {
            return nil
        }
        self.scheduleId = scheduleId
        
        guard let title = aDecoder.decodeObjectForKey("title") as? String else
        {
            return nil
        }
        self.title = title
        
        guard let scheduleTeamId = aDecoder.decodeObjectForKey("scheduleTeamId") as? String else
        {
            return nil
        }
        self.scheduleTeamId = scheduleTeamId
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(scheduleId, forKey: "scheduleId")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(scheduleTeamId, forKey: "scheduleTeamId")
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
        
        let encodedTitle = schedule_title.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
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
    
    static func getSchedules(completionHandler: (Result<[Schedule], NSError>) -> Void)
    {
        Alamofire.request(.GET, Schedule.endpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
    
    class Helper: NSObject, NSCoding
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
        
        func encodeWithCoder(aCoder: NSCoder)
        {
            schedule?.encodeWithCoder(aCoder)
        }
    }
}