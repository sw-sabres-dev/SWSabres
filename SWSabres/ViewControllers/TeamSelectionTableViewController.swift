//
//  TeamSelectionTableViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/8/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

class TeamSelectionTableViewController: UITableViewController
{
    var teams: [Team] = [Team]()
    var updatedTeamFilter: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.tintColor = AppTintColors.backgroundTintColor
        self.title = "Teams"
        
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            self.teams = contentManager.scheduleMap.values.flatMap { contentManager.teamMap[$0.scheduleTeamId] }
            self.teams.sortInPlace {
                
                if let shortName1 = $0.shortName, let shortName2 = $1.shortName
                {
                    return shortName1.compare(shortName2) == .OrderedAscending
                }
                else
                {
                    return false
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
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
        return teams.count + 1 // +1 is for all teams.
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("teamCellIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            if indexPath.row == 0
            {
                cell.textLabel?.text = "All Teams"

                switch contentManager.teamsFilter
                {
                    case .All:
                        cell.accessoryType = .Checkmark
                    default:
                        cell.accessoryType = .None
                    break
                }
            }
            else
            {
                let team: Team = teams[indexPath.row-1]
                cell.textLabel?.text = team.shortName
                
                switch contentManager.teamsFilter
                {
                case .Selected(let selectedTeams):
                    cell.accessoryType = selectedTeams.contains(team) ? .Checkmark : .None
                    
                default:
                    cell.accessoryType = .None
                    break
                }
            }
        }
        //cell.accessoryType = .Checkmark
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            if indexPath.row == 0
            {
                switch contentManager.teamsFilter
                {
                    case .All:
                    return
                    
                    default:
                    contentManager.teamsFilter = .All
                    updatedTeamFilter = true

                    tableView.reloadData()
                }
                
            }
            else
            {
                switch contentManager.teamsFilter
                {
                    case .All:
                    
                        var selectedTeams: [Team] = [Team]()
                        selectedTeams.append(teams[indexPath.row-1])
                        contentManager.teamsFilter = .Selected(selectedTeams)
                        updatedTeamFilter = true
                    
                        tableView.reloadData()
                    
                    case .Selected(var selectedTeams):
                    
                        let team = teams[indexPath.row-1]
                        if let index = selectedTeams.indexOf(team)
                        {
                            selectedTeams.removeAtIndex(index)
                            if selectedTeams.count > 0
                            {
                                selectedTeams.sortInPlace {
                                    
                                    if let shortName1 = $0.shortName, let shortName2 = $1.shortName
                                    {
                                        return shortName1.compare(shortName2) == .OrderedAscending
                                    }
                                    else
                                    {
                                        return false
                                    }
                                }
                                
                                contentManager.teamsFilter = .Selected(selectedTeams)
                            }
                            else
                            {
                                contentManager.teamsFilter = .All
                            }
                            
                            tableView.reloadData()
                        }
                        else
                        {
                            if teams.count > 0 && selectedTeams.count == teams.count - 1
                            {
                                contentManager.teamsFilter = .All
                            }
                            else
                            {
                                selectedTeams.append(team)
                                selectedTeams.sortInPlace {
                                    
                                    if let shortName1 = $0.shortName, let shortName2 = $1.shortName
                                    {
                                        return shortName1.compare(shortName2) == .OrderedAscending
                                    }
                                    else
                                    {
                                        return false
                                    }
                                }
                                contentManager.teamsFilter = .Selected(selectedTeams)
                            }
                            updatedTeamFilter = true
                            
                            tableView.reloadData()
                        }
                }
            }
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
