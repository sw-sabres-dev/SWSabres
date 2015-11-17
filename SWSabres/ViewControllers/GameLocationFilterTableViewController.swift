//
//  GameLocationFilterTableViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/17/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

class GameLocationFilterTableViewController: UITableViewController
{
    var updatedGameLocationFilter: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.tintColor = AppTintColors.backgroundTintColor
        self.title = "Game Locations"
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
        
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("gameLocationCellIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            switch indexPath.row
            {
            case 0:
                
                cell.textLabel?.text = "All"
                cell.accessoryType = contentManager.gameLocationFilter == .All ? .Checkmark : .None
                
            case 1:
                
                cell.textLabel?.text = "Home"
                cell.accessoryType = contentManager.gameLocationFilter == .Home ? .Checkmark : .None
                
            case 2:
                
                cell.textLabel?.text = "Away"
                cell.accessoryType = contentManager.gameLocationFilter == .Away ? .Checkmark : .None
                
            default:
                break;
                
            }
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager
        {
            switch indexPath.row
            {
            case 0:
                
                if contentManager.gameLocationFilter == .All
                {
                    return
                }
                else
                {
                    contentManager.gameLocationFilter = .All
                    updatedGameLocationFilter = true
                    tableView.reloadData()
                }
                
            case 1:
                
                if contentManager.gameLocationFilter == .Home
                {
                    return
                }
                else
                {
                    contentManager.gameLocationFilter = .Home
                    updatedGameLocationFilter = true
                    tableView.reloadData()
                }
                
            case 2:
                
                if contentManager.gameLocationFilter == .Away
                {
                    return
                }
                else
                {
                    contentManager.gameLocationFilter = .Away
                    updatedGameLocationFilter = true
                    tableView.reloadData()
                }
                
            default:
                break
                
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
