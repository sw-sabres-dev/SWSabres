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
    @IBOutlet weak var firstScoreLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var secondLogo: UIImageView!
    @IBOutlet weak var secondLogoLabel: UILabel!
    @IBOutlet weak var secondScoreLabel: UILabel!
    
    @IBOutlet weak var venueTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var addScoreButton: UIBarButtonItem!
    
    var game: Game?
    var venuePlacemark: MKPlacemark?
    
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
        
        let actionButtonColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0)
        self.directionsButton.tintColor = actionButtonColor
        
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
                    if let score = game.gameOurScore
                    {
                        firstScoreLabel.text = String(score)
                    }
                    else
                    {
                        firstScoreLabel.hidden = true
                    }
                }
                else
                {
                    secondLogo.image = UIImage(named: "logo")
                    secondLogoLabel.text = shortName
                    if let score = game.gameOurScore
                    {
                        secondScoreLabel.text = String(score)
                    }
                    else
                    {
                        secondScoreLabel.hidden = true
                    }
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
                    if let score = game.gameOppScore
                    {
                        secondScoreLabel.text = String(score)
                    }
                    else
                    {
                        secondScoreLabel.hidden = true
                    }
                }
                else
                {
                    firstLogo.image = nil
                    firstLogo.pin_setImageFromURL(logoUrl)
                    firstLogoLabel.text = teamName
                    if let score = game.gameOppScore
                    {
                        firstScoreLabel.text = String(score)
                    }
                    else
                    {
                        firstScoreLabel.hidden = true
                    }
                }
            }
            else if let opponent = game.opponent
            {
                if game.isHomeGame
                {
                    secondLogo.pin_setImageFromURL(nil)
                    secondLogo.image = nil
                    secondLogoLabel.text = opponent
                    if let score = game.gameOppScore
                    {
                        secondScoreLabel.text = String(score)
                    }
                    else
                    {
                        secondScoreLabel.hidden = true
                    }
                }
                else
                {
                    firstLogo.pin_setImageFromURL(nil)
                    firstLogo.image = nil
                    firstLogoLabel.text = opponent
                    if let score = game.gameOppScore
                    {
                        firstScoreLabel.text = String(score)
                    }
                    else
                    {
                        firstScoreLabel.hidden = true
                    }
                }
            }
            
            let compareResult = game.gameDate.compare(NSDate())
            addScoreButton.enabled = compareResult == .OrderedAscending || compareResult == .OrderedSame
            
            if game.gameOurScore != nil && game.gameOppScore != nil
            {
                addScoreButton.title = "Edit Score"
            }
            
//            firstScoreTextField.hidden = compareResult == .OrderedDescending
//            secondScoreTextField.hidden = compareResult == .OrderedDescending

            
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
                let mkPlacemark = MKPlacemark(placemark: placemark)
                self.venuePlacemark = mkPlacemark
                
                self.mapView.addAnnotation(mkPlacemark)
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
                    self.mapView.camera.altitude *= 3
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
    
    @IBAction func addScoreButtonPressed(sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: addScoreButton.title, message: nil, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppTintColors.backgroundTintColor
    }
    
    @IBAction func directionsButtonPressed(sender: AnyObject)
    {
        if let venuePlacemark = self.venuePlacemark
        {
            let mapItem = MKMapItem(placemark: venuePlacemark)
            
            MKMapItem.openMapsWithItems([mapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
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
