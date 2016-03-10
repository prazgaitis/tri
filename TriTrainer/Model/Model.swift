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

let ActivityType = "Activity"

protocol ModelDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

class Model {
    
    class func sharedInstance() -> Model {
        return modelSingletonGlobal
    }
    
    var delegate: ModelDelegate?
    
    //current user's details from CK
    var currentLoggedInUser: String?
    var currentLoggedInUserID: String?
    var friendsCount: Int?
    var friendsList: [[String]?]?
    
    var items = [Activity]()
    let userInfo: UserInfo
    var creatorsOfItems = [String]()
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        userInfo = UserInfo(container: container)
    }
    
    func getPermission(){
        let container: CKContainer = CKContainer.defaultContainer()
        container.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability,
            completionHandler: {
                applicationPermissionStatus, error in
                if (applicationPermissionStatus == CKApplicationPermissionStatus.Granted) {
                    print("we're good")
                    self.getUserInfo()
                } else {
                    print("no permission granted")
                }
        })
    }
    
    
    func refresh() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Activity", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "Timestamp", ascending: false)]
        
        
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
                    
                    //get user who created the record
                    if let creator = record.creatorUserRecordID {
                        print("Creator is: \(creator)")
                    }
                    
                    let distance = record.objectForKey("Distance") as? Double
                    let duration = record.objectForKey("Duration") as? Double
                    let timestamp = record.objectForKey("Timestamp") as? NSDate
                    let locations = record.objectForKey("Locations") as? [CLLocation]
                    let activityType = record.objectForKey("ActivityType") as? String
                    let creatorName = record.objectForKey("CreatorName") as? String
                    let creatorID = record.objectForKey("CreatorID") as? String
                    
                    let activity = Activity(record: record , database:self.publicDB, duration: duration!, distance: distance!, timestamp: timestamp!, locations: locations, activityType: activityType!, creatorName: creatorName!, creatorID: creatorID!)

                    self.items.append(activity)
                    
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    print("model updated!")
                    for creator in self.creatorsOfItems {
                        print("Creators name: \(creator)")
                    }
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
    
    func getUserInfo(){
        let container: CKContainer = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler({recordID, error in
            if let err = error {
                print("failed to get record ID")
            } else {
                print("Record ID is: \(recordID!.recordName)")
                self.currentLoggedInUserID = recordID!.recordName
                if let user = recordID {
                    self.whatsMyName(user)
                } else {
                    print("record ID is nil")
                }
            }
        })
    }
    
    func contactsPlease() {
        let container: CKContainer = CKContainer.defaultContainer()
        container.discoverAllContactUserInfosWithCompletionHandler({users, error in
            
            if let err = error {
                print("contact discovery failed \(err)")
            } else {
                print("user discovery did not fail")
                
                if let users = users {
                    print("users count: \(users.count)")
                    self.friendsCount = users.count
                    
                    for userInfo in users {
                        let userRecordID = userInfo.userRecordID
                        if let info = userInfo.displayContact {
                            self.friendsList?.append(["\(info.givenName) \(info.givenName)", (userRecordID?.recordName)!])
                        }
                        print("First Name = \(userInfo.displayContact?.givenName)")
                    }
                }
            }
            })
    }
    
    func whatsMyName(userRecordID: CKRecordID) {
        let container: CKContainer = CKContainer.defaultContainer()
        container.discoverUserInfoWithUserRecordID(userRecordID, completionHandler: ({user, error in
            if let err = error {
                print("There was an error: \(err)")
            } else {
                if let user = user {
                    if let userContactInfo = user.displayContact {
                        print("MY NAME IS: \(userContactInfo.givenName) \(userContactInfo.familyName)")
                        self.currentLoggedInUser = "\(userContactInfo.givenName) \(userContactInfo.familyName)"
                    }
                }
            }
        }))
    }
    
    func nameFromUserRecord(userRecordID: CKRecordID) {
        let container: CKContainer = CKContainer.defaultContainer()
        container.discoverUserInfoWithUserRecordID(userRecordID, completionHandler: ({user, error in
            if let err = error {
                print("There was an error: \(err)")
            } else {
                if let user = user {
                    if let userContactInfo = user.displayContact {
                         self.creatorsOfItems.append("\(userContactInfo.givenName) \(userContactInfo.familyName)")
                    }
                }
            }
        }))
    }
    
    func showOnlyMyActivities() {
        
        let container: CKContainer = CKContainer.defaultContainer()
        let completionHandler: (CKRecordID?, NSError?) -> Void = { (userRecordID: CKRecordID?, error: NSError?) in
            if let userRecordID = userRecordID {
                let predicate = NSPredicate(format: "creatorUserRecordID == %@", userRecordID)
                let query = CKQuery(recordType: "Activity", predicate: predicate)
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
                            let creatorName = record.objectForKey("CreatorName") as? String
                            let creatorID = record.objectForKey("CreatorID") as? String
                            
                            let activity = Activity(record: record , database:self.publicDB, duration: duration!, distance: distance!, timestamp: timestamp!, locations: locations, activityType: activityType!, creatorName: creatorName!, creatorID: creatorID!)
                            
                            self.items.append(activity)
                            
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.modelUpdated()
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