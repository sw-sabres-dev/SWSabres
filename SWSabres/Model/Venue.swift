//
//  Venue.swift
//  SWSabres
//
//  Created by Mark Johnson on 11/2/15.
//  Copyright © 2015 swdev.net. All rights reserved.
//

import Foundation
import SwiftyJSON
import os.log

struct Venue: ResponseJSONObjectSerializable, UniqueObject
{
    static let endpoint: String = "https://southwakesabres.org/wp-json/wp/v2/mstw_ss_venue"
    
    let venueId: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let title: String
    let modified: Date
    
    init?(coder aDecoder: NSCoder)
    {
        guard let venueId = aDecoder.decodeObject(forKey: "venueId") as? String else
        {
            return nil
        }
        self.venueId = venueId
        
        guard let address = aDecoder.decodeObject(forKey: "address") as? String else
        {
            return nil
        }
        self.address = address
        
        guard let city = aDecoder.decodeObject(forKey: "city") as? String else
        {
            return nil
        }
        self.city = city
        
        guard let state = aDecoder.decodeObject(forKey: "state") as? String else
        {
            return nil
        }
        self.state = state
        
        guard let zip = aDecoder.decodeObject(forKey: "zip") as? String else
        {
            return nil
        }
        self.zip = zip
        
        guard let title = aDecoder.decodeObject(forKey: "title") as? String else
        {
            return nil
        }
        self.title = title
        
        guard let decodedModified: Date = aDecoder.decodeObject(forKey: "modified") as? Date else
        {
            return nil
        }
        self.modified = decodedModified
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(venueId, forKey: "venueId")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(state, forKey: "state")
        aCoder.encode(zip, forKey: "zip")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(modified, forKey: "modified")
    }
    
    init?(json: SwiftyJSON.JSON)
    {
        guard let venue_street = json["custom_fields"]["venue_street"].string else
        {
            return nil
        }
        
        guard let venue_city = json["custom_fields"]["venue_city"].string else
        {
            return nil
        }
        
        guard let venue_state = json["custom_fields"]["venue_state"].string else
        {
            return nil
        }
        
        guard let venue_zip = json["custom_fields"]["venue_zip"].string else
        {
            return nil
        }
        
        guard let venue_slug = json["slug"].string else
        {
            return nil
        }
        
        guard let venue_title = json["title"]["rendered"].string else
        {
            return nil
        }
        
        guard let venue_modified = json["modified"].string else // 2015-11-01 00:40:53
        {
            return nil
        }
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss"
        
        guard let parsedModified: Date = dateFormatter.date(from: venue_modified) else
        {
            return nil
        }
        
        self.modified = parsedModified
        
        guard let encodedVenueTitle = venue_title.data(using: String.Encoding.utf8) else
        {
            return nil
        }

        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
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
        
        os_log("Loaded venue: %@", venueId)
    }
 
    var uniqueId: String
    {
        get
        {
            return venueId
        }
    }
    
    static func getVenues() async -> [Venue]? {
        return await Venue.getObjects(Venue.endpoint)
    }
    
    @objc(_TtCV8SWSabres5Venue6Helper)class Helper: NSObject, NSCoding
    {
        var venue: Venue?
        
        init(venue: Venue)
        {
            self.venue = venue
        }
        
        required init(coder aDecoder: NSCoder)
        {
            venue = Venue(coder: aDecoder)
        }
        
        func encode(with aCoder: NSCoder)
        {
            venue?.encodeWithCoder(aCoder)
        }
    }
}
