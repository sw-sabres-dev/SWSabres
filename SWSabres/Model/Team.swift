//
//  Team.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import os.log

struct Team: ResponseJSONObjectSerializable, UniqueObject, Equatable, Hashable
{
    static let endpoint: String = "https://southwakesabres.org/wp-json/wp/v2/mstw_ss_team"
    
    let teamId: String
    let name: String
    let modified: Date
    var logoUrl: String?
    var shortName: String?
    
    init?(coder aDecoder: NSCoder)
    {
        guard let teamId = aDecoder.decodeObject(forKey: "teamId") as? String else
        {
            return nil
        }
        self.teamId = teamId
        
        guard let name = aDecoder.decodeObject(forKey: "name") as? String else
        {
            return nil
        }
        self.name = name
        
        guard let decodedModified: Date = aDecoder.decodeObject(forKey: "modified") as? Date else
        {
            return nil
        }
        self.modified = decodedModified
        
        logoUrl = aDecoder.decodeObject(forKey: "logoUrl") as? String
        shortName = aDecoder.decodeObject(forKey: "shortName") as? String
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(teamId, forKey: "teamId")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(logoUrl, forKey: "logoUrl")
        aCoder.encode(shortName, forKey: "shortName")
        aCoder.encode(modified, forKey: "modified")
    }
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let team_full_name = json["custom_fields"]["team_full_name"].string else
        {
            return nil
        }
        
        guard let team_slug = json["slug"].string else
        {
            return nil
        }
        
        guard let team_modified = json["modified"].string else // 2015-11-01 00:40:53
        {
            return nil
        }
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss"
        
        guard let parsedModified: Date = dateFormatter.date(from: team_modified) else
        {
            return nil
        }
        
        self.modified = parsedModified
        
        self.teamId = team_slug
        self.name = team_full_name

        self.logoUrl = json["custom_fields"]["team_alt_logo"].string

        var team_short_name = json["custom_fields"]["team_short_name"].string
        
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
    
    static func getTeams() async -> [Team]? {
        return await Team.getObjects(Team.endpoint)
    }
    
    @objc(_TtCV8SWSabres4Team6Helper)class Helper: NSObject, NSCoding
    {
        var team: Team?
        
        init(team: Team)
        {
            self.team = team
        }
        
        required init(coder aDecoder: NSCoder)
        {
            team = Team(coder: aDecoder)
        }
        
        func encode(with aCoder: NSCoder)
        {
            team?.encodeWithCoder(aCoder)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(teamId)
    }
}

func ==(lhs: Team, rhs: Team) -> Bool {
    return lhs.teamId == rhs.teamId
}
