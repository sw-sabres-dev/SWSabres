//
//  GameDetailViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import MapKit

class GameDetailViewController: UIViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstLogo: UIImageView!
    @IBOutlet weak var firstLogoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var secondLogo: UIImageView!
    @IBOutlet weak var secondLogoLabel: UILabel!
    
    @IBOutlet weak var venueTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var game: Game?
    weak var contentManager: ContentManager?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        /*
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.containerView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0)
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.containerView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0)
        
        self.view.addConstraint(leftConstraint)
        self.view.addConstraint(rightConstraint
        )
        */
        /*
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
            attribute:NSLayoutAttributeLeading
            relatedBy:0
            toItem:self.view
            attribute:NSLayoutAttributeLeft
            multiplier:1.0
            constant:0];
        [self.view addConstraint:leftConstraint];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
            attribute:NSLayoutAttributeTrailing
            relatedBy:0
            toItem:self.view
            attribute:NSLayoutAttributeRight
            multiplier:1.0
            constant:0];
        [self.view addConstraint:rightConstraint];
        */
        
        //self.scrollView.contentSize = CGSizeMake(200, 200)
        
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        {
            contentManager = delegate.contentManager
        }
        else
        {
            return
        }
        
        if let game = game
        {
            
            if let schedule: Schedule = contentManager!.scheduleMap[game.gameScheduleId], let team: Team = contentManager!.teamMap[schedule.scheduleTeamId], let shortName = team.shortName
            {
                if game.isHomeGame
                {
                    firstLogo.image = UIImage(named: "logo")
                    firstLogoLabel.text = shortName
                }
                else
                {
                    secondLogo.image = UIImage(named: "logo")
                    secondLogoLabel.text = shortName
                }
            }
            
            if let teamId: String = game.teamId, let team: Team = contentManager!.teamMap[teamId], let teamName: String = team.shortName ?? team.name
            {
                var logoUrl: NSURL? = nil
                
                if let teamLogoUrlString: String = team.logoUrl
                {
                    logoUrl = NSURL(string: teamLogoUrlString)
                }
                
                if game.isHomeGame
                {
                    secondLogo.image = nil
                    secondLogo.pin_setImageFromURL(logoUrl)
                    secondLogoLabel.text = teamName
                }
                else
                {
                    firstLogo.image = nil
                    firstLogo.pin_setImageFromURL(logoUrl)
                    firstLogoLabel.text = teamName
                }
            }
            else if let opponent = game.opponent
            {
                if game.isHomeGame
                {
                    secondLogo.pin_setImageFromURL(nil)
                    secondLogo.image = nil
                    secondLogoLabel.text = opponent
                }
                else
                {
                    firstLogo.pin_setImageFromURL(nil)
                    firstLogo.image = nil
                    firstLogoLabel.text = opponent
                }
            }
            
            if let firstText: String = firstLogoLabel.text, let secondText: String = secondLogoLabel.text
            {
                self.title = "\(firstText) vs. \(secondText)"
            }
            
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM dd"
            
            self.dateLabel.text = dateFormatter.stringFromDate(game.gameDate)
            

            if let gameResult = game.gameResult
            {
                timeLabel.text = gameResult
            }
            else
            {
                dateFormatter.dateFormat = nil
                dateFormatter.timeStyle = .ShortStyle

                timeLabel.text = dateFormatter.stringFromDate(game.gameDate)
            }
            
            if let gameVenueId = game.gameVenueId, let venue: Venue = self.contentManager!.venueMap[gameVenueId]
            {
                venueTitleLabel.text = venue.title
                let address = "\(venue.address) \(venue.city) \(venue.state) \(venue.zip)"
                addressLabel.text = address
                
                showAddressOnMap(address)
            }
            else
            {
                venueTitleLabel.text = ""
                addressLabel.text = ""
            }

            let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "addressLabelPressed:")
            self.addressLabel.addGestureRecognizer(gesture)
            
        }
        
        // Do any additional setup after loading the view.
    }

    func addressLabelPressed(gesture: UIGestureRecognizer)
    {
        if let address: String = addressLabel.text
        {
            let pasteBoard = UIPasteboard.generalPasteboard()
            pasteBoard.string = address
            
            showMessageBox(venueTitleLabel.text, message: "Address copied to clipboard.")
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAddressOnMap(address: String)
    {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if (error != nil)
            {
                print("geocode Error", error)
            }
            if let placemark = placemarks?.first
            {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
                }
            }
        })

    }

    private func showMessageBox(title: String?, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppTintColors.backgroundTintColor
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
