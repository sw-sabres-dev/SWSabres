//
//  GameInfo.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/9/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct GameInfo: ResponseJSONObjectSerializable
{
    static let baseEndpoint: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_game&count=-1&meta_key=game_unix_dtg&orderby=meta_value&order=ASC&include=id,modified"
    
    let gamePostId: Int
    let modified: NSDate
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let game_postId = json["id"].int else
        {
            return nil
        }
        
        self.gamePostId = game_postId

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
    }
    
    static func getAllGameInfo(completionHandler: (Result<[GameInfo], NSError>) -> Void)
    {
        Alamofire.request(.GET, GameInfo.baseEndpoint).getPostsReponseArray { response in
            completionHandler(response.result)
        }
    }
}