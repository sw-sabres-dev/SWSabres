//
//  Team.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Team: ResponseJSONObjectSerializable, UniqueObject
{
    static let endpoint: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_team&count=500"
    
    let teamId: String
    let name: String
    var shortName: String?
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let team_full_name = json["custom_fields"]["team_full_name"][0].string else
        {
            return nil
        }
        
        guard let team_slug = json["slug"].string else
        {
            return nil
        }
        
        self.teamId = team_slug
        self.name = team_full_name

        var team_short_name = json["custom_fields"]["team_short_name"][0].string
        
        if String.isNilOrEmpty(team_short_name)
        {
            team_short_name = nil
        }

        self.shortName = team_short_name
    }
    
    var uniqueId: String
    {
        get
        {
            return teamId
        }
    }
    
    static func getTeams(fileName: String, completionHandler: (Result<[Team], NSError>) -> Void)
    {
        Alamofire.request(.GET, Team.endpoint).getPostsReponseArray(fileName) { response in
            completionHandler(response.result)
        }
    }
}
