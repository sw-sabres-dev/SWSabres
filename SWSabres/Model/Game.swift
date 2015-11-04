//
//  Game.swift
//  TestAlamoFire
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
    let gameDate: NSDate
    let gameScheduleId: String
    let isHomeGame: Bool
    var opponent: String?
    var teamId: String?
    var gameVenueId: String?
    var gameResult: String?
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let game_slug = json["slug"].string else
        {
            return nil
        }

        guard let game_sched_id = json["custom_fields"]["game_sched_id"][0].string else
        {
            return nil
        }
        
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
        self.gameScheduleId = game_sched_id
    }
    
    static func endpointForScheduleId(scheduleId: String) -> String
    {
        return baseEndpoint + "&meta_key=game_sched_id&meta_value=\(scheduleId)"
    }
    
    static func getAllGames(fileName: String, completionHandler: (Result<[Game], NSError>) -> Void)
    {
        Alamofire.request(.GET, Game.baseEndpoint).getPostsReponseArray(fileName) { response in
            completionHandler(response.result)
        }
    }
}
