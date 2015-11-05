//
//  AnnouncementDetailsViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit

class AnnouncementDetailsViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView!
    var announcement: Announcement?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let announcement = announcement
        {
            self.title = announcement.title
            webView.loadHTMLString(announcement.content, baseURL: nil)
            //textView.attributedText = announcement.content
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
