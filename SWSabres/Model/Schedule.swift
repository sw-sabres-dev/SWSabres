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

struct Schedule: ResponseJSONObjectSerializable
{
    static let endpoint: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_schedule"
    
    let scheduleId: String
    let title: String
    let scheduleTeamId: String
    
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
    
    static func getSchedules(completionHandler: (Result<[Schedule], NSError>) -> Void)
    {
        Alamofire.request(.GET, Schedule.endpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
}