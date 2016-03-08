//
//  Model.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/29/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

let GPSActivityType = "GPSActivity"

protocol ModelDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

class Model {
    
    class func sharedInstance() -> Model {
        return modelSingletonGlobal
    }
    
    var delegate: ModelDelegate?
    
    var items = [GPSActivity]()
    let userInfo: UserInfo
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        userInfo = UserInfo(container: container)
    }
    
    
    func refresh() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "GPSActivity", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "Timestamp", ascending: false)]
        //print("query: \(query)")
        
        
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    print("error loading: \(error)")
                }
            } else {
                //error is nil - all good
                
                //data is up to date
                NewActivityViewController.dirty = false
                
                self.items.removeAll(keepCapacity: true)
                for record in results! {
                    let distance = record.objectForKey("Distance") as? Double
                    let duration = record.objectForKey("Duration") as? Double
                    let timestamp = record.objectForKey("Timestamp") as? NSDate
                    let locations = record.objectForKey("Locations") as? [CLLocation]
                    let activityType = record.objectForKey("ActivityType") as? String
                    let username = record.objectForKey("Username") as? String
                    
                    let activity = GPSActivity(record: record , database:self.publicDB, duration: duration!, distance: distance!, timestamp: timestamp!, locations: locations!, activityType: activityType!, username: username!)

                    self.items.append(activity)
                    
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    print("")
                }
            }
        }
    }
    
    func getContacts() {
        print("calling getContacts()")
        let container: CKContainer = CKContainer.defaultContainer()
        let discoverContacts: (([CKDiscoveredUserInfo]?, NSError?) -> Void) = { (contacts: [CKDiscoveredUserInfo]?, error: NSError?) -> Void  in
            print("we got here")
            if let contacts = contacts {
                print("contacts count: \(contacts.count)")
                for contact in contacts {
                    print(contact)
                }
            } else {
                print("contacts != contacts")
            }
        }
        container.discoverAllContactUserInfosWithCompletionHandler(discoverContacts)
    }
    
    func showOnlyMyActivities() {
        
        let container: CKContainer = CKContainer.defaultContainer()
        let completionHandler: (CKRecordID?, NSError?) -> Void = { (userRecordID: CKRecordID?, error: NSError?) in
            if let userRecordID = userRecordID {
                let predicate = NSPredicate(format: "creatorUserRecordID == %@", userRecordID)
                let query = CKQuery(recordType: "GPSActivity", predicate: predicate)
                query.sortDescriptors = [NSSortDescriptor(key: "Timestamp", ascending: false)]
                container.publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
                    if error != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.errorUpdating(error!)
                            print("error loading: \(error)")
                        }
                    } else {
                        //error is nil - all good
                        
                        //data is up to date
                        NewActivityViewController.dirty = false
                        
                        self.items.removeAll(keepCapacity: true)
                        for record in results! {
                            let distance = record.objectForKey("Distance") as? Double
                            let duration = record.objectForKey("Duration") as? Double
                            let timestamp = record.objectForKey("Timestamp") as? NSDate
                            let locations = record.objectForKey("Locations") as? [CLLocation]
                            let activityType = record.objectForKey("ActivityType") as? String
                            let username = record.objectForKey("Username") as? String
                            
                            let activity = GPSActivity(record: record , database:self.publicDB, duration: duration!, distance: distance!, timestamp: timestamp!, locations: locations!, activityType: activityType!, username: username!)
                            
                            self.items.append(activity)
                            
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.modelUpdated()
                            print("")
                        }
                    }
                }
            }
        }
        //// Returns the user record ID associated with the current user.
        container.fetchUserRecordIDWithCompletionHandler(completionHandler)
    }
    
}

let modelSingletonGlobal = Model()