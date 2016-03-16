//
//  GPSActivity.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/27/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import Foundation
import CloudKit


class Activity: NSObject {
    
    enum ActivityType {
        case Bike, Run, Swim
    }
    
    var duration: Double
    var distance: Double
    var timestamp: NSDate
    var locations: [CLLocation]?
    var activityType: String
    var creatorName: String
    var creatorID: String
    
    init(duration: Double, distance: Double, timestamp: NSDate, locations: [CLLocation]?, activityType: String, creatorName: String, creatorID: String) {
        self.timestamp = timestamp
        self.distance = distance
        self.duration = duration
        self.locations = locations
        self.activityType = activityType
        self.creatorName = creatorName
        self.creatorID = creatorID
    }
    
    convenience override init() {
        let locat = [CLLocation]()
        self.init(duration: 0.0, distance: 0.0, timestamp: NSDate(), locations: locat, activityType: "run", creatorName: "Joe Shmoe", creatorID: "insertRandomStringHere")
    }
    
    //--- cloudkit stuff
    
    var record: CKRecord!
    weak var database: CKDatabase!
    
    init(record: CKRecord, database: CKDatabase, duration: Double, distance: Double, timestamp: NSDate, locations: [CLLocation]?, activityType: String, creatorName: String, creatorID: String) {
        self.record = record
        self.database = database
        self.timestamp = timestamp
        self.distance = distance
        self.duration = duration
        self.locations = locations
        self.activityType = record.objectForKey("ActivityType") as! String
        self.creatorName = record.objectForKey("CreatorName") as! String
        self.creatorID = record.objectForKey("CreatorID") as! String
    }
    
}