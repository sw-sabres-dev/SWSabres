//
//  GameDetailViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import MapKit
import ReachabilitySwift

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
    weak var saveAction: UIAlertAction?
    
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
        self.firstScoreLabel.text = nil
        self.secondScoreLabel.text = nil
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "addressLabelPressed:")
        self.addressLabel.addGestureRecognizer(gesture)
        
        self.populateControlsWithGame()

        /*
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, contentManager: ContentManager = delegate.contentManager, let game = game
        {
            
            if let schedule: Schedule = contentManager.scheduleMap[game.gameScheduleId], let team: Team = contentManager.teamMap[schedule.scheduleTeamId], let shortName = team.shortName
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
            
            if let teamId: String = game.teamId, let team: Team = contentManager.teamMap[teamId], let teamName: String = team.shortName ?? team.name
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
            
            if let gameVenueId = game.gameVenueId, let venue: Venue = contentManager.venueMap[gameVenueId]
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

            
        }
        */
        
        // Do any additional setup after loading the view.
    }

    func populateControlsWithGame()
    {
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, contentManager: ContentManager = delegate.contentManager, let game = game
        {
            if let schedule: Schedule = contentManager.scheduleMap[game.gameScheduleId], let team: Team = contentManager.teamMap[schedule.scheduleTeamId], let shortName = team.shortName
            {
                if game.isHomeGame
                {
                    firstLogo.image = UIImage(named: "logo")
                    firstLogoLabel.text = shortName
                    if let score = game.gameOurScore
                    {
                        firstScoreLabel.text = String(score)
                        firstScoreLabel.hidden = false
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
                        secondScoreLabel.hidden = false
                    }
                    else
                    {
                        secondScoreLabel.hidden = true
                    }
                }
            }
            
            if let teamId: String = game.teamId, let team: Team = contentManager.teamMap[teamId], let teamName: String = team.shortName ?? team.name
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
                        secondScoreLabel.hidden = false
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
                        firstScoreLabel.hidden = false
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
                        secondScoreLabel.hidden = false
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
                        firstScoreLabel.hidden = false
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
            
            if let gameVenueId = game.gameVenueId, let venue: Venue = contentManager.venueMap[gameVenueId]
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
        }
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
        do
        {
            let reachability: Reachability =  try Reachability.reachabilityForInternetConnection()
            if reachability.currentReachabilityStatus == .NotReachable
            {
                self.showMessageBox("Error", message: "No Internet Connectivity found!")
            }
            else
            {
                self.showScoreEditAlert()
            }
        }
        catch
        {
            self.showMessageBox("Error", message: "\(error)")
        }
    }
    
    func showScoreEditAlert(message: String? = nil)
    {
        let alertController = UIAlertController(title: addScoreButton.title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            
            if let firstScoreField: UITextField = alertController.textFields?[0], let secondScoreField: UITextField = alertController.textFields?[1]
            {
                if let firstScoreString = firstScoreField.text, let firstScore: Int = Int(firstScoreString), let secondScoreString = secondScoreField.text, let secondScore: Int = Int(secondScoreString), var gameToUpdate = self.game
                {
                    gameToUpdate.gameOurScore = gameToUpdate.isHomeGame ? firstScore : secondScore
                    gameToUpdate.gameOppScore = gameToUpdate.isHomeGame ? secondScore : firstScore
                    gameToUpdate.gameResult = String(format: "%@: %@-%@", gameToUpdate.gameOurScore > gameToUpdate.gameOppScore ? "W" : "L", firstScoreString, secondScoreString)
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
                    
                    Game.updateGameScore(gameToUpdate, completionHandler: { (result) -> Void in
                        
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
                        
                        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, contentManager: ContentManager = delegate.contentManager, let updateGameScoreResult = result.value, let dayOfGame: NSDate = ContentManager.dayForDate(gameToUpdate.gameDate), var gamesOnDay: [Game] = contentManager.gameSections[dayOfGame] where updateGameScoreResult.success
                        {
                            gamesOnDay = gamesOnDay.filter { return $0.gamePostId != gameToUpdate.gamePostId }
                            gamesOnDay.append(gameToUpdate)
                            
                            contentManager.gameSections[dayOfGame] = gamesOnDay
                            self.game = gameToUpdate
                            
                            self.populateControlsWithGame()
                            
                            contentManager.fireGameContentCallbacks()
                            
                            alertController.dismissViewControllerAnimated(true, completion: nil)
                            
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                self.showScoreEditAlert("Updating the score failed. Please try again.")
                            }
                        }
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.showScoreEditAlert("Score is invalid. Please try again.")
                    }
                }
            }
            
        }
        self.saveAction = action
        
        alertController.addAction(action)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            //textField.keyboardType = .NumberPad
            textField.placeholder = self.firstLogoLabel.text
            textField.text = self.firstScoreLabel.text
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            //textField.keyboardType = .NumberPad
            textField.placeholder = self.secondLogoLabel.text
            textField.text = self.secondScoreLabel.text
        }
        
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
}
