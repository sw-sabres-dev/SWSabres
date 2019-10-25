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
    @objc lazy var dateFormatter: DateFormatter = DateFormatter()
    @objc lazy var sectionDateFormatter: DateFormatter = DateFormatter()
    
    var gameSections: [Date: [Game]] = [Date: [Game]]()
    var selectedDaysGames: [Game] = [Game]()
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()
    @objc var sortedDays: [Date] = [Date]()
    
    weak var contentManager: ContentManager?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "Game Schedule"

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        //sectionDateFormatter.dateFormat = "EEE MMM dd yyyy"
        sectionDateFormatter.dateStyle = .full
        sectionDateFormatter.timeStyle = .none
        
        self.tableView.rowHeight = 88
        
        if let delegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            contentManager = delegate.contentManager
            
            delegate.contentManager.loadContentScheduleCallback = {
                
                self.gameSections = delegate.contentManager.gameSections as [Date : [Game]]
                self.scheduleMap = delegate.contentManager.scheduleMap
                self.venueMap = delegate.contentManager.venueMap
                self.teamMap = delegate.contentManager.teamMap
                self.sortedDays = delegate.contentManager.sortedDays as [Date]
                
                self.tableView?.reloadData()
                self.gotoNearestNextGame()
            }
            
            if !delegate.contentManager.isLoadingContent
            {
                self.gameSections = delegate.contentManager.gameSections as [Date : [Game]]
                self.scheduleMap = delegate.contentManager.scheduleMap
                self.venueMap = delegate.contentManager.venueMap
                self.teamMap = delegate.contentManager.teamMap
                self.sortedDays = delegate.contentManager.sortedDays as [Date]

                DispatchQueue.main.async {
                    
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
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem)
    {
        self.gotoNearestNextGame(true)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue)
    {
        if let gameFilterViewController = segue.source as? GameFilterTableViewController, let contentManager = contentManager
        {
            if gameFilterViewController.filtersChanged
            {
                contentManager.refreshGamesWithFilter()
            }
        }
    }
    
    @objc func gotoNearestNextGame(_ animate: Bool = false)
    {
        if let today: Date = ContentManager.dayForDate(Date())
        {
            for index in 0 ..< sortedDays.count
            {
                let result: ComparisonResult = today.compare(sortedDays[index])
                if result == .orderedSame || result == .orderedAscending
                {
                    self.tableView?.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: animate)
                    break;
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return sortedDays.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let dayDate: Date = sortedDays[section]
        let gamesOnDay: [Game]? = gameSections[dayDate]
        
        return gamesOnDay != nil ? gamesOnDay!.count : 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let dayDate: Date = sortedDays[section]
        
        return sectionDateFormatter.string(from: dayDate)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let baseCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "gameLogoCellIdentifier", for: indexPath)
        
        if let cell: GameLogoTableViewCell = baseCell as? GameLogoTableViewCell
        {
            let dayDate: Date = sortedDays[indexPath.section]
            if let gamesOnDay: [Game] = gameSections[dayDate]
            {
                let game = gamesOnDay[indexPath.row]
             
                if let schedule: Schedule = scheduleMap[game.gameScheduleId], let team: Team = teamMap[schedule.scheduleTeamId], let shortName = team.shortName
                {
                    if game.isHomeGame
                    {
                        cell.firstLogo.pin_setImage(from: nil)
                        cell.firstLogo.image = UIImage(named: "logo")
                        cell.firstLogoLabel.text = shortName
                    }
                    else
                    {
                        cell.secondLogo.pin_setImage(from: nil)
                        cell.secondLogo.image = UIImage(named: "logo")
                        cell.secondLogoLabel.text = shortName
                    }
                }
                
                if let teamId: String = game.teamId, let team: Team = teamMap[teamId], let teamName: String = team.shortName ?? team.name
                {
                    var logoUrl: URL? = nil
                    
                    if let teamLogoUrlString: String = team.logoUrl
                    {
                        logoUrl = URL(string: teamLogoUrlString)
                    }
                    
                    if game.isHomeGame
                    {
                        cell.secondLogo.image = nil
                        cell.secondLogo.pin_setImage(from: logoUrl)
                        cell.secondLogoLabel.text = teamName
                    }
                    else
                    {
                        cell.firstLogo.image = nil
                        cell.firstLogo.pin_setImage(from: logoUrl)
                        cell.firstLogoLabel.text = teamName
                    }
                }
                else if let opponent = game.opponent
                {
                    if game.isHomeGame
                    {
                        cell.secondLogo.pin_setImage(from: nil)
                        cell.secondLogo.image = nil
                        cell.secondLogoLabel.text = opponent
                    }
                    else
                    {
                        cell.firstLogo.pin_setImage(from: nil)
                        cell.firstLogo.image = nil
                        cell.firstLogoLabel.text = opponent
                    }
                }
                
                if let gameResult = game.gameResult
                {
                    cell.gameTimeLabel.text = gameResult
                    cell.venueLabel.isHidden = true
                    cell.addressLabel.isHidden = true
                }
                else
                {
                    cell.venueLabel.isHidden = false
                    cell.addressLabel.isHidden = false

                    cell.gameTimeLabel.text = dateFormatter.string(from: game.gameDate as Date)
                    
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
                cell.firstLogo.pin_setImage(from: nil)
                cell.firstLogo.image = nil
                cell.secondLogoLabel.text = ""
                cell.secondLogo.pin_setImage(from: nil)
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

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView
        {
            headerView.contentView.backgroundColor = AppTintColors.backgroundTintColor
            headerView.textLabel?.textColor = UIColor.white
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let cell: UITableViewCell = sender as? UITableViewCell, let indexPath = self.tableView.indexPath(for: cell), let viewController: GameDetailViewController = segue.destination as? GameDetailViewController
        {
            let dayDate: Date = sortedDays[indexPath.section]
            if let gamesOnDay: [Game] = gameSections[dayDate]
            {
                viewController.game = gamesOnDay[indexPath.row]
            }
        }
    }

}
