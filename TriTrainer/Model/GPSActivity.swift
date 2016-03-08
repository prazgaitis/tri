//
//  GPSActivity.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/27/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import Foundation
import CoreData

//class GPSActivity: NSManagedObject {
//    
//    @NSManaged var duration: NSNumber
//    @NSManaged var distance: NSNumber
//    @NSManaged var timestamp: NSDate
//    @NSManaged var locations: NSMutableOrderedSet
//    
//}

import CloudKit


class GPSActivity: NSObject {
    
    enum ActivityType {
        case Bike, Run
    }
    
    var duration: Double
    var distance: Double
    var timestamp: NSDate
    var locations: [CLLocation]
    var activityType: String
    var username: String
    
    init(duration: Double, distance: Double, timestamp: NSDate, locations: [CLLocation], activityType: String, username: String) {
        self.timestamp = timestamp
        self.distance = distance
        self.duration = duration
        self.locations = locations
        self.activityType = activityType
        self.username = username
    }
    
    convenience override init() {
        let locat = [CLLocation]()
        self.init(duration: 10.0, distance: 10.0, timestamp: NSDate(), locations: locat, activityType: "run", username: "username")
    }
    
    //--- cloudkit stuff
    
    var record: CKRecord!
    weak var database: CKDatabase!
    
    init(record : CKRecord, database: CKDatabase, duration: Double, distance: Double, timestamp: NSDate, locations: [CLLocation], activityType: String, username: String) {
        self.record = record
        self.database = database
        
        self.timestamp = timestamp
        self.distance = distance
        self.duration = duration
        self.locations = locations
        self.username = username

        
        self.activityType = record.objectForKey("ActivityType") as! String
    }
    
}