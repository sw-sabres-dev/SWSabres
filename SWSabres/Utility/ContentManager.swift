//
//  ContentManager.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

final class ContentManager
{
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    var games: [Game] = [Game]()
    var gameSections: [NSDate: [Game]] = [NSDate: [Game]]()
    var sortedDays: [NSDate] = [NSDate]()
    
    func loadContent(completionBlock: () -> ())
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let jsonCacheFolder = documentFolder.stringByAppendingPathComponent("jsonCacheFolder")
            
            let fileManager: NSFileManager = NSFileManager()
            
            do
            {
                try FileUtil.ensureFolder(jsonCacheFolder)
            }
            catch
            {
                return
            }
            
            let queueGroup = dispatch_group_create()
            
            let venuesFileName = jsonCacheFolder.stringByAppendingPathComponent("venues.json")
            
            if fileManager.fileExistsAtPath(venuesFileName)
            {
                self.venueMap = Venue.loadObjectMap(venuesFileName)
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_group_enter(queueGroup)
                
                Venue.getVenues(venuesFileName){ (result) -> Void in
                    
                    if let venues = result.value
                    {
                        self.venueMap.removeAll()
                        
                        for venue in venues
                        {
                            self.venueMap[venue.venueId] = venue
                        }
                    }
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            let teamsFileName = jsonCacheFolder.stringByAppendingPathComponent("teams.json")
            
            if fileManager.fileExistsAtPath(teamsFileName)
            {
                self.teamMap = Team.loadObjectMap(teamsFileName)
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_group_enter(queueGroup)
                
                Team.getTeams(teamsFileName){ (result) -> Void in
                    
                    if let teams = result.value
                    {
                        self.teamMap.removeAll()
                        
                        for team in teams
                        {
                            self.teamMap[team.teamId] = team
                        }
                    }
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            let schedulesFileName = jsonCacheFolder.stringByAppendingPathComponent("schedules.json")
            
            if fileManager.fileExistsAtPath(schedulesFileName)
            {
                self.scheduleMap = Schedule.loadObjectMap(schedulesFileName)
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_group_enter(queueGroup)
                
                Schedule.getSchedules(schedulesFileName){ (result) -> Void in
                    
                    if let schedules = result.value
                    {
                        self.scheduleMap.removeAll()
                        
                        for schedule in schedules
                        {
                            self.scheduleMap[schedule.scheduleId] = schedule
                        }
                    }
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            
            
            let gameFileName = jsonCacheFolder.stringByAppendingPathComponent("games.json")
            
            if fileManager.fileExistsAtPath(gameFileName)
            {
                let games: [Game] = Game.loadObjects(gameFileName)
                
                for game in games
                {
                    if let gameDay: NSDate = self.dayForDate(game.gameDate)
                    {
                        if var gamesOnDay: [Game] = self.gameSections[gameDay]
                        {
                            gamesOnDay.append(game)
                            self.gameSections[gameDay] = gamesOnDay
                        }
                        else
                        {
                            var gamesOnDay: [Game] = [Game]()
                            gamesOnDay.append(game)
                            self.gameSections[gameDay] = gamesOnDay
                        }
                    }
                }
                
                self.sortedDays = self.gameSections.keys.sort {$0.compare($1) == .OrderedAscending}
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_group_enter(queueGroup)
                
                Game.getAllGames(gameFileName){ (result) -> Void in
                    
                    if let fetchedGames = result.value
                    {
                        for game in fetchedGames
                        {
                            if let gameDay: NSDate = self.dayForDate(game.gameDate)
                            {
                                if var gamesOnDay: [Game] = self.gameSections[gameDay]
                                {
                                    gamesOnDay.append(game)
                                    self.gameSections[gameDay] = gamesOnDay
                                }
                                else
                                {
                                    var gamesOnDay: [Game] = [Game]()
                                    gamesOnDay.append(game)
                                    self.gameSections[gameDay] = gamesOnDay
                                }
                            }
                        }
                        
                        self.sortedDays = self.gameSections.keys.sort {$0.compare($1) == .OrderedAscending}
                    }
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            dispatch_group_notify(queueGroup, dispatch_get_main_queue()) {
                
                completionBlock()
                //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                //self.tableView.reloadData()
            }
        }

    }
    
    private func dayForDate(date: NSDate) -> NSDate?
    {
        let calendar = NSCalendar.currentCalendar()
        let timeZone = NSTimeZone.localTimeZone()
        calendar.timeZone = timeZone
        
        let dateComps = calendar.components([.Year, .Month, .Day], fromDate: date)
        
        dateComps.hour = 0
        dateComps.minute = 0
        dateComps.second = 0
        
        return calendar.dateFromComponents(dateComps)
    }
}