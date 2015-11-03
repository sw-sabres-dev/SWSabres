//
//  Venue.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Venue: ResponseJSONObjectSerializable, UniqueObject
{
    static let endpoint: String = "http://www.southwakesabres.org/?json=get_posts&post_type=mstw_ss_venue&count=500"
    
    let venueId: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let title: String
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let venue_street = json["custom_fields"]["venue_street"][0].string else
        {
            return nil
        }
        
        guard let venue_city = json["custom_fields"]["venue_city"][0].string else
        {
            return nil
        }
        
        guard let venue_state = json["custom_fields"]["venue_state"][0].string else
        {
            return nil
        }
        
        guard let venue_zip = json["custom_fields"]["venue_zip"][0].string else
        {
            return nil
        }
        
        guard let venue_slug = json["slug"].string else
        {
            return nil
        }
        
        guard let venue_title = json["title"].string else
        {
            return nil
        }
        
        let encodedVenueTitle = venue_title.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        
        if let attributedString = try? NSAttributedString(data: encodedVenueTitle, options: attributedOptions, documentAttributes: nil)
        {
            self.title = attributedString.string
        }
        else
        {
            return nil
        }
        
        self.venueId = venue_slug
        self.address = venue_street
        self.city = venue_city
        self.state = venue_state
        self.zip = venue_zip
    }
 
    var uniqueId: String
    {
        get
        {
            return venueId
        }
    }
    
    static func getVenues(fileName: String, completionHandler: (Result<[Venue], NSError>) -> Void)
    {
        Alamofire.request(.GET, Venue.endpoint).getPostsReponseArray(fileName) { response in
            completionHandler(response.result)
        }
    }
}