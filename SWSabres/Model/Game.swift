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
    static let baseUpdateGameScoreEndPoint = "http://www.southwakesabres.org/updateGameResults.php"
    
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
    var gameOurScore: Int?
    var gameOppScore: Int?
    
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
        
        if let gameOurScoreNumber = aDecoder.decodeObjectForKey("gameOurScore") as? NSNumber
        {
            self.gameOurScore = gameOurScoreNumber.integerValue
        }
        if let gameOppScoreNumber = aDecoder.decodeObjectForKey("gameOppScore") as? NSNumber
        {
            self.gameOppScore = gameOppScoreNumber.integerValue
        }
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
        
        if let gameOurScore = gameOurScore
        {
            aCoder.encodeObject(NSNumber(integer: gameOurScore), forKey: "gameOurScore")
        }
        
        if let gameOppScore = gameOppScore
        {
            aCoder.encodeObject(NSNumber(integer: gameOppScore), forKey: "gameOppScore")
        }
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
        
        if let game_our_scoreString = json["custom_fields"]["game_our_score"][0].string where !game_our_scoreString.isEmpty
        {
            self.gameOurScore = Int(game_our_scoreString)
        }
        
        if let game_opp_scoreString = json["custom_fields"]["game_opp_score"][0].string where !game_opp_scoreString.isEmpty
        {
            self.gameOppScore = Int(game_opp_scoreString)
        }
        
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
        let endpoint: String = String(format: "%@&include=id,slug,modified,custom_fields", Game.baseEndpoint)
        
        Alamofire.request(.GET, endpoint).getPostsReponseArray { response in
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
    
    static func updateGameScore(game: Game, completionHandler: (Result<UpdateGameScoreResult, NSError>) -> Void)
    {
        guard let components = NSURLComponents(string: baseUpdateGameScoreEndPoint) else
        {
            return
        }
        
        var gameOurScoreString: String = ""
        var gameOppScoreString: String = ""
        var gameResultString: String = ""
        
        if let gameOurScore: Int = game.gameOurScore
        {
            gameOurScoreString = String(gameOurScore)
        }
        
        if let gameOppScore: Int = game.gameOppScore
        {
            gameOppScoreString = String(gameOppScore)
        }
        
        if let gameResult = game.gameResult
        {
            gameResultString = gameResult
        }
        
        components.queryItems = [
            NSURLQueryItem(name: "post_id", value: String(game.gamePostId)),
            NSURLQueryItem(name: "game_our_score", value: gameOurScoreString),
            NSURLQueryItem(name: "game_opp_score", value: gameOppScoreString),
            NSURLQueryItem(name: "game_result", value: gameResultString)
        ]
        
        Alamofire.request(.GET, components.URLString).responseObject { response in
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
