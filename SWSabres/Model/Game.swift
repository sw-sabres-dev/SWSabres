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
import os.log

struct Game: ResponseJSONObjectSerializable
{
    static let baseEndpoint: String = "https://southwakesabres.org/wp-json/wp/v2/mstw_ss_game"
    static let baseUpdateGameScoreEndPoint = "http://www.southwakesabres.org/updateGameResults.php"
    
    let gameId: String
    let gamePostId: Int
    let gameDate: Date
    let gameScheduleId: String
    let isHomeGame: Bool
    let isTimeTba: Bool
    let modified: Date
    var opponent: String?
    var teamId: String?
    var gameVenueId: String?
    var gameResult: String?
    var gameOurScore: Int?
    var gameOppScore: Int?
    
    init?(coder aDecoder: NSCoder)
    {
        guard let gameId = aDecoder.decodeObject(forKey: "gameId") as? String else
        {
            return nil
        }
        self.gameId = gameId
        
        guard let gamePostId = aDecoder.decodeObject(forKey: "gamePostId") as? NSNumber else
        {
            return nil
        }
        self.gamePostId = gamePostId.intValue
        
        guard let gameDate = aDecoder.decodeObject(forKey: "gameDate") as? Date else
        {
            return nil
        }
        self.gameDate = gameDate
        
        guard let gameScheduleId = aDecoder.decodeObject(forKey: "gameScheduleId") as? String else
        {
            return nil
        }
        self.gameScheduleId = gameScheduleId
        
        guard let isHomeGameNumber = aDecoder.decodeObject(forKey: "isHomeGame") as? NSNumber else
        {
            return nil
        }
        self.isHomeGame = isHomeGameNumber.boolValue

        if let isTimeTbaNumber = aDecoder.decodeObject(forKey: "isTimeTba") as? NSNumber {
            self.isTimeTba = isTimeTbaNumber.boolValue
        } else {
            self.isTimeTba = false
        }

        guard let decodedModified: Date = aDecoder.decodeObject(forKey: "modified") as? Date else
        {
            return nil
        }
        self.modified = decodedModified

        self.opponent = aDecoder.decodeObject(forKey: "opponent") as? String
        self.teamId = aDecoder.decodeObject(forKey: "teamId") as? String
        self.gameVenueId = aDecoder.decodeObject(forKey: "gameVenueId") as? String
        self.gameResult = aDecoder.decodeObject(forKey: "gameResult") as? String
        
        if let gameOurScoreNumber = aDecoder.decodeObject(forKey: "gameOurScore") as? NSNumber
        {
            self.gameOurScore = gameOurScoreNumber.intValue
        }
        if let gameOppScoreNumber = aDecoder.decodeObject(forKey: "gameOppScore") as? NSNumber
        {
            self.gameOppScore = gameOppScoreNumber.intValue
        }
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(gameId, forKey: "gameId")
        aCoder.encode(NSNumber(value: gamePostId as Int), forKey: "gamePostId")
        aCoder.encode(gameDate, forKey: "gameDate")
        aCoder.encode(gameScheduleId, forKey: "gameScheduleId")
        aCoder.encode(NSNumber(value: isHomeGame as Bool), forKey: "isHomeGame")
        aCoder.encode(NSNumber(value: isTimeTba as Bool), forKey: "isTimeTba")
        aCoder.encode(opponent, forKey: "opponent")
        aCoder.encode(teamId, forKey: "teamId")
        aCoder.encode(gameVenueId, forKey: "gameVenueId")
        aCoder.encode(gameResult, forKey: "gameResult")
        aCoder.encode(modified, forKey: "modified")
        
        if let gameOurScore = gameOurScore
        {
            aCoder.encode(NSNumber(value: gameOurScore as Int), forKey: "gameOurScore")
        }
        
        if let gameOppScore = gameOppScore
        {
            aCoder.encode(NSNumber(value: gameOppScore as Int), forKey: "gameOppScore")
        }
    }

    init?(json: SwiftyJSON.JSON)
    {
        
        guard let game_slug = json["slug"].string else
        {
            return nil
        }
        os_log("Loading game %@", log: .default, game_slug)

        guard let game_postId = json["id"].int else
        {
            return nil
        }

        guard let game_sched_id = json["custom_fields"]["game_sched_id"].string else
        {
            return nil
        }
        
        guard let game_modified = json["modified"].string else // 2015-11-01 00:40:53
        {
            return nil
        }
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss"
        
        guard let parsedModified: Date = dateFormatter.date(from: game_modified) else
        {
            return nil
        }
        
        self.modified = parsedModified
        
        var game_unix_dtg = json["custom_fields"]["game_unix_dtg"].doubleValue
        
        if game_unix_dtg == 0
        {
            return nil
        }
        
        self.teamId = json["custom_fields"]["game_opponent_team"].string
        self.opponent = json["custom_fields"]["game_opponent"].string
        self.isHomeGame = json["custom_fields"]["game_is_home_game"].boolValue

        if let game_time_tba = json["custom_fields"]["game_time_tba"].string {
            self.isTimeTba = game_time_tba.uppercased().starts(with: "TB")
        } else {
            self.isTimeTba = false
        }

        self.gameVenueId = json["custom_fields"]["game_gl_location"].string
        let result = json["custom_fields"]["game_result"].string
        
        self.gameResult = !String.isNilOrEmpty(result) ? result : nil
        
        if let game_our_scoreString = json["custom_fields"]["game_our_score"].string, !game_our_scoreString.isEmpty
        {
            self.gameOurScore = Int(game_our_scoreString)
        }
        
        if let game_opp_scoreString = json["custom_fields"]["game_opp_score"].string, !game_opp_scoreString.isEmpty
        {
            self.gameOppScore = Int(game_opp_scoreString)
        }
        
        // The game time is stored in local unix time not GMT.
        // Use seconds from GMT to get the unix time for the day of the game.
        let tempGameUnixDate = game_unix_dtg - Double(NSTimeZone.local.secondsFromGMT())
        // Get the date for the game.
        let tempGameDate = Date(timeIntervalSince1970: tempGameUnixDate)
        // Calculate what the offset from GMT will be on that day.  This will take into account daylight savings.
        let offset = TimeZone.autoupdatingCurrent.secondsFromGMT(for: tempGameDate)
        
        // Fix the timezone offset
        game_unix_dtg -= Double(offset)

        self.gameDate = Date(timeIntervalSince1970: game_unix_dtg)
        
        self.gameId = game_slug
        self.gamePostId = game_postId
        self.gameScheduleId = game_sched_id
    }

    static func getAllGames() async -> [Game]? {
        return await Game.getObjects(Game.baseEndpoint)
    }
    
    static func updateGameScore(_ game: Game, completionHandler: @escaping (Result<UpdateGameScoreResult>) -> Void)
    {
        guard var components = URLComponents(string: baseUpdateGameScoreEndPoint) else
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
            URLQueryItem(name: "post_id", value: String(game.gamePostId)),
            URLQueryItem(name: "game_our_score", value: gameOurScoreString),
            URLQueryItem(name: "game_opp_score", value: gameOppScoreString),
            URLQueryItem(name: "game_result", value: gameResultString)
        ]
        
        let url = try? components.asURL()
        Alamofire.request(url!).responseObject { response in
            completionHandler(response.result)
        }
    }
    
    @objc(_TtCV8SWSabres4Game6Helper)class Helper: NSObject, NSCoding
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
        
        func encode(with aCoder: NSCoder)
        {
            game?.encodeWithCoder(aCoder)
        }
    }
}
