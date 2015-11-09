//
//  GameFilterTableViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/8/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

class GameFilterTableViewController: UITableViewController {

    var filtersChanged = false
    
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

    func getCurrentTeamsFilterString() -> String
    {
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            switch contentManager.teamsFilter
            {
                case .Selected(let teams):
                
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
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue)
    {
        if let teamSelectionViewController = segue.sourceViewController as? TeamSelectionTableViewController
        {
            if teamSelectionViewController.updatedTeamFilter
            {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                filtersChanged = true
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsStyleCellIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        switch indexPath.row
        {
            case 0:
            
            cell.textLabel?.text = "Teams"
            
            cell.detailTextLabel?.text = self.getCurrentTeamsFilterString()
            default:
            break
        }
        
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == 0
        {
            self.performSegueWithIdentifier("teamsFilterSegue", sender: nil)
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
