//
//  AnnouncementsTableViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

class AnnouncementsTableViewController: UITableViewController {

    var announcements: [Announcement] = [Announcement]()
    lazy var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .NoStyle
        
        if let logoTitleView: LogoTitleView = LogoTitleView.loadFromNibNamed("LogoTitleView") as? LogoTitleView
        {
            logoTitleView.backgroundColor = ApptTintColors.backgroundTintColor
            logoTitleView.titleLabel.textColor = UIColor.whiteColor()
            
            if let size = self.navigationController?.navigationBar.bounds
            {
                logoTitleView.frame = size
            }
            self.navigationItem.titleView = logoTitleView
        }
        
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "announcementCellIdentifier")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let jsonCacheFolder = documentFolder.stringByAppendingPathComponent("jsonCacheFolder")
            
            do
            {
                try FileUtil.ensureFolder(jsonCacheFolder)
            }
            catch
            {
                return
            }
            
            let announcementsFileName = jsonCacheFolder.stringByAppendingPathComponent("announcements.json")
            let fileManager: NSFileManager = NSFileManager()
            
            if fileManager.fileExistsAtPath(announcementsFileName)
            {
                self.announcements =  Announcement.loadObjects(announcementsFileName)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.tableView.reloadData()
                }
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                Announcement.getAnnouncements(announcementsFileName) { (result) -> Void in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if let fetchedAnnouncements = result.value
                    {
                        self.announcements = fetchedAnnouncements
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return announcements.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("announcementCellIdentifier", forIndexPath: indexPath)

//        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
//        if (cell == nil)
//        {
//            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reuseIdentifier")
//        }
        
        // Configure the cell...

        let announcement = announcements[indexPath.row]
        
        if let announcementCell: AnnouncementTableViewCell = cell as? AnnouncementTableViewCell
        {
            announcementCell.headlineLabel.text = announcement.title
            announcementCell.dateLabel.text = dateFormatter.stringFromDate(announcement.date)
        }

        //cell.textLabel?.text = announcement.title
        //cell.detailTextLabel?.text = dateFormatter.stringFromDate(announcement.date)
        
        return cell
    }

    /*
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0
        {
            
            let header: UIView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 117))
            header.backgroundColor = ApptTintColors.backgroundTintColor
            
            let imageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, tableView.frame.width, 117))
            imageView.contentMode = .ScaleAspectFit
            imageView.image = UIImage(named: "banner")
            header.addSubview(imageView)
            
            return header
            
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 117
    }
*/
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
