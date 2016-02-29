//
//  Swim.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/27/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

//import Foundation
//import CoreData
//
//class Swim: NSManagedObject {
//    
//    @NSManaged var timestamp: NSDate
//    @NSManaged var duration: NSNumber
//    @NSManaged var distance: NSNumber
//    
//}


class Swim {
    var distance: Double
    var duration: Double
    
    init(distance: Double, duration: Double) {
        self.distance = distance
        self.duration = duration
    }
}