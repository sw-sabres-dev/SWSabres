//
//  ContentUpdate.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/9/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation

final class ContentUpdate
{
    var updatedAnnouncements: [Announcement]?
    var deletedAnnouncements: [Announcement]?
    var updatedVenues: [Venue]?
    var deletedVenues: [Venue]?
    var updatedTeams: [Team]?
    var deletedTeams: [Team]?
    var updatedSchedules: [Schedule]?
    var deletedSchedules: [Schedule]?
    var updatedGames: [Game]?
    var deletedGames: [Game]?
    var updatedGameKeys: [Int]?
    
    var isContentUpdated: Bool
    {
        get
        {
            return updatedAnnouncements != nil || deletedAnnouncements != nil || updatedVenues != nil || deletedVenues != nil || updatedTeams != nil || deletedTeams != nil ||
                   updatedSchedules != nil || deletedSchedules != nil || updatedGames != nil || deletedGames != nil
        }
    }
}