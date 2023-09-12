//
//  ContentManager.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import os.log

final class ContentManager
{
    enum TeamsFilter
    {
        case all
        case selected([Team])
    }
    
    enum GameLocationFilter : Int
    {
        case all = 0
        case home = 1
        case away = 2
    }
    
    enum DownloadContentError: Error
    {
        case none
        case noConnectivity
        case error(Error)
    }
    
    var isLoadingContent: Bool = false
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    var games: [Game] = [Game]()
    var gameSections: [Date: [Game]] = [Date: [Game]]()
    var sortedDays: [Date] = [Date]()
    var announcements: [Announcement] = [Announcement]()
    var loadContentScheduleCallback: (() -> ())?
    var loadContentCalendarCallback: (() -> ())?
    var announcementsLoadedCallback: (() -> ())?
    var downloadContentError: DownloadContentError = .none
    
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
                case .all:
                
                    let userDefaults = UserDefaults.standard
                    if userDefaults.object(forKey: "teamsFilter") != nil
                    {
                        userDefaults.removeObject(forKey: "teamsFilter")
                    }
                    userDefaults.synchronize()
                
                case .selected(let teams):
                    
                    let helperTeamsIds: [String] = teams.map { $0.teamId }
                    
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(helperTeamsIds, forKey: "teamsFilter")
                    userDefaults.synchronize()
            }
            
        }
    }
    
    fileprivate var teamsFilterStorage: TeamsFilter = .all
    
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
            case .all:
                
                let userDefaults = UserDefaults.standard
                if userDefaults.object(forKey: "gameLocationFilter") != nil
                {
                    userDefaults.removeObject(forKey: "gameLocationFilter")
                }
                userDefaults.synchronize()
                
            default:
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(NSNumber(value: newValue.rawValue as Int), forKey: "gameLocationFilter")
                userDefaults.synchronize()
            }
            
        }
    }
    
    fileprivate var gameLocationFilterStorage: GameLocationFilter = .all
    
    init()
    {
        self.loadContent()
    }
    
    class var contentPath: String
    {
        get
        {
            let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return documentFolder.stringByAppendingPathComponent("contentCache")
        }
    }
    
    func loadContent()
    {
        isLoadingContent = true
        
        let userDefaults = UserDefaults.standard
        if userDefaults.integer(forKey: "resetContentCount") == 0
        {
            os_log("Found resetContentCount = 0, deleting saved data at games.ser")
            let gamesFileName = ContentManager.contentPath.stringByAppendingPathComponent("games.ser")
            let fileManager: FileManager = FileManager()
            if fileManager.fileExists(atPath: gamesFileName)
            {
                do
                {
                    try fileManager.removeItem(atPath: gamesFileName)
                }
                catch
                {
                }
            }
            
            userDefaults.set(1, forKey: "resetContentCount")
            userDefaults.synchronize()
        }
        
        DispatchQueue.global().async {
            
            let fileManager: FileManager = FileManager()
            
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
            
            if fileManager.fileExists(atPath: announcementsFileName) && fileManager.fileExists(atPath: venuesFileName) && fileManager.fileExists(atPath: teamsFileName) && fileManager.fileExists(atPath: schedulesFileName) && fileManager.fileExists(atPath: gamesFileName)
            {
                os_log("Loading saved data from file")
                do
                {
                    try self.loadAnnouncements()
                    try self.loadVenues()
                    try self.loadTeams()
                    try self.loadSchedules()
                    try self.loadGames()
                    
                    let userDefaults = UserDefaults.standard
                    self.loadPersistedTeamsFilter(userDefaults)
                    self.loadGameLocationFiler(userDefaults)
                    
                    self.filterGames()
                    
                    DispatchQueue.main.async {
                        
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
                        try fileManager.removeItem(atPath: announcementsFileName)
                        try fileManager.removeItem(atPath: venuesFileName)
                        try fileManager.removeItem(atPath: teamsFileName)
                        try fileManager.removeItem(atPath: schedulesFileName)
                        try fileManager.removeItem(atPath: gamesFileName)
                        
                        let userDefaults = UserDefaults.standard
                        if userDefaults.object(forKey: "teamsFilter") != nil
                        {
                            userDefaults.removeObject(forKey: "teamsFilter")
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

    func downloadContent(_ completionBlock: @escaping () -> ())
    {
        os_log("Downloading updated content")
        Task.detached(priority: .background) {
            let queueGroup = DispatchGroup()

            queueGroup.enter()
            
            if let announcements = await Announcement.getAnnouncements() {
                self.announcements = announcements
                
                self.saveAnnouncements()
                
                if let announcementsLoadedCallback = self.announcementsLoadedCallback
                {
                    DispatchQueue.main.async {
                        
                        announcementsLoadedCallback()
                    }
                }
                queueGroup.leave()
            }
            
            queueGroup.enter()
            
            if let venues = await Venue.getVenues() {
                self.venueMap.removeAll()
                
                for venue in venues
                {
                    self.venueMap[venue.venueId] = venue
                }
                
                self.saveVenues()
                
                queueGroup.leave()
            }
            
            queueGroup.enter()
            
            if let teams = await Team.getTeams() {
                self.teamMap.removeAll()
                
                for team in teams
                {
                    self.teamMap[team.teamId] = team
                }
                
                self.saveTeams()
                
                queueGroup.leave()
            }
            
            queueGroup.enter()
            
            if let schedules = await Schedule.getSchedules() {
                self.scheduleMap.removeAll()
                
                for schedule in schedules
                {
                    self.scheduleMap[schedule.scheduleId] = schedule
                }
                
                self.saveSchedules()
                
                queueGroup.leave()
            }
            
            queueGroup.enter()
            
            if let fetchedGames = await Game.getAllGames() {
                
                self.games = fetchedGames
                
                let userDefaults = UserDefaults.standard
                self.loadPersistedTeamsFilter(userDefaults)
                self.loadGameLocationFiler(userDefaults)
                
                self.filterGames()
                
                self.saveGames()
                
                queueGroup.leave()
            }
            
            DispatchQueue.main.async {
                ContentManager.lastCheckForContentUpdate = Date()
                completionBlock()
            }
        }
    }

        
    func checkforUpdates()
    {
        if let lastCheckForContentUpdate: Date = ContentManager.lastCheckForContentUpdate
        {
            let interval: TimeInterval = Date().timeIntervalSince(lastCheckForContentUpdate)
            if interval < 15
            {
                os_log("Not ready to update, interval = %d", interval)
                return
            }
            os_log("Performing update")
        }
        
        self.downloadContentError = .none
        
        Task.detached(priority: .background) {
            
            let queueGroup = DispatchGroup()
            
            let contentUpdate: ContentUpdate = ContentUpdate()
            
            queueGroup.enter()
            
            if let fetchedAnnouncements = await Announcement.getAnnouncements() {
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
                        if announcement.modified != fetchedAnnouncement.modified
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
                
                queueGroup.leave()
            }
            
            queueGroup.enter()
            
            if let fetchedVenues = await Venue.getVenues() {
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
                        if venue.modified != fetchedVenue.modified
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
                
                queueGroup.leave()
            }
            queueGroup.enter()
            
            if let fetchedTeams = await Team.getTeams() {
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
                        if team.modified != fetchedTeam.modified
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

                queueGroup.leave()
            }
            
            queueGroup.enter()
            
            if let fetchedSchedules = await Schedule.getSchedules() {
                
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
                        if schedule.modified != fetchedSchedule.modified
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
                
                queueGroup.leave()
            }
            
            queueGroup.enter()
            
            contentUpdate.allGames = await Game.getAllGames()
            
            queueGroup.leave()
            
            queueGroup.notify(queue: DispatchQueue.main) {

                ContentManager.lastCheckForContentUpdate = Date()
                
                if contentUpdate.isContentUpdated
                {
                    self.isLoadingContent = true
                    self.handleContentUpdate(contentUpdate)
                    //completionBlock()
                }
            }
        }
    }
    
    fileprivate func handleContentUpdate(_ contentUpdate: ContentUpdate)
    {
        DispatchQueue.global().async {
            
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
                        filteredAnnouncements.append(contentsOf: updatedAnnouncements)
                    }
                    
                    if !filteredAnnouncements.isEmpty
                    {
                        self.announcements = filteredAnnouncements.sorted { $0.date.compare($1.date as Date) == .orderedDescending}
                        
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
                        self.venueMap.removeValue(forKey: venue.venueId)
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
                        self.teamMap.removeValue(forKey: team.teamId)
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
                        self.scheduleMap.removeValue(forKey: schedule.scheduleId)
                    }
                }
                
                self.saveSchedules()
            }
            
            if let allGames: [Game] = contentUpdate.allGames, allGames.count > 0
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
                    // get list of unchanged games
                    var filteredGames = self.games.filter { return !gameSet.contains($0.gameId) }
                    
                    // add updated games
                    if let updatedGames = contentUpdate.updatedGames
                    {
                        filteredGames.append(contentsOf: updatedGames)
                    }
                    
                    // sort games and "publish"
                    if !filteredGames.isEmpty
                    {
                        self.games = filteredGames.sorted { $0.gameDate.compare($1.gameDate as Date) == .orderedAscending}
                    }
                    
                    self.saveGames()
                    
                    self.filterGames()
                }
            }
            
            DispatchQueue.main.async {
                
                self.isLoadingContent = false
                
                if let announcementsLoadedCallback = self.announcementsLoadedCallback, contentUpdate.updatedAnnouncements != nil || contentUpdate.deletedAnnouncements != nil
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
        DispatchQueue.main.async {
            
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
    
    func loadPersistedTeamsFilter(_ userDefaults: UserDefaults)
    {
        if let teamIds:[String] = userDefaults.object(forKey: "teamsFilter") as? [String]
        {
            let selectedTeams: [Team] = teamIds.compactMap { self.teamMap[$0] }
            
            self.teamsFilterStorage = .selected(selectedTeams)
        }
    }
    
    func loadGameLocationFiler(_ userDefaults: UserDefaults)
    {
        if let gameLocationNumber: NSNumber = userDefaults.object(forKey: "gameLocationFilter") as? NSNumber, let filter: GameLocationFilter = GameLocationFilter(rawValue: gameLocationNumber.intValue)
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
            case .all:
                
            if gameLocationFilter != .all
            {
                filteredGames = games.filter {
                    
                    if gameLocationFilter == .home && $0.isHomeGame
                    {
                        return true
                    }
                    else if gameLocationFilter == .away && !$0.isHomeGame
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
            
            case .selected(let teams):
                filteredGames = games.filter {
                    
                    if let schedule: Schedule = scheduleMap[$0.gameScheduleId], let scheduledTeam: Team = teamMap[schedule.scheduleTeamId]
                    {
                        if teams.contains(scheduledTeam)
                        {
                            if gameLocationFilter != .all
                            {
                                if gameLocationFilter == .home && $0.isHomeGame
                                {
                                    return true
                                }
                                else if gameLocationFilter == .away && !$0.isHomeGame
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
        
        for game in filteredGames.sorted(by: { $0.gameDate.compare($1.gameDate) == .orderedAscending })
        {
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yyyy HH:mm:ss"
            let formattedDate = df.string(from: game.gameDate)
            os_log("Adding game %@ date: %@", log: .default, game.gameId, formattedDate)
            if let gameDay: Date = ContentManager.dayForDate(game.gameDate as Date)
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
        
        self.sortedDays = self.gameSections.keys.sorted {$0.compare($1) == .orderedAscending}
    }
    
    func refreshGamesWithFilter()
    {
        DispatchQueue.main.async {
         
            self.filterGames()
            
            DispatchQueue.main.async {
                
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
        
        if let helperVenueMap: [String: Venue.Helper] = NSKeyedUnarchiver.unarchiveObject(withFile: venuesFileName) as? [String: Venue.Helper]
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
        
        if let helperTeamMap: [String: Team.Helper] = NSKeyedUnarchiver.unarchiveObject(withFile: teamsFileName) as? [String: Team.Helper]
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
        
        if let helperScheduleMap: [String: Schedule.Helper] = NSKeyedUnarchiver.unarchiveObject(withFile: schedulesFileName) as? [String: Schedule.Helper]
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
        os_log("Saving all games")
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
        
        if let helperGames: [Game.Helper] = NSKeyedUnarchiver.unarchiveObject(withFile: gamesFileName) as? [Game.Helper]
        {
            self.games = helperGames.compactMap { $0.game }
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
        
        if let helperAnnouncements: [Announcement.Helper] = NSKeyedUnarchiver.unarchiveObject(withFile: announcementsFileName) as? [Announcement.Helper]
        {
            self.announcements = helperAnnouncements.compactMap { $0.announcement }
        }
        else
        {
            throw NSError(domain: "ContentManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unarchive announcements"])
        }
    }

    class func dayForDate(_ date: Date) -> Date?
    {
        var calendar = Calendar.current
        let timeZone = TimeZone.autoupdatingCurrent
        calendar.timeZone = timeZone
        
        var dateComps = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        
        dateComps.hour = 0
        dateComps.minute = 0
        dateComps.second = 0
        
        return calendar.date(from: dateComps)
    }
    
    class var lastCheckForContentUpdate: Date?
    {
        get
        {
            let userDefaults = UserDefaults.standard
            return userDefaults.object(forKey: "lastCheckForContentUpdate") as? Date
        }
        set
        {
            if let validDate: Date = newValue
            {
                let userDefaults = UserDefaults.standard
                userDefaults.set(validDate, forKey: "lastCheckForContentUpdate")
                userDefaults.synchronize()
            }
        }
    }
}
