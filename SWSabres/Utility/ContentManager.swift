//
//  ContentManager.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import ReachabilitySwift

final class ContentManager
{
    enum TeamsFilter
    {
        case All
        case Selected([Team])
    }
    
    enum GameLocationFilter : Int
    {
        case All = 0
        case Home = 1
        case Away = 2
    }
    
    enum DownloadContentError: ErrorType
    {
        case None
        case NoConnectivity
        case Error(ErrorType)
    }
    
    var isLoadingContent: Bool = false
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    var games: [Game] = [Game]()
    var gameSections: [NSDate: [Game]] = [NSDate: [Game]]()
    var sortedDays: [NSDate] = [NSDate]()
    var announcements: [Announcement] = [Announcement]()
    var loadContentScheduleCallback: (() -> ())?
    var loadContentCalendarCallback: (() -> ())?
    var announcementsLoadedCallback: (() -> ())?
    var downloadContentError: DownloadContentError = .None
    
    var teamsFilter: TeamsFilter
    {
        get
        {
            return teamsFilterStorage
        }
        set
        {
            teamsFilterStorage = newValue
            
            switch teamsFilterStorage
            {
                case .All:
                
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    if userDefaults.objectForKey("teamsFilter") != nil
                    {
                        userDefaults.removeObjectForKey("teamsFilter")
                    }
                    userDefaults.synchronize()
                
                case .Selected(let teams):
                    
                    let helperTeamsIds: [String] = teams.map { $0.teamId }
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(helperTeamsIds, forKey: "teamsFilter")
                    userDefaults.synchronize()
            }
            
        }
    }
    
    private var teamsFilterStorage: TeamsFilter = .All
    
    var gameLocationFilter: GameLocationFilter
    {
        get
        {
            return gameLocationFilterStorage
        }
        set
        {
            gameLocationFilterStorage = newValue
            
            switch gameLocationFilterStorage
            {
            case .All:
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                if userDefaults.objectForKey("gameLocationFilter") != nil
                {
                    userDefaults.removeObjectForKey("gameLocationFilter")
                }
                userDefaults.synchronize()
                
            default:
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(NSNumber(integer: newValue.rawValue), forKey: "gameLocationFilter")
                userDefaults.synchronize()
            }
            
        }
    }
    
    private var gameLocationFilterStorage: GameLocationFilter = .All
    
    init()
    {
        self.loadContent()
    }
    
    class var contentPath: String
    {
        get
        {
            let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            return documentFolder.stringByAppendingPathComponent("contentCache")
        }
    }

    /*
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
    */
    
    func loadContent()
    {
        isLoadingContent = true
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.integerForKey("resetContentCount") == 0
        {
            let gamesFileName = ContentManager.contentPath.stringByAppendingPathComponent("games.ser")
            let fileManager: NSFileManager = NSFileManager()
            if fileManager.fileExistsAtPath(gamesFileName)
            {
                do
                {
                    try fileManager.removeItemAtPath(gamesFileName)
                }
                catch
                {
                }
            }
            
            userDefaults.setInteger(1, forKey: "resetContentCount")
            userDefaults.synchronize()
        }
        
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
            let venuesFileName = ContentManager.contentPath.stringByAppendingPathComponent("venueMap.ser")
            let teamsFileName = ContentManager.contentPath.stringByAppendingPathComponent("teamMap.ser")
            let schedulesFileName = ContentManager.contentPath.stringByAppendingPathComponent("scheduleMap.ser")
            let gamesFileName = ContentManager.contentPath.stringByAppendingPathComponent("games.ser")
            
            if fileManager.fileExistsAtPath(announcementsFileName) && fileManager.fileExistsAtPath(venuesFileName) && fileManager.fileExistsAtPath(teamsFileName) && fileManager.fileExistsAtPath(schedulesFileName) && fileManager.fileExistsAtPath(gamesFileName)
            {
                do
                {
                    try self.loadAnnouncements()
                    try self.loadVenues()
                    try self.loadTeams()
                    try self.loadSchedules()
                    try self.loadGames()
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    self.loadPersistedTeamsFilter(userDefaults)
                    self.loadGameLocationFiler(userDefaults)
                    
                    self.filterGames()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.isLoadingContent = false
                        
                        if let announcementsLoadedCallback = self.announcementsLoadedCallback
                        {
                            announcementsLoadedCallback()
                        }
                        
                        if let loadContentCallback = self.loadContentScheduleCallback
                        {
                            loadContentCallback()
                        }
                        
                        if let calendarCallback = self.loadContentCalendarCallback
                        {
                            calendarCallback()
                        }
                        
                        self.checkforUpdates()
                    }
                }
                catch
                {
                    do
                    {
                        // The local data failed to load so wack it.
                        try fileManager.removeItemAtPath(announcementsFileName)
                        try fileManager.removeItemAtPath(venuesFileName)
                        try fileManager.removeItemAtPath(teamsFileName)
                        try fileManager.removeItemAtPath(schedulesFileName)
                        try fileManager.removeItemAtPath(gamesFileName)
                        
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        if userDefaults.objectForKey("teamsFilter") != nil
                        {
                            userDefaults.removeObjectForKey("teamsFilter")
                        }
                        
                        self.downloadContent {
                            
                            self.isLoadingContent = false
                            
                            if let loadContentCallback = self.loadContentScheduleCallback
                            {
                                loadContentCallback()
                            }
                            
                            if let calendarCallback = self.loadContentCalendarCallback
                            {
                                calendarCallback()
                            }
                        }
                    }
                    catch{}
                }
            }
            else
            {
                self.downloadContent {
                    
                    self.isLoadingContent = false
                    
                    if let loadContentCallback = self.loadContentScheduleCallback
                    {
                        loadContentCallback()
                    }
                    
                    if let calendarCallback = self.loadContentCalendarCallback
                    {
                        calendarCallback()
                    }
                }
            }
        }
        
    }

    func downloadContent(completionBlock: () -> ())
    {
        dispatch_async(dispatch_get_main_queue()) {
            
            do
            {
                let reachability: Reachability =  try Reachability.reachabilityForInternetConnection()
                if reachability.currentReachabilityStatus == .NotReachable
                {
                    self.downloadContentError = .NoConnectivity
                    
                    if let announcementsLoadedCallback = self.announcementsLoadedCallback
                    {
                        announcementsLoadedCallback()
                    }
                    
                    return
                }
            }
            catch
            {
                self.downloadContentError = .Error(error)
                
                if let announcementsLoadedCallback = self.announcementsLoadedCallback
                {
                    announcementsLoadedCallback()
                }
                
                return
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                do
                {
                    let reachability: Reachability =  try Reachability.reachabilityForInternetConnection()
                    if reachability.currentReachabilityStatus == .NotReachable
                    {
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            self.downloadContentError = .NoConnectivity
                            
                            completionBlock()
                        }
                        
                        return
                    }
                    try FileUtil.ensureFolder(ContentManager.contentPath)
                }
                catch
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.downloadContentError = .Error(error)
                        
                        completionBlock()
                    }
                    
                    return
                }
                
                let queueGroup = dispatch_group_create()
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                dispatch_group_enter(queueGroup)
                
                Announcement.getAnnouncements { (result) -> Void in
                    
                    if let fetchedAnnouncements = result.value
                    {
                        self.announcements = fetchedAnnouncements
                        
                        self.saveAnnouncements()
                        
                        if let announcementsLoadedCallback = self.announcementsLoadedCallback
                        {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                announcementsLoadedCallback()
                            }
                        }
                        
                        dispatch_group_leave(queueGroup)
                    }
                }
                
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
                
                dispatch_group_enter(queueGroup)
                
                Game.getAllGames { (result) -> Void in
                    
                    if let fetchedGames = result.value
                    {
                        self.games = fetchedGames
                        
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        self.loadPersistedTeamsFilter(userDefaults)
                        self.loadGameLocationFiler(userDefaults)
                        
                        self.filterGames()
                    }
                    
                    self.saveGames()
                    
                    dispatch_group_leave(queueGroup)
                }
                
                dispatch_group_notify(queueGroup, dispatch_get_main_queue()) {
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    ContentManager.lastCheckForContentUpdate = NSDate()
                    completionBlock()
                }
            }
        }
    }

        
    func checkforUpdates()
    {
        if let lastCheckForContentUpdate: NSDate = ContentManager.lastCheckForContentUpdate
        {
            let interval: NSTimeInterval = NSDate().timeIntervalSinceDate(lastCheckForContentUpdate)
            if interval < (1 * 60 * 2)
            {
                return
            }
        }
        
        self.downloadContentError = .None
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let queueGroup = dispatch_group_create()
            
            let contentUpdate: ContentUpdate = ContentUpdate()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            dispatch_group_enter(queueGroup)
            
            Announcement.getAnnouncements { (result) -> Void in
                
                if let fetchedAnnouncements = result.value
                {
                    var fetchedAnnouncementMap: [String: Announcement] = [String: Announcement]()
                    var updatedAnnouncements: [Announcement] = [Announcement]()
                    var deletedAnnouncements: [Announcement] = [Announcement]()
                    
                    for fetchedAnnouncement in fetchedAnnouncements
                    {
                        fetchedAnnouncementMap[fetchedAnnouncement.announcementId] = fetchedAnnouncement
                        
                        var found: Bool = false
                        
                        for announcement in self.announcements
                        {
                            if announcement.announcementId == fetchedAnnouncement.announcementId
                            {
                                found = true
                                break;
                            }
                        }
                        
                        if !found
                        {
                            updatedAnnouncements.append(fetchedAnnouncement)
                        }
                    }
                    
                    for announcement in self.announcements
                    {
                        if let fetchedAnnouncement: Announcement = fetchedAnnouncementMap[announcement.announcementId]
                        {
                            if !announcement.modified.isEqualToDate(fetchedAnnouncement.modified)
                            {
                                updatedAnnouncements.append(fetchedAnnouncement)
                            }
                        }
                        else
                        {
                            deletedAnnouncements.append(announcement)
                        }
                    }
                    
                    if !updatedAnnouncements.isEmpty
                    {
                        contentUpdate.updatedAnnouncements = updatedAnnouncements
                    }
                    
                    if !deletedAnnouncements.isEmpty
                    {
                        contentUpdate.deletedAnnouncements = deletedAnnouncements
                    }
                    
                    dispatch_group_leave(queueGroup)
                }
            }
            
            dispatch_group_enter(queueGroup)
            
            Venue.getVenues { (result) -> Void in
                
                if let fetchedVenues = result.value
                {
                    var fetchedVenueMap: [String: Venue] = [String: Venue]()
                    var updatedVenues: [Venue] = [Venue]()
                    var deletedVenues: [Venue] = [Venue]()
                    
                    for fetchedVenue in fetchedVenues
                    {
                        fetchedVenueMap[fetchedVenue.venueId] = fetchedVenue
                        
                        if self.venueMap[fetchedVenue.venueId] == nil
                        {
                            updatedVenues.append(fetchedVenue)
                        }
                    }
                    
                    for venue in self.venueMap.values
                    {
                        if let fetchedVenue: Venue = fetchedVenueMap[venue.venueId]
                        {
                            if !venue.modified.isEqualToDate(fetchedVenue.modified)
                            {
                                updatedVenues.append(fetchedVenue)
                            }
                        }
                        else
                        {
                            deletedVenues.append(venue)
                        }
                    }
                    
                    if !updatedVenues.isEmpty
                    {
                        contentUpdate.updatedVenues = updatedVenues
                    }
                    
                    if !deletedVenues.isEmpty
                    {
                        contentUpdate.deletedVenues = deletedVenues
                    }
                }
                
                dispatch_group_leave(queueGroup)
            }
            
            dispatch_group_enter(queueGroup)
            
            Team.getTeams { (result) -> Void in
                
                if let fetchedTeams = result.value
                {
                    var fetchedTeamsMap: [String: Team] = [String: Team]()
                    var updatedTeams: [Team] = [Team]()
                    var deletedTeams: [Team] = [Team]()
                    
                    for fetchedTeam in fetchedTeams
                    {
                        fetchedTeamsMap[fetchedTeam.teamId] = fetchedTeam
                        
                        if self.teamMap[fetchedTeam.teamId] == nil
                        {
                            updatedTeams.append(fetchedTeam)
                        }
                    }
                    
                    for team in self.teamMap.values
                    {
                        if let fetchedTeam: Team = fetchedTeamsMap[team.teamId]
                        {
                            if !team.modified.isEqualToDate(fetchedTeam.modified)
                            {
                                updatedTeams.append(fetchedTeam)
                            }
                        }
                        else
                        {
                            deletedTeams.append(team)
                        }
                    }
                    
                    if !updatedTeams.isEmpty
                    {
                        contentUpdate.updatedTeams = updatedTeams
                    }
                    
                    if !deletedTeams.isEmpty
                    {
                        contentUpdate.deletedTeams = deletedTeams
                    }
                }
                
                dispatch_group_leave(queueGroup)
            }
            
            dispatch_group_enter(queueGroup)
            
            Schedule.getSchedules { (result) -> Void in
                
                if let fetchedSchedules = result.value
                {
                    var fetchedSchedulesMap: [String: Schedule] = [String: Schedule]()
                    var updatedSchedules: [Schedule] = [Schedule]()
                    var deletedSchedules: [Schedule] = [Schedule]()
                    
                    for fetchedSchedule in fetchedSchedules
                    {
                        fetchedSchedulesMap[fetchedSchedule.scheduleId] = fetchedSchedule
                        
                        if self.scheduleMap[fetchedSchedule.scheduleId] == nil
                        {
                            updatedSchedules.append(fetchedSchedule)
                        }
                    }
                    
                    for schedule in self.scheduleMap.values
                    {
                        if let fetchedSchedule: Schedule = fetchedSchedulesMap[schedule.scheduleId]
                        {
                            if !schedule.modified.isEqualToDate(fetchedSchedule.modified)
                            {
                                updatedSchedules.append(fetchedSchedule)
                            }
                        }
                        else
                        {
                            deletedSchedules.append(schedule)
                        }
                    }
                    
                    if !updatedSchedules.isEmpty
                    {
                        contentUpdate.updatedSchedules = updatedSchedules
                    }
                    
                    if !deletedSchedules.isEmpty
                    {
                        contentUpdate.deletedSchedules = deletedSchedules
                    }
                }
                
                dispatch_group_leave(queueGroup)
            }
            
            dispatch_group_enter(queueGroup)
            
            GameInfo.getAllGameInfo { (result) -> Void in
                
                if let fetchedGameInfos = result.value
                {
                    var fetchedGameInfoMap: [Int: GameInfo] = [Int: GameInfo]()
                    var gameMap: [Int: Game] = [Int: Game]()
                    var deletedGames: [Game] = [Game]()
                    var updatedKeys: [Int] = [Int]()
                    
                    for game in self.games
                    {
                        gameMap[game.gamePostId] = game
                    }
                    
                    for fetchedGameInfo in fetchedGameInfos
                    {
                        fetchedGameInfoMap[fetchedGameInfo.gamePostId] = fetchedGameInfo
                        
                        if gameMap[fetchedGameInfo.gamePostId] == nil
                        {
                            updatedKeys.append(fetchedGameInfo.gamePostId)
                        }
                    }
                    
                    for game in self.games
                    {
                        if let fetchedGameInfo: GameInfo = fetchedGameInfoMap[game.gamePostId]
                        {
                            if !game.modified.isEqualToDate(fetchedGameInfo.modified)
                            {
                                updatedKeys.append(fetchedGameInfo.gamePostId)
                            }
                        }
                        else
                        {
                            deletedGames.append(game)
                        }
                    }
                    
                    if !deletedGames.isEmpty
                    {
                        contentUpdate.deletedGames = deletedGames
                    }
                    
                    if !updatedKeys.isEmpty
                    {
                        contentUpdate.updatedGameKeys = updatedKeys
                    }
                }
                
                
                dispatch_group_leave(queueGroup)
            }
            
            
            dispatch_group_wait(queueGroup, DISPATCH_TIME_FOREVER)
            
            if let gameKeys = contentUpdate.updatedGameKeys where gameKeys.count > 0
            {
                dispatch_group_enter(queueGroup)
                
                if gameKeys.count < 10
                {
                    Game.getGamesForKeys(gameKeys) { (result) -> Void in
                        
                        if let fetchedGames = result.value
                        {
                            contentUpdate.updatedGames = fetchedGames
                        }
                        
                        dispatch_group_leave(queueGroup)
                    }
                }
                else
                {
                    // There are too many updates to retreive by key just get all the games.
                    
                    Game.getAllGames { (result) -> Void in
                        
                        if let fetchedGames = result.value
                        {
                            contentUpdate.allGames = fetchedGames
                        }
                        
                        dispatch_group_leave(queueGroup)
                    }
                }
                
            }
            
            dispatch_group_notify(queueGroup, dispatch_get_main_queue()) {
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                ContentManager.lastCheckForContentUpdate = NSDate()
                
                if contentUpdate.isContentUpdated
                {
                    self.isLoadingContent = true
                    self.handleContentUpdate(contentUpdate)
                    //completionBlock()
                }
            }
        }
    }
    
    private func handleContentUpdate(contentUpdate: ContentUpdate)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if (contentUpdate.updatedAnnouncements != nil || contentUpdate.deletedAnnouncements != nil)
            {
                var announcementSet: Set<String> = Set<String>()
                
                if let updatedAnnouncements = contentUpdate.updatedAnnouncements
                {
                    for announcement in updatedAnnouncements
                    {
                        announcementSet.insert(announcement.announcementId)
                    }
                }
                
                if let deletedAnnouncements = contentUpdate.deletedAnnouncements
                {
                    for announcement in deletedAnnouncements
                    {
                        announcementSet.insert(announcement.announcementId)
                    }
                }
                
                if announcementSet.count > 0
                {
                    var filteredAnnouncements = self.announcements.filter { return !announcementSet.contains($0.announcementId) }
                    if let updatedAnnouncements = contentUpdate.updatedAnnouncements
                    {
                        filteredAnnouncements.appendContentsOf(updatedAnnouncements)
                    }
                    
                    if !filteredAnnouncements.isEmpty
                    {
                        self.announcements = filteredAnnouncements.sort { $0.date.compare($1.date) == .OrderedDescending}
                        
                        self.saveAnnouncements()
                    }
                }
            }
            
            if contentUpdate.updatedVenues != nil || contentUpdate.deletedVenues != nil
            {
                if let updatedVenues = contentUpdate.updatedVenues
                {
                    for venue in updatedVenues
                    {
                        self.venueMap[venue.venueId] = venue
                    }
                }
                
                if let deletedVenues = contentUpdate.deletedVenues
                {
                    for venue in deletedVenues
                    {
                        self.venueMap.removeValueForKey(venue.venueId)
                    }
                }
                
                self.saveVenues()
            }
            
            if contentUpdate.updatedTeams != nil || contentUpdate.deletedTeams != nil
            {
                if let updatedTeams = contentUpdate.updatedTeams
                {
                    for team in updatedTeams
                    {
                        self.teamMap[team.teamId] = team
                    }
                }
                
                if let deletedTeams = contentUpdate.deletedTeams
                {
                    for team in deletedTeams
                    {
                        self.teamMap.removeValueForKey(team.teamId)
                    }
                }
                
                self.saveTeams()
            }
            
            if contentUpdate.updatedSchedules != nil || contentUpdate.deletedSchedules != nil
            {
                if let updatedSchedules = contentUpdate.updatedSchedules
                {
                    for schedule in updatedSchedules
                    {
                        self.scheduleMap[schedule.scheduleId] = schedule
                    }
                }
                
                if let deletedSchedules = contentUpdate.deletedSchedules
                {
                    for schedule in deletedSchedules
                    {
                        self.scheduleMap.removeValueForKey(schedule.scheduleId)
                    }
                }
                
                self.saveSchedules()
            }
            
            if let allGames: [Game] = contentUpdate.allGames where allGames.count > 0
            {
                self.games = allGames
                
                self.saveGames()
                
                self.filterGames()
            }
            else if contentUpdate.updatedGames != nil || contentUpdate.deletedGames != nil
            {
                var gameSet: Set<String> = Set<String>()
                
                if let updatedGames = contentUpdate.updatedGames
                {
                    for game in updatedGames
                    {
                        gameSet.insert(game.gameId)
                    }
                }
                
                if let deletedGames = contentUpdate.deletedGames
                {
                    for game in deletedGames
                    {
                        gameSet.insert(game.gameId)
                    }
                }
                
                if gameSet.count > 0
                {
                    var filteredGames = self.games.filter { return !gameSet.contains($0.gameId) }
                    if let updatedGames = contentUpdate.updatedGames
                    {
                        filteredGames.appendContentsOf(updatedGames)
                    }
                    
                    if !filteredGames.isEmpty
                    {
                        self.games = filteredGames.sort { $0.gameDate.compare($1.gameDate) == .OrderedAscending}
                    }
                    
                    self.saveGames()
                    
                    self.filterGames()
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.isLoadingContent = false
                
                if let announcementsLoadedCallback = self.announcementsLoadedCallback where contentUpdate.updatedAnnouncements != nil || contentUpdate.deletedAnnouncements != nil
                {
                    announcementsLoadedCallback()
                }
                
                if let loadContentCallback = self.loadContentScheduleCallback
                {
                    loadContentCallback()
                }
                
                if let calendarCallback = self.loadContentCalendarCallback
                {
                    calendarCallback()
                }
            }
        }
    }
    
    func fireGameContentCallbacks()
    {
        dispatch_async(dispatch_get_main_queue()) {
            
            if let loadContentCallback = self.loadContentScheduleCallback
            {
                loadContentCallback()
            }
            
            if let calendarCallback = self.loadContentCalendarCallback
            {
                calendarCallback()
            }
        }
    }
    
    func loadPersistedTeamsFilter(userDefaults: NSUserDefaults)
    {
        if let teamIds:[String] = userDefaults.objectForKey("teamsFilter") as? [String]
        {
            let selectedTeams: [Team] = teamIds.flatMap { self.teamMap[$0] }
            
            self.teamsFilterStorage = .Selected(selectedTeams)
        }
    }
    
    func loadGameLocationFiler(userDefaults: NSUserDefaults)
    {
        if let gameLocationNumber: NSNumber = userDefaults.objectForKey("gameLocationFilter") as? NSNumber, let filter: GameLocationFilter = GameLocationFilter(rawValue: gameLocationNumber.integerValue)
        {
            self.gameLocationFilterStorage = filter
        }
    }
    
    func filterGames()
    {
        let filteredGames: [Game]
        self.gameSections.removeAll()

        switch teamsFilter
        {
            case .All:
                
            if gameLocationFilter != .All
            {
                filteredGames = games.filter {
                    
                    if gameLocationFilter == .Home && $0.isHomeGame
                    {
                        return true
                    }
                    else if gameLocationFilter == .Away && !$0.isHomeGame
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
            }
            else
            {
                filteredGames = games
            }
            
            case .Selected(let teams):
                filteredGames = games.filter {
                    
                    if let schedule: Schedule = scheduleMap[$0.gameScheduleId], let scheduledTeam: Team = teamMap[schedule.scheduleTeamId]
                    {
                        if teams.contains(scheduledTeam)
                        {
                            if gameLocationFilter != .All
                            {
                                if gameLocationFilter == .Home && $0.isHomeGame
                                {
                                    return true
                                }
                                else if gameLocationFilter == .Away && !$0.isHomeGame
                                {
                                    return true
                                }
                                else
                                {
                                    return false
                                }
                            }
                            
                            return true
                        }
                    }
                    
                    return false
            }
        }
        
        for game in filteredGames
        {
            if let gameDay: NSDate = ContentManager.dayForDate(game.gameDate)
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
    
    func refreshGamesWithFilter()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
         
            self.filterGames()
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let loadContentCallback = self.loadContentScheduleCallback
                {
                    loadContentCallback()
                }
                
                if let calendarCallback = self.loadContentCalendarCallback
                {
                    calendarCallback()
                }
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
    
    func loadVenues() throws
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
        else
        {
            throw NSError(domain: "ContentManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unarchive venues"])
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
    
    func loadTeams() throws
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
        else
        {
            throw NSError(domain: "ContentManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unarchive teams"])
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
    
    func loadSchedules() throws
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
        else
        {
            throw NSError(domain: "ContentManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unarchive schedules"])
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
    
    func loadGames() throws
    {
        games.removeAll()
        gameSections.removeAll()
        
        let gamesFileName = ContentManager.contentPath.stringByAppendingPathComponent("games.ser")
        
        if let helperGames: [Game.Helper] = NSKeyedUnarchiver.unarchiveObjectWithFile(gamesFileName) as? [Game.Helper]
        {
            self.games = helperGames.flatMap { $0.game }
        }
        else
        {
            throw NSError(domain: "ContentManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unarchive games"])
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
    
    func loadAnnouncements() throws
    {
        announcements.removeAll()
        
        let announcementsFileName = ContentManager.contentPath.stringByAppendingPathComponent("announcements.ser")
        
        if let helperAnnouncements: [Announcement.Helper] = NSKeyedUnarchiver.unarchiveObjectWithFile(announcementsFileName) as? [Announcement.Helper]
        {
            self.announcements = helperAnnouncements.flatMap { $0.announcement }
        }
        else
        {
            throw NSError(domain: "ContentManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unarchive announcements"])
        }
    }

    class func dayForDate(date: NSDate) -> NSDate?
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
    
    class var lastCheckForContentUpdate: NSDate?
    {
        get
        {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.objectForKey("lastCheckForContentUpdate") as? NSDate
        }
        set
        {
            if let validDate: NSDate = newValue
            {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(validDate, forKey: "lastCheckForContentUpdate")
                userDefaults.synchronize()
            }
        }
    }
}