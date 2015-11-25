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
    lazy var dateFormatter: NSDateFormatter = NSDateFormatter()
    lazy var sectionDateFormatter: NSDateFormatter = NSDateFormatter()
    
    var gameSections: [NSDate: [Game]] = [NSDate: [Game]]()
    var selectedDaysGames: [Game] = [Game]()
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    var sortedDays: [NSDate] = [NSDate]()
    
    weak var contentManager: ContentManager?
    
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
        
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        {
            contentManager = delegate.contentManager
            
            delegate.contentManager.loadContentScheduleCallback = {
                
                self.gameSections = delegate.contentManager.gameSections
                self.scheduleMap = delegate.contentManager.scheduleMap
                self.venueMap = delegate.contentManager.venueMap
                self.teamMap = delegate.contentManager.teamMap
                self.sortedDays = delegate.contentManager.sortedDays
                
                self.tableView?.reloadData()
                self.gotoNearestNextGame()
            }
            
            if !delegate.contentManager.isLoadingContent
            {
                self.gameSections = delegate.contentManager.gameSections
                self.scheduleMap = delegate.contentManager.scheduleMap
                self.venueMap = delegate.contentManager.venueMap
                self.teamMap = delegate.contentManager.teamMap
                self.sortedDays = delegate.contentManager.sortedDays

                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.gotoNearestNextGame()
                }
            }
//            delegate.contentManager.loadContent {
//            
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                self.tableView.reloadData()
//                
//                self.gotoNearestNextGame()
//            }
        }
    }
    @IBAction func todayButtonPressed(sender: UIBarButtonItem)
    {
        self.gotoNearestNextGame(true)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue)
    {
        if let gameFilterViewController = segue.sourceViewController as? GameFilterTableViewController, let contentManager = contentManager
        {
            if gameFilterViewController.filtersChanged
            {
                contentManager.refreshGamesWithFilter()
            }
        }
    }
    
    func gotoNearestNextGame(animate: Bool = false)
    {
        if let today: NSDate = ContentManager.dayForDate(NSDate())
        {
            for var index = 0; index < sortedDays.count; ++index
            {
                let result: NSComparisonResult = today.compare(sortedDays[index])
                if result == .OrderedSame || result == .OrderedAscending
                {
                    self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: index), atScrollPosition: .Top, animated: animate)
                    break;
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sortedDays.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let dayDate: NSDate = sortedDays[section]
        let gamesOnDay: [Game]? = gameSections[dayDate]
        
        return gamesOnDay != nil ? gamesOnDay!.count : 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let dayDate: NSDate = sortedDays[section]
        
        return sectionDateFormatter.stringFromDate(dayDate)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let baseCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("gameLogoCellIdentifier", forIndexPath: indexPath)
        
        if let cell: GameLogoTableViewCell = baseCell as? GameLogoTableViewCell
        {
            let dayDate: NSDate = sortedDays[indexPath.section]
            if let gamesOnDay: [Game] = gameSections[dayDate]
            {
                let game = gamesOnDay[indexPath.row]
             
                if let schedule: Schedule = scheduleMap[game.gameScheduleId], let team: Team = teamMap[schedule.scheduleTeamId], let shortName = team.shortName
                {
                    if game.isHomeGame
                    {
                        cell.firstLogo.pin_setImageFromURL(nil)
                        cell.firstLogo.image = UIImage(named: "logo")
                        cell.firstLogoLabel.text = shortName
                    }
                    else
                    {
                        cell.secondLogo.pin_setImageFromURL(nil)
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
                    
                    if let gameVenueId = game.gameVenueId, let venue: Venue = venueMap[gameVenueId]
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
            headerView.contentView.backgroundColor = AppTintColors.backgroundTintColor
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let cell: UITableViewCell = sender as? UITableViewCell, let indexPath = self.tableView.indexPathForCell(cell), let viewController: GameDetailViewController = segue.destinationViewController as? GameDetailViewController
        {
            let dayDate: NSDate = sortedDays[indexPath.section]
            if let gamesOnDay: [Game] = gameSections[dayDate]
            {
                viewController.game = gamesOnDay[indexPath.row]
            }
        }
    }

}
