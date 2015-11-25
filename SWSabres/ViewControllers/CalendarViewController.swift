//
//  CalendarViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/11/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import RSDayFlow

class CalendarViewController: UIViewController, RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource, UITableViewDataSource
{
    @IBOutlet weak var calendarView: GameCalendarDatePickerView!
    @IBOutlet weak var gameTableView: UITableView!

    var gameSections: [NSDate: [Game]] = [NSDate: [Game]]()
    var selectedDaysGames: [Game] = [Game]()
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()

    lazy var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        calendarView.delegate = self
        calendarView.dataSource = self
        gameTableView.dataSource = self
        
        self.title = "Game Calendar"

        self.view.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle

        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            delegate.contentManager.loadContentCalendarCallback = {
                
                self.gameSections = contentManager.gameSections
                self.scheduleMap = contentManager.scheduleMap
                self.venueMap = contentManager.venueMap
                self.teamMap = contentManager.teamMap
                
                self.gotoToday()
            }
            
            if !delegate.contentManager.isLoadingContent
            {
                self.gameSections = contentManager.gameSections
                self.scheduleMap = contentManager.scheduleMap
                self.venueMap = contentManager.venueMap
                self.teamMap = contentManager.teamMap

                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.gotoToday()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if let indexPath = gameTableView.indexPathForSelectedRow
        {
            gameTableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }
    
    func gotoToday(animate: Bool = false)
    {
        if let today: NSDate = ContentManager.dayForDate(NSDate())
        {
            calendarView?.selectDate(today)
            calendarView?.scrollToDate(today, animated: animate)
            
            if let games: [Game] = self.gameSections[today]
            {
                selectedDaysGames = games
            }
            else
            {
                selectedDaysGames.removeAll()
            }
            
            self.gameTableView?.reloadData()
        }
    }
    
    @IBAction func todayButtonPressed(sender: UIBarButtonItem)
    {
        self.gotoToday(true)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue)
    {
        if let gameFilterViewController = segue.sourceViewController as? GameFilterTableViewController, let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            if gameFilterViewController.filtersChanged
            {
                contentManager.refreshGamesWithFilter()
            }
        }
    }
    
    func datePickerView(view: RSDFDatePickerView!, didSelectDate date: NSDate!)
    {
        if let games: [Game] = self.gameSections[date]
        {
            selectedDaysGames = games
        }
        else
        {
            selectedDaysGames.removeAll()
        }
        
        self.gameTableView.reloadData()
    }
    
    func datePickerView(view: RSDFDatePickerView!, shouldMarkDate date: NSDate!) -> Bool
    {
        return self.gameSections[date] != nil
    }
    
    func datePickerView(view: RSDFDatePickerView!, markImageColorForDate date: NSDate!) -> UIColor!
    {
//        if let today: NSDate = ContentManager.dayForDate(NSDate())
//        {
//            if today.isEqualToDate(date)
//            {
//                return AppTintColors.backgroundTintColor
//            }
//        }
        
        return UIColor.lightGrayColor()
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let cell: UITableViewCell = sender as? UITableViewCell, let indexPath = gameTableView.indexPathForCell(cell), let viewController: GameDetailViewController = segue.destinationViewController as? GameDetailViewController
        {
            viewController.game = selectedDaysGames[indexPath.row]
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
            return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selectedDaysGames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let baseCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("gameLogoCellIdentifier", forIndexPath: indexPath)
        
        if let cell: GameLogoTableViewCell = baseCell as? GameLogoTableViewCell
        {
            let game = selectedDaysGames[indexPath.row]
            
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
            
            return cell
        }
        
        return baseCell
    }
}
