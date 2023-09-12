//
//  GameFilterTableViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/8/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

class GameFilterTableViewController: UITableViewController {

    @objc var filtersChanged = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Filters"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func getCurrentTeamsFilterString() -> String
    {
        if let delegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            let contentManager: ContentManager = delegate.contentManager
            switch contentManager.teamsFilter
            {
                case .selected(let teams):
                
                    return teams.reduce("") {
                        wholeString, team in
                        let maybeComma = (team == teams.last) ? "" : ", "
                        return "\(wholeString)\(team.shortName ?? "")\(maybeComma)"
                }
                
                default:
                break
            }
        }
        
        return "All Teams"
    }
    
    @objc func getCurrentGameLocationFilterString() -> String
    {
        if let delegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            let contentManager: ContentManager = delegate.contentManager
            switch contentManager.gameLocationFilter
            {
                case .all:
                return "All"
                
                case .home:
                return "Home"
                
                case .away:
                return "Away"
            }
        }
        
        return "All"
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue)
    {
        if let teamSelectionViewController = segue.source as? TeamSelectionTableViewController, teamSelectionViewController.updatedTeamFilter == true
        {
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            filtersChanged = true
        }
        else if let gameLocationFilterTableViewController = segue.source as? GameLocationFilterTableViewController, gameLocationFilterTableViewController.updatedGameLocationFilter == true
        {
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            filtersChanged = true
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsStyleCellIdentifier", for: indexPath)

        // Configure the cell...

        switch indexPath.row
        {
            case 0:
            
            cell.textLabel?.text = "Teams"
            
            cell.detailTextLabel?.text = self.getCurrentTeamsFilterString()
            
            case 1:
            
            cell.textLabel?.text = "Game Locations"
            
            cell.detailTextLabel?.text = self.getCurrentGameLocationFilterString()
            
            default:
            break
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == 0
        {
            self.performSegue(withIdentifier: "teamsFilterSegue", sender: nil)
        }
        else if indexPath.row == 1
        {
            self.performSegue(withIdentifier: "gameLocationFilterSegue", sender: nil)
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
