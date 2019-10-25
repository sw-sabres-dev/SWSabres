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

    var gameSections: [Date: [Game]] = [Date: [Game]]()
    var selectedDaysGames: [Game] = [Game]()
    var scheduleMap: [String: Schedule] = [String: Schedule]()
    var venueMap: [String: Venue] = [String: Venue]()
    var teamMap: [String: Team] = [String: Team]()

    @objc lazy var dateFormatter: DateFormatter = DateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        calendarView.delegate = self
        calendarView.dataSource = self
        gameTableView.dataSource = self
        
        self.title = "Game Calendar"

        self.view.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        if let delegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            delegate.contentManager.loadContentCalendarCallback = {
                
                self.gameSections = contentManager.gameSections as [Date : [Game]]
                self.scheduleMap = contentManager.scheduleMap
                self.venueMap = contentManager.venueMap
                self.teamMap = contentManager.teamMap
                
                self.gotoToday()
            }
            
            if !delegate.contentManager.isLoadingContent
            {
                self.gameSections = contentManager.gameSections as [Date : [Game]]
                self.scheduleMap = contentManager.scheduleMap
                self.venueMap = contentManager.venueMap
                self.teamMap = contentManager.teamMap

                DispatchQueue.main.async {
                    
                    self.gotoToday()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if let indexPath = gameTableView.indexPathForSelectedRow
        {
            gameTableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    @objc func gotoToday(_ animate: Bool = false)
    {
        if let today: Date = ContentManager.dayForDate(Date())
        {
            calendarView?.select(today)
            calendarView?.scroll(to: today, animated: animate)
            
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
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem)
    {
        self.gotoToday(true)
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue)
    {
        if let gameFilterViewController = segue.source as? GameFilterTableViewController, let delegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            if gameFilterViewController.filtersChanged
            {
                contentManager.refreshGamesWithFilter()
            }
        }
    }
    
    func datePickerView(_ view: RSDFDatePickerView!, didSelect date: Date!)
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
    
    func datePickerView(_ view: RSDFDatePickerView!, shouldMark date: Date!) -> Bool
    {
        return self.gameSections[date] != nil
    }
    
    func datePickerView(_ view: RSDFDatePickerView!, markImageColorFor date: Date!) -> UIColor!
    {
//        if let today: NSDate = ContentManager.dayForDate(NSDate())
//        {
//            if today.isEqualToDate(date)
//            {
//                return AppTintColors.backgroundTintColor
//            }
//        }
        
        return UIColor.lightGray
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let cell: UITableViewCell = sender as? UITableViewCell, let indexPath = gameTableView.indexPath(for: cell), let viewController: GameDetailViewController = segue.destination as? GameDetailViewController
        {
            viewController.game = selectedDaysGames[indexPath.row]
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selectedDaysGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let baseCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "gameLogoCellIdentifier", for: indexPath)
        
        if let cell: GameLogoTableViewCell = baseCell as? GameLogoTableViewCell
        {
            let game = selectedDaysGames[indexPath.row]
            print("Displaying game \(game.gameId) in calendar view")
            
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
                
                cell.gameTimeLabel.text = game.isTimeTba ?
                    "TBA" : dateFormatter.string(from: game.gameDate as Date)
                
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
