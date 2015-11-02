//
//  Game.swift
//  TestAlamoFire
//
//  Created by Mark Johnson on 10/31/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation

struct Game
{
    static let gamesURL: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_game&count=500&meta_key=game_sched_id&meta_value=2015-jvg"
    
    let gameDate: NSDate
    let opponent: String
    let location: String
}