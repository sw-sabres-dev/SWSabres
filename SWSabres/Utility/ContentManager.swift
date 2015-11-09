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
    enum TeamsFilter
    {
        case All
        case Selected([Team])
    }
    
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    var games: [Game] = [Game]()
    var gameSections: [NSDate: [Game]] = [NSDate: [Game]]()
    var sortedDays: [NSDate] = [NSDate]()
    var announcements: [Announcement] = [Announcement]()
    var teamsFilter: TeamsFilter = .All
    
    class var contentPath: String
    {
        get
        {
            let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            return documentFolder.stringByAppendingPathComponent("contentCache")
        }
    }
    
    func loadAnnouncements(completionBlock: () -> ())
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let fileManager: NSFileManager = NSFileManager()
            
            do
            {
                try FileUtil.ensureFolder(ContentManager.contentPath)
            }
            catch
            {
                return
            }
            
            let announcementsFileName = ContentManager.contentPath.stringByAppendingPathComponent("announcements.ser")
            
            if fileManager.fileExistsAtPath(announcementsFileName)
            {
                self.loadAnnouncements()
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    completionBlock()
                    //self.tableView.reloadData()
                }
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                Announcement.getAnnouncements { (result) -> Void in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if let fetchedAnnouncements = result.value
                    {
                        self.announcements = fetchedAnnouncements
                        
                        self.saveAnnouncements()
                        
                        completionBlock()
                        //self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func loadContent(completionBlock: () -> ())
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let fileManager: NSFileManager = NSFileManager()
            
            do
            {
                try FileUtil.ensureFolder(ContentManager.contentPath)
            }
            catch
            {
                return
            }
            
            let queueGroup = dispatch_group_create()
            
            let venuesFileName = ContentManager.contentPath.stringByAppendingPathComponent("venueMap.ser")
            
            if fileManager.fileExistsAtPath(venuesFileName)
            {
                self.loadVenues()
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_group_enter(queueGroup)
                
                Venue.getVenues { (result) -> Void in
                    
                    if let venues = result.value
                    {
                        self.venueMap.removeAll()
                        
                        for venue in venues
                        {
                            self.venueMap[venue.venueId] = venue
                        }
                    }
                    
                    self.saveVenues()
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            let teamsFileName = ContentManager.contentPath.stringByAppendingPathComponent("teamMap.ser")
            
            if fileManager.fileExistsAtPath(teamsFileName)
            {
                self.loadTeams()
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_group_enter(queueGroup)
                
                Team.getTeams { (result) -> Void in
                    
                    if let teams = result.value
                    {
                        self.teamMap.removeAll()
                        
                        for team in teams
                        {
                            self.teamMap[team.teamId] = team
                        }
                    }
                    
                    self.saveTeams()
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            let schedulesFileName = ContentManager.contentPath.stringByAppendingPathComponent("scheduleMap.ser")
            
            if fileManager.fileExistsAtPath(schedulesFileName)
            {
                self.loadSchedules()
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_group_enter(queueGroup)
                
                Schedule.getSchedules { (result) -> Void in
                    
                    if let schedules = result.value
                    {
                        self.scheduleMap.removeAll()
                        
                        for schedule in schedules
                        {
                            self.scheduleMap[schedule.scheduleId] = schedule
                        }
                    }
                    
                    self.saveSchedules()
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            
            
            let gamesFileName = ContentManager.contentPath.stringByAppendingPathComponent("games.ser")
            
            if fileManager.fileExistsAtPath(gamesFileName)
            {
                self.loadGames()
                
                for game in self.games
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
                
                Game.getAllGames { (result) -> Void in
                    
                    if let fetchedGames = result.value
                    {
                        self.games = fetchedGames
                        
                        self.filterGames()
                    }
                    
                    self.saveGames()
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            dispatch_group_notify(queueGroup, dispatch_get_main_queue()) {
                
                completionBlock()
            }
        }

    }
    
    func filterGames()
    {
        let filteredGames: [Game]
        self.gameSections.removeAll()

        switch teamsFilter
        {
            case .All:
            filteredGames = games
            
            case .Selected(let teams):
                filteredGames = games.filter {
                    
                    if let schedule: Schedule = scheduleMap[$0.gameScheduleId], let scheduledTeam: Team = teamMap[schedule.scheduleTeamId]
                    {
                        if teams.contains(scheduledTeam)
                        {
                            return true
                        }
                    }
                    
                    return false
            }
        }
        
        for game in filteredGames
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
    
    func refreshGamesWithFilter(completionBlock: () -> ())
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
         
            self.filterGames()
            
            dispatch_async(dispatch_get_main_queue()) {
                
                completionBlock()
            }
        }
    }
    func saveVenues()
    {
        let venuesFileName = ContentManager.contentPath.stringByAppendingPathComponent("venueMap.ser")
        
        do
        {
            try FileUtil.ensureFileFolder(venuesFileName)
        }
        catch
        {
            return
        }
        
        var helperVenueMap: [String: Venue.Helper] = Dictionary<String, Venue.Helper>()
        
        for (key, value) in venueMap
        {
            helperVenueMap[key] = Venue.Helper(venue: value)
        }
        
        NSKeyedArchiver.archiveRootObject(helperVenueMap, toFile: venuesFileName)
    }
    
    func loadVenues()
    {
        venueMap.removeAll()
        
        let venuesFileName = ContentManager.contentPath.stringByAppendingPathComponent("venueMap.ser")
        
        if let helperVenueMap: [String: Venue.Helper] = NSKeyedUnarchiver.unarchiveObjectWithFile(venuesFileName) as? [String: Venue.Helper]
        {
            for (key, value) in helperVenueMap
            {
                if let venue: Venue = value.venue
                {
                    venueMap[key] = venue
                }
            }
        }
    }
    
    func saveTeams()
    {
        let teamsFileName = ContentManager.contentPath.stringByAppendingPathComponent("teamMap.ser")
        
        do
        {
            try FileUtil.ensureFileFolder(teamsFileName)
        }
        catch
        {
            return
        }
        
        var helperTeamMap: [String: Team.Helper] = Dictionary<String, Team.Helper>()
        
        for (key, value) in teamMap
        {
            helperTeamMap[key] = Team.Helper(team: value)
        }
        
        NSKeyedArchiver.archiveRootObject(helperTeamMap, toFile: teamsFileName)
    }
    
    func loadTeams()
    {
        teamMap.removeAll()
        
        let teamsFileName = ContentManager.contentPath.stringByAppendingPathComponent("teamMap.ser")
        
        if let helperTeamMap: [String: Team.Helper] = NSKeyedUnarchiver.unarchiveObjectWithFile(teamsFileName) as? [String: Team.Helper]
        {
            for (key, value) in helperTeamMap
            {
                if let team: Team = value.team
                {
                    teamMap[key] = team
                }
            }
        }
    }
    
    func saveSchedules()
    {
        let schedulesFileName = ContentManager.contentPath.stringByAppendingPathComponent("scheduleMap.ser")
        
        do
        {
            try FileUtil.ensureFileFolder(schedulesFileName)
        }
        catch
        {
            return
        }
        
        var helperScheduleMap: [String: Schedule.Helper] = Dictionary<String, Schedule.Helper>()
        
        for (key, value) in scheduleMap
        {
            helperScheduleMap[key] = Schedule.Helper(schedule: value)
        }
        
        NSKeyedArchiver.archiveRootObject(helperScheduleMap, toFile: schedulesFileName)
    }
    
    func loadSchedules()
    {
        scheduleMap.removeAll()
        
        let schedulesFileName = ContentManager.contentPath.stringByAppendingPathComponent("scheduleMap.ser")
        
        if let helperScheduleMap: [String: Schedule.Helper] = NSKeyedUnarchiver.unarchiveObjectWithFile(schedulesFileName) as? [String: Schedule.Helper]
        {
            for (key, value) in helperScheduleMap
            {
                if let schedule: Schedule = value.schedule
                {
                    scheduleMap[key] = schedule
                }
            }
        }
    }
    
    func saveGames()
    {
        let gamesFileName = ContentManager.contentPath.stringByAppendingPathComponent("games.ser")
        
        do
        {
            try FileUtil.ensureFileFolder(gamesFileName)
        }
        catch
        {
            return
        }
        
        let helperGames: [Game.Helper] = games.map { Game.Helper(game: $0) }
        
        NSKeyedArchiver.archiveRootObject(helperGames, toFile: gamesFileName)
    }
    
    func loadGames()
    {
        games.removeAll()
        gameSections.removeAll()
        
        let gamesFileName = ContentManager.contentPath.stringByAppendingPathComponent("games.ser")
        
        if let helperGames: [Game.Helper] = NSKeyedUnarchiver.unarchiveObjectWithFile(gamesFileName) as? [Game.Helper]
        {
            self.games = helperGames.flatMap { $0.game }
        }
    }
    
    func saveAnnouncements()
    {
        let announcementsFileName = ContentManager.contentPath.stringByAppendingPathComponent("announcements.ser")
        
        do
        {
            try FileUtil.ensureFileFolder(announcementsFileName)
        }
        catch
        {
            return
        }
        
        let helperAnnouncements: [Announcement.Helper] = announcements.map { Announcement.Helper(announcement: $0) }
        
        NSKeyedArchiver.archiveRootObject(helperAnnouncements, toFile: announcementsFileName)
    }
    
    func loadAnnouncements()
    {
        announcements.removeAll()
        
        let announcementsFileName = ContentManager.contentPath.stringByAppendingPathComponent("announcements.ser")
        
        if let helperAnnouncements: [Announcement.Helper] = NSKeyedUnarchiver.unarchiveObjectWithFile(announcementsFileName) as? [Announcement.Helper]
        {
            self.announcements = helperAnnouncements.flatMap { $0.announcement }
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