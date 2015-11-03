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

class ScheduleTableViewController: UITableViewController
{
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    var games: [Game] = [Game]()
    lazy var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "Schedule"

        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle

        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "testCellIdentifier")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let queueGroup = dispatch_group_create()
            dispatch_group_enter(queueGroup)
            
            Venue.getVenues{ (result) -> Void in
                
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

            dispatch_group_enter(queueGroup)
            
            Team.getTeams{ (result) -> Void in
                
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

            dispatch_group_enter(queueGroup)
            
            Schedule.getSchedules{ (result) -> Void in
                
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

            dispatch_group_enter(queueGroup)
            
            Game.getAllGames{ (result) -> Void in
                
                if let fetchedGames = result.value
                {
                    self.games = fetchedGames
                    //self.games = fetchedGames.sort { $0.gameDate.compare($1.gameDate) == .OrderedAscending }
                }
                
                dispatch_group_leave(queueGroup)
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return games.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //let cell = tableView.dequeueReusableCellWithIdentifier("testCellIdentifier", forIndexPath: indexPath)

        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        // Configure the cell...

        let game = games[indexPath.row]
        
        var labelText: String = ""
        
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
        
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(game.gameDate)
        
        return cell
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
