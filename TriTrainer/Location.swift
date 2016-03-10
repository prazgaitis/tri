//
//  Location.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/27/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import Foundation
import CoreData

class Location {
    
    var timestamp: NSDate
    var latitude: Double
    var longitude: Double
    var activity: Activity
    
    init(timestamp: NSDate, latitude: Double, longitude: Double, activity: Activity) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.activity = activity
    }
    
    convenience init() {
        self.init(timestamp: NSDate(),latitude: 100.00, longitude: 100.00, activity: Activity())
    }
}