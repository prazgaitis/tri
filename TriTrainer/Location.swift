//
//  Location.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/27/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import Foundation
import CoreData

//class Location: NSManagedObject {
//    
//    @NSManaged var timestamp: NSDate
//    @NSManaged var latitude: NSNumber
//    @NSManaged var longitude: NSNumber
//    @NSManaged var gpsactivity: NSManagedObject
//    
//}

class Location {
    
    var timestamp: NSDate
    var latitude: Double
    var longitude: Double
    var gpsactivity: GPSActivity
    
    init(timestamp: NSDate, latitude: Double, longitude: Double, gpsactivity: GPSActivity) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.gpsactivity = gpsactivity
    }
    
    convenience init() {
        self.init(timestamp: NSDate(),latitude: 100.00, longitude: 100.00, gpsactivity: GPSActivity())
    }
}