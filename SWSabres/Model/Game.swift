//
//  Game.swift
//  SWSabres
//
//  Created by Mark Johnson on 10/31/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Game: ResponseJSONObjectSerializable
{
    static let baseEndpoint: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_game&count=-1&meta_key=game_unix_dtg&orderby=meta_value&order=ASC"
    
    let gameId: String
    let gamePostId: Int
    let gameDate: NSDate
    let gameScheduleId: String
    let isHomeGame: Bool
    let modified: NSDate
    var opponent: String?
    var teamId: String?
    var gameVenueId: String?
    var gameResult: String?
    
    init?(coder aDecoder: NSCoder)
    {
        guard let gameId = aDecoder.decodeObjectForKey("gameId") as? String else
        {
            return nil
        }
        self.gameId = gameId
        
        guard let gamePostId = aDecoder.decodeObjectForKey("gamePostId") as? NSNumber else
        {
            return nil
        }
        self.gamePostId = gamePostId.integerValue
        
        guard let gameDate = aDecoder.decodeObjectForKey("gameDate") as? NSDate else
        {
            return nil
        }
        self.gameDate = gameDate
        
        guard let gameScheduleId = aDecoder.decodeObjectForKey("gameScheduleId") as? String else
        {
            return nil
        }
        self.gameScheduleId = gameScheduleId
        
        guard let isHomeGameNumber = aDecoder.decodeObjectForKey("isHomeGame") as? NSNumber else
        {
            return nil
        }
        self.isHomeGame = isHomeGameNumber.boolValue
        
        guard let decodedModified: NSDate = aDecoder.decodeObjectForKey("modified") as? NSDate else
        {
            return nil
        }
        self.modified = decodedModified

        self.opponent = aDecoder.decodeObjectForKey("opponent") as? String
        self.teamId = aDecoder.decodeObjectForKey("teamId") as? String
        self.gameVenueId = aDecoder.decodeObjectForKey("gameVenueId") as? String
        self.gameResult = aDecoder.decodeObjectForKey("gameResult") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(gameId, forKey: "gameId")
        aCoder.encodeObject(NSNumber(integer: gamePostId), forKey: "gamePostId")
        aCoder.encodeObject(gameDate, forKey: "gameDate")
        aCoder.encodeObject(gameScheduleId, forKey: "gameScheduleId")
        aCoder.encodeObject(NSNumber(bool: isHomeGame), forKey: "isHomeGame")
        aCoder.encodeObject(opponent, forKey: "opponent")
        aCoder.encodeObject(teamId, forKey: "teamId")
        aCoder.encodeObject(gameVenueId, forKey: "gameVenueId")
        aCoder.encodeObject(gameResult, forKey: "gameResult")
        aCoder.encodeObject(modified, forKey: "modified")
    }

    init?(json: SwiftyJSON.JSON)
    {
        guard let game_slug = json["slug"].string else
        {
            return nil
        }

        guard let game_postId = json["id"].int else
        {
            return nil
        }
        
        guard let game_sched_id = json["custom_fields"]["game_sched_id"][0].string else
        {
            return nil
        }
        
        guard let game_modified = json["modified"].string else // 2015-11-01 00:40:53
        {
            return nil
        }
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH:mm:ss"
        
        guard let parsedModified: NSDate = dateFormatter.dateFromString(game_modified) else
        {
            return nil
        }
        
        self.modified = parsedModified
        
        var game_unix_dtg = json["custom_fields"]["game_unix_dtg"][0].doubleValue
        
        if game_unix_dtg == 0
        {
            return nil
        }
        
        self.teamId = json["custom_fields"]["game_opponent_team"][0].string
        self.opponent = json["custom_fields"]["game_opponent"][0].string
        self.isHomeGame = json["custom_fields"]["game_is_home_game"][0].boolValue
        self.gameVenueId = json["custom_fields"]["game_gl_location"][0].string
        let result = json["custom_fields"]["game_result"][0].string
        
        self.gameResult = !String.isNilOrEmpty(result) ? result : nil
        
        // Fix the timezone offset.
        game_unix_dtg -= Double(NSTimeZone.localTimeZone().secondsFromGMT)
        
        self.gameDate = NSDate(timeIntervalSince1970: game_unix_dtg)
        
        self.gameId = game_slug
        self.gamePostId = game_postId
        self.gameScheduleId = game_sched_id
    }
    
    static func endpointForScheduleId(scheduleId: String) -> String
    {
        return baseEndpoint + "&meta_key=game_sched_id&meta_value=\(scheduleId)"
    }
    
    static func getAllGames(completionHandler: (Result<[Game], NSError>) -> Void)
    {
        Alamofire.request(.GET, Game.baseEndpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
    
    static func getGamesForKeys(keys: [Int], completionHandler: (Result<[Game], NSError>) -> Void)
    {
        var endpoint: String = Game.baseEndpoint
        
        for key in keys
        {
            endpoint += "&post__in[]=\(key)"
        }
        
        Alamofire.request(.GET, endpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
    
    class Helper: NSObject, NSCoding
    {
        var game: Game?
        
        init(game: Game)
        {
            self.game = game
        }
        
        required init(coder aDecoder: NSCoder)
        {
            game = Game(coder: aDecoder)
        }
        
        func encodeWithCoder(aCoder: NSCoder)
        {
            game?.encodeWithCoder(aCoder)
        }
    }
}
