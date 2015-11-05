//
//  ScheduleTableViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PINRemoteImage

final class ScheduleTableViewController: UITableViewController
{
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    lazy var dateFormatter: NSDateFormatter = NSDateFormatter()
    var gameSections: [NSDate: [Game]] = [NSDate: [Game]]()
    var sortedDays: [NSDate] = [NSDate]()
    lazy var sectionDateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "Game Schedule"

        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle

        //sectionDateFormatter.dateFormat = "EEE MMM dd yyyy"
        sectionDateFormatter.dateStyle = .FullStyle
        sectionDateFormatter.timeStyle = .NoStyle
        
        self.tableView.rowHeight = 88
        
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
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.sortedDays.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let dayDate: NSDate = self.sortedDays[section]
        let gamesOnDay: [Game]? = self.gameSections[dayDate]
        
        return gamesOnDay != nil ? gamesOnDay!.count : 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let dayDate: NSDate = self.sortedDays[section]
        
        return sectionDateFormatter.stringFromDate(dayDate)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let baseCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("gameLogoCellIdentifier", forIndexPath: indexPath)
        
        if let cell: GameLogoTableViewCell = baseCell as? GameLogoTableViewCell
        {
            let dayDate: NSDate = self.sortedDays[indexPath.section]
            if let gamesOnDay: [Game] = self.gameSections[dayDate]
            {
                let game = gamesOnDay[indexPath.row]
             
                if let schedule: Schedule = scheduleMap[game.gameScheduleId], let team: Team = teamMap[schedule.scheduleTeamId], let shortName = team.shortName
                {
                    if game.isHomeGame
                    {
                        cell.firstLogo.image = UIImage(named: "logo")
                        cell.firstLogoLabel.text = shortName
                    }
                    else
                    {
                        cell.secondLogo.image = UIImage(named: "logo")
                        cell.secondLogoLabel.text = shortName
                    }
                }
                
                if let teamId: String = game.teamId, let team: Team = teamMap[teamId], let teamName: String = team.shortName ?? team.name
                {
                    var logoUrl: NSURL? = nil
                    
                    if let teamLogoUrlString: String = team.logoUrl
                    {
                        logoUrl = NSURL(string: teamLogoUrlString)
                    }
                    
                    if game.isHomeGame
                    {
                        cell.secondLogo.image = nil
                        cell.secondLogo.pin_setImageFromURL(logoUrl)
                        cell.secondLogoLabel.text = teamName
                    }
                    else
                    {
                        cell.firstLogo.image = nil
                        cell.firstLogo.pin_setImageFromURL(logoUrl)
                        cell.firstLogoLabel.text = teamName
                    }
                }
                else if let opponent = game.opponent
                {
                    if game.isHomeGame
                    {
                        cell.secondLogo.pin_setImageFromURL(nil)
                        cell.secondLogo.image = nil
                        cell.secondLogoLabel.text = opponent
                    }
                    else
                    {
                        cell.firstLogo.pin_setImageFromURL(nil)
                        cell.firstLogo.image = nil
                        cell.firstLogoLabel.text = opponent
                    }
                }
                
                if let gameResult = game.gameResult
                {
                    cell.gameTimeLabel.text = gameResult
                    cell.venueLabel.hidden = true
                    cell.addressLabel.hidden = true
                }
                else
                {
                    cell.venueLabel.hidden = false
                    cell.addressLabel.hidden = false

                    cell.gameTimeLabel.text = dateFormatter.stringFromDate(game.gameDate)
                    
                    if let gameVenueId = game.gameVenueId, let venue: Venue = self.venueMap[gameVenueId]
                    {
                        cell.venueLabel.text = venue.title
                        cell.addressLabel.text = "\(venue.address) \(venue.city) \(venue.state) \(venue.zip)"
                    }
                    else
                    {
                        cell.venueLabel.text = ""
                        cell.addressLabel.text = ""
                    }
                }
            }
            else
            {
                cell.firstLogoLabel.text = ""
                cell.firstLogo.pin_setImageFromURL(nil)
                cell.firstLogo.image = nil
                cell.secondLogoLabel.text = ""
                cell.secondLogo.pin_setImageFromURL(nil)
                cell.secondLogo.image = nil
                cell.gameTimeLabel.text = ""
                cell.venueLabel.text = ""
                cell.addressLabel.text = ""
            }
            
            return cell

        }
        
        return baseCell
        
        /*
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reuseIdentifier")
            cell.accessoryType = .DisclosureIndicator
        }
        
        // Configure the cell...

        let dayDate: NSDate = self.sortedDays[indexPath.section]
        if let gamesOnDay: [Game] = self.gameSections[dayDate]
        {
            let game = gamesOnDay[indexPath.row]
            
            var labelText: String = ""
            
            labelText += dateFormatter.stringFromDate(game.gameDate)
            labelText += " "
            
            if let schedule: Schedule = scheduleMap[game.gameScheduleId], let team: Team = teamMap[schedule.scheduleTeamId], let shortName = team.shortName
            {
                labelText += "\(shortName) "
                
                labelText += game.isHomeGame ? "vs " : "at "
                
            }
            
            if let teamId: String = game.teamId, let team: Team = teamMap[teamId]
            {
                if let teamName: String = team.name
                {
                    labelText += teamName
                }
            }
            else
            {
                if let opponent = game.opponent
                {
                    labelText += opponent
                }
            }
            
            cell.textLabel?.text = labelText
            
            if let gameVenueId = game.gameVenueId, let venue: Venue = self.venueMap[gameVenueId]
            {
                cell.detailTextLabel?.text = venue.title
            }

        }
        
        
        return cell
        */
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView
        {
            headerView.contentView.backgroundColor = ApptTintColors.backgroundTintColor
            headerView.textLabel?.textColor = UIColor.whiteColor()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
