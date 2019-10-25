//
//  GameDetailViewController.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/5/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import UIKit
import MapKit
import Reachability

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    @objc var venuePlacemark: MKPlacemark?
    @objc weak var saveAction: UIAlertAction?
    
    var reachability: Reachability?

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
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameDetailViewController.addressLabelPressed(_:)))
        self.addressLabel.addGestureRecognizer(gesture)
        
        self.populateControlsWithGame()

        // Do any additional setup after loading the view.
        self.reachability = Reachability()
    }

    @objc func populateControlsWithGame()
    {
        if let delegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager, let game = game
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
                        firstScoreLabel.isHidden = false
                    }
                    else
                    {
                        firstScoreLabel.isHidden = true
                    }
                }
                else
                {
                    secondLogo.image = UIImage(named: "logo")
                    secondLogoLabel.text = shortName
                    if let score = game.gameOurScore
                    {
                        secondScoreLabel.text = String(score)
                        secondScoreLabel.isHidden = false
                    }
                    else
                    {
                        secondScoreLabel.isHidden = true
                    }
                }
            }
            
            if let teamId: String = game.teamId, let team: Team = contentManager.teamMap[teamId], let teamName: String = team.shortName ?? team.name
            {
                var logoUrl: URL? = nil
                
                if let teamLogoUrlString: String = team.logoUrl
                {
                    logoUrl = URL(string: teamLogoUrlString)
                }
                
                if game.isHomeGame
                {
                    secondLogo.image = nil
                    secondLogo.pin_setImage(from: logoUrl)
                    secondLogoLabel.text = teamName
                    if let score = game.gameOppScore
                    {
                        secondScoreLabel.text = String(score)
                        secondScoreLabel.isHidden = false
                    }
                    else
                    {
                        secondScoreLabel.isHidden = true
                    }
                }
                else
                {
                    firstLogo.image = nil
                    firstLogo.pin_setImage(from: logoUrl)
                    firstLogoLabel.text = teamName
                    if let score = game.gameOppScore
                    {
                        firstScoreLabel.text = String(score)
                        firstScoreLabel.isHidden = false
                    }
                    else
                    {
                        firstScoreLabel.isHidden = true
                    }
                }
            }
            else if let opponent = game.opponent
            {
                if game.isHomeGame
                {
                    secondLogo.pin_setImage(from: nil)
                    secondLogo.image = nil
                    secondLogoLabel.text = opponent
                    if let score = game.gameOppScore
                    {
                        secondScoreLabel.text = String(score)
                        secondScoreLabel.isHidden = false
                    }
                    else
                    {
                        secondScoreLabel.isHidden = true
                    }
                }
                else
                {
                    firstLogo.pin_setImage(from: nil)
                    firstLogo.image = nil
                    firstLogoLabel.text = opponent
                    if let score = game.gameOppScore
                    {
                        firstScoreLabel.text = String(score)
                        firstScoreLabel.isHidden = false
                    }
                    else
                    {
                        firstScoreLabel.isHidden = true
                    }
                }
            }
            
            let now = Date()
            let compareResult = game.gameDate.compare(now)
            
            if let gameDatePlusOneDay = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: game.gameDate as Date, options:[])
            {
                addScoreButton.isEnabled = compareResult != .orderedDescending && now.compare(gameDatePlusOneDay) != .orderedDescending
            }
            
            if game.gameOurScore != nil && game.gameOppScore != nil
            {
                addScoreButton.title = "Edit Score"
            }
            
            if let firstText: String = firstLogoLabel.text, let secondText: String = secondLogoLabel.text
            {
                self.title = "\(firstText) vs. \(secondText)"
            }
            
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd"
            
            self.dateLabel.text = dateFormatter.string(from: game.gameDate as Date)
            
            
            if let gameResult = game.gameResult
            {
                timeLabel.text = gameResult
            }
            else
            {
                dateFormatter.dateFormat = nil
                dateFormatter.timeStyle = .short
                
                timeLabel.text = dateFormatter.string(from: game.gameDate as Date)
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
    
    @objc func addressLabelPressed(_ gesture: UIGestureRecognizer)
    {
        if let address: String = addressLabel.text
        {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = address
            
            showMessageBox(venueTitleLabel.text, message: "Address copied to clipboard.")
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showAddressOnMap(_ address: String)
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
                DispatchQueue.main.async {
                    
                    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
                    self.mapView.camera.altitude *= 3
                }
            }
        })

    }

    fileprivate func showMessageBox(_ title: String?, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppTintColors.backgroundTintColor
    }
    
    @IBAction func addScoreButtonPressed(_ sender: UIBarButtonItem)
    {
        if reachability?.connection == Reachability.Connection.none
        {
            self.showMessageBox("Error", message: "No Internet Connectivity found!")
        }
        else
        {
            self.showScoreEditAlert()
        }
    }
    
    @objc func showScoreEditAlert(_ message: String? = nil)
    {
        let alertController = UIAlertController(title: addScoreButton.title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Save", style: .default) { (action) -> Void in
            
            if let firstScoreField: UITextField = alertController.textFields?[0], let secondScoreField: UITextField = alertController.textFields?[1]
            {
                if let firstScoreString = firstScoreField.text, let firstScore: Int = Int(firstScoreString), let secondScoreString = secondScoreField.text, let secondScore: Int = Int(secondScoreString), var gameToUpdate = self.game
                {
                    gameToUpdate.gameOurScore = gameToUpdate.isHomeGame ? firstScore : secondScore
                    gameToUpdate.gameOppScore = gameToUpdate.isHomeGame ? secondScore : firstScore
                    gameToUpdate.gameResult = String(format: "%@: %@-%@", gameToUpdate.gameOurScore > gameToUpdate.gameOppScore ? "W" : "L", firstScoreString, secondScoreString)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    self.navigationController?.view.isUserInteractionEnabled = false
                    
                    Game.updateGameScore(gameToUpdate, completionHandler: { (result) -> Void in
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.navigationController?.view.isUserInteractionEnabled = true
                        
                        if let delegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate, let contentManager: ContentManager = delegate.contentManager, let updateGameScoreResult = result.value, let dayOfGame: Date = ContentManager.dayForDate(gameToUpdate.gameDate), var gamesOnDay: [Game] = contentManager.gameSections[dayOfGame], updateGameScoreResult.success
                        {
                            gamesOnDay = gamesOnDay.filter { return $0.gamePostId != gameToUpdate.gamePostId }
                            gamesOnDay.append(gameToUpdate)
                            
                            contentManager.gameSections[dayOfGame] = gamesOnDay.sorted { $0.gameDate.compare($1.gameDate) == .orderedAscending}
                            self.game = gameToUpdate
                            
                            self.populateControlsWithGame()
                            
                            contentManager.fireGameContentCallbacks()
                            
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                
                                self.showScoreEditAlert("Updating the score failed. Please try again.")
                            }
                        }
                    })
                }
                else
                {
                    DispatchQueue.main.async {
                        
                        self.showScoreEditAlert("Score is invalid. Please try again.")
                    }
                }
            }
            
        }
        self.saveAction = action
        
        alertController.addAction(action)
        
        alertController.addTextField { (textField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = self.firstLogoLabel.text
            textField.text = self.firstScoreLabel.text
        }
        
        alertController.addTextField { (textField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = self.secondLogoLabel.text
            textField.text = self.secondScoreLabel.text
        }
        
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppTintColors.backgroundTintColor
    }
    
    @IBAction func directionsButtonPressed(_ sender: AnyObject)
    {
        if let venuePlacemark = self.venuePlacemark
        {
            let mapItem = MKMapItem(placemark: venuePlacemark)
            
            MKMapItem.openMaps(with: [mapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}
