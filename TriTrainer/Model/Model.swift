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
import UIKit

let ActivityType = "Activity"

protocol ModelDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

class Model {
    
    class func sharedInstance() -> Model {
        return modelSingletonGlobal
    }
    
    //delegates
    var delegate: ModelDelegate?
    
    //current user's details from CK
    var currentLoggedInUser: String?
    var currentLoggedInUserID: String?
    var friendsCount: Int?
    var friendsList: [[String]?]?
    
    //current user's friends ID's
    var currentUsersFriends = [String]()
    
    //Cloudkit DB stuff
    var allActivities = [Activity]()
    var myActivities = [Activity]()
    let userInfo: UserInfo
    var creatorsOfItems = [String]()
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    // totals
    // cu = currentUser
    // f = myFriends
    
    var cuTotalRunDistance: Double = 0.0
    var cuTotalSwimDistance: Double = 0.0
    var cuTotalBikeDistance: Double = 0.0
    
    var fTotalRunDistance: Double = 0.0
    var fTotalSwimDistance: Double = 0.0
    var fTotalBikeDistance: Double = 0.0
    
    //dates
    var startOfWeekAtMidnight = NSDate?()
    
    //activities by current week
    var cuAllActivitiesThisWeek = [Activity]()
    var cuAllRunsThisWeek = [Activity]()
    var cuAllRidesThisWeek = [Activity]()
    var cuAllSwimsThisWeek = [Activity]()
    
    //all friends' activities this week
    var fAllActivitiesThisWeek = [Activity]()
    var fAllRunsThisWeek = [Activity]()
    var fAllRidesThisWeek = [Activity]()
    var fAllSwimsThisWeek = [Activity]()
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        userInfo = UserInfo(container: container)
    }
    
    func getPermission(){
        
        //show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let container: CKContainer = CKContainer.defaultContainer()
        
        container.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability,
            completionHandler: {
                applicationPermissionStatus, error in
                if (applicationPermissionStatus == CKApplicationPermissionStatus.Granted) {
                    print("-- Permission to access contacts has been granted -- ")
                    print("+ Function call: getUserInfo() within getPermission() in Model.swift (line 82)")
                    self.getUserInfo()
                } else {
                    print("-- Permission to access contacts not granted --")
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.showMessage("Error: \(error)")
                    self.postData("error: \(error)", field2: "error in getPermission() in model.swift", field3: "0")
                }
                //hide network indicator
                //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    
    //function to post error data to Google docs
    func postData(field1: String, field2: String, field3: String) {
        
        let data1 = field1.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let data2 = field2.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let data3 = field3.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        print(data1!)
        print(data2!)
        print(data3!)
        
        let url: NSURL = NSURL(string: "https://docs.google.com/forms/d/1-T-bHj1sjJp6Df1nwYXYDANMibfyZsKGvR3-OF6XX6k/formResponse?ifq&entry.276372852=\(data1!)&entry.1434010333=\(data2!)&entry.2064025692=\(data3!)&submit=Submit")!
        
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.showMessage("Error: \(error)")
                return
            }
            
            //let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //prints the webpage html
            //print("datastring: \(dataString)")
            
        }
        task.resume()
    }

    
    
    func refresh() {
        
        //show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // TODO: search by my friends only
        // currently searches for all app users
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Activity", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "Timestamp", ascending: false)]
        
        
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            //if error:
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.showMessage("Error: \(error)")
                    self.postData("error: \(error)", field2: "error in refresh() in model.swift", field3: "0")
                    print("error loading: \(error)")
                }
            //else success:
            } else {
                //data is up to date
                NewActivityViewController.dirty = false
                
                //remove all items from the items array
                self.allActivities.removeAll(keepCapacity: true)
                
                //return all resuts
                print("-- All App Users' Activity --")
                
                //if we know the current user's ID
                if let currentUserID = self.currentLoggedInUserID {
                    
                    //for each record in the results, create an Activity object and add it to the array
                    for record in results! {
                        
                        //get user who created the record
                        if let creator = record.creatorUserRecordID {
                            
                            if currentUserID == record.objectForKey("CreatorID") as? String {
                                print("Creator is: (current logged in User)")
                            } else {
                                print("Creator is: \(creator.recordName)", terminator: "")
                                
                                //check if person is friend
                                if self.currentUsersFriends.contains(creator.recordName) {
                                    print(" - Friend: 👍🏼")
                                } else {
                                    print(" Not a friend")
                                }
                            }
                        }
                        
                        let distance = record.objectForKey("Distance") as? Double
                        let duration = record.objectForKey("Duration") as? Double
                        let timestamp = record.objectForKey("Timestamp") as? NSDate
                        let locations = record.objectForKey("Locations") as? [CLLocation]
                        let activityType = record.objectForKey("ActivityType") as? String
                        let creatorName = record.objectForKey("CreatorName") as? String
                        let creatorID = record.objectForKey("CreatorID") as? String
                        
                        let activity = Activity(record: record , database:self.publicDB, duration: duration!, distance: distance!, timestamp: timestamp!, locations: locations, activityType: activityType!, creatorName: creatorName!, creatorID: creatorID!)
                        
                        //add the newly created object to the array
                        self.allActivities.append(activity)
                        
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    print("model updated after calling refresh() in Model.swift (line 142)")
                    
                    for creator in self.creatorsOfItems {
                        print("Creators name: \(creator)")
                    }
                }
            }
            //hide network indicator
            //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func getContacts() {
        
        //show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        print("calling getContacts()")
        let container: CKContainer = CKContainer.defaultContainer()
        let discoverContacts: (([CKDiscoveredUserInfo]?, NSError?) -> Void) = { (contacts: [CKDiscoveredUserInfo]?, error: NSError?) -> Void  in
            if let contacts = contacts {
                print("Count of contacts that also use Tri: \(contacts.count)")
                for contact in contacts {
                    print(contact)
                }
            } else {
                print("contacts != contacts")
            }
            //hide network indicator
            //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        container.discoverAllContactUserInfosWithCompletionHandler(discoverContacts)
    }
    
    func getUserInfo(){
        let container: CKContainer = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler({recordID, error in
            if let _ = error {
                print("failed to get record ID")
            } else {
                print("\n\nCurrent User\n-----------\nRecord ID: \(recordID!.recordName)")
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
        print("++ Calling function contactsPlease() in Model.swift (~line 214)")

        //show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let container: CKContainer = CKContainer.defaultContainer()
        container.discoverAllContactUserInfosWithCompletionHandler({users, error in
            
            if let err = error {
                print("Function contactsPlease() --> contact discovery failed \(err)")
                
                //remove the splash screen if no data is loaded
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.removeSplashView()
                    print("Cloudkit error: \(err)")
                    appDelegate.showMessage("Error: \(err)")
                    self.postData("error: \(err)", field2: "error in contactsPlease() in model.swift", field3: "0")
                }
            } else {
                if let users = users {
                    print("\n-- successfully discovered \(users.count) other contacts using the app --")
                    self.friendsCount = users.count
                    

                    print("\nList of Friends using Tri")
                    print("---------------------------------")
                    
                    for userInfo in users {
                        let userRecordID = userInfo.userRecordID
                        if let info = userInfo.displayContact {
                            self.friendsList?.append(["\(info.givenName) \(info.givenName)", (userRecordID?.recordName)!])
                            self.currentUsersFriends.append((userRecordID?.recordName)!)
                        }
                        if let friend = userInfo.displayContact {
                            print("- \(friend.givenName) \(friend.familyName)")
                        }
                    }
                    print("\n\n")
                    
                    //remove the splash screen once data is loaded
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.removeSplashView()
                    }

                    
                    //TODO: Update Current User's Friends List
                }
            }
            //hide network indicator
            //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    func whatsMyName(userRecordID: CKRecordID) {
        let container: CKContainer = CKContainer.defaultContainer()
        container.discoverUserInfoWithUserRecordID(userRecordID, completionHandler: ({user, error in
            if let err = error {
                print("There was an error: \(err)")

                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.showMessage("Error: \(err)")
                self.postData("error: \(err)", field2: "error in whatsMyName() in model.swift", field3: "0")
            } else {
                if let user = user {
                    if let userContactInfo = user.displayContact {
                        print("Name: \(userContactInfo.givenName) \(userContactInfo.familyName)")
                        self.currentLoggedInUser = "\(userContactInfo.givenName) \(userContactInfo.familyName)"
                    }
                }
            }
        }))
    }
    
//    func nameFromUserRecord(userRecordID: CKRecordID) {
//        let container: CKContainer = CKContainer.defaultContainer()
//        container.discoverUserInfoWithUserRecordID(userRecordID, completionHandler: ({user, error in
//            if let err = error {
//                print("There was an error: \(err)")
//            } else {
//                if let user = user {
//                    if let userContactInfo = user.displayContact {
//                         self.creatorsOfItems.append("\(userContactInfo.givenName) \(userContactInfo.familyName)")
//                    }
//                }
//            }
//        }))
//    }
    
    //function to calculate the day of the week
    
    func getDayOfWeek(today: NSDate)->Int? {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: today)
        let weekDay = myComponents.weekday
        return weekDay
    }
    
    // query cloudkit for activities by the current logged in user
    
    func showOnlyMyActivities() {
        
        //show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //reset lifetime totals
        self.cuTotalRunDistance = 0.0
        self.cuTotalBikeDistance = 0.0
        self.cuTotalSwimDistance = 0.0
    
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
                            
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.showMessage("Error: \(error)")
                            self.postData("error: \(error)", field2: "error in showOnlyMyActivites() in model.swift", field3: "0")
                        }
                    } else {
                        //error is nil - all good
                        
                        //data is up to date
                        NewActivityViewController.dirty = false
                        
                        self.myActivities.removeAll(keepCapacity: true)
                        
                        //iterate over all results
                        for record in results! {
                            let distance = record.objectForKey("Distance") as? Double
                            let duration = record.objectForKey("Duration") as? Double
                            let timestamp = record.objectForKey("Timestamp") as? NSDate
                            let locations = record.objectForKey("Locations") as? [CLLocation]
                            let activityType = record.objectForKey("ActivityType") as? String
                            let creatorName = record.objectForKey("CreatorName") as? String
                            let creatorID = record.objectForKey("CreatorID") as? String
                            
                            let activity = Activity(record: record , database:self.publicDB, duration: duration!, distance: distance!, timestamp: timestamp!, locations: locations, activityType: activityType!, creatorName: creatorName!, creatorID: creatorID!)
                            
                            self.myActivities.append(activity)
                            
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.modelUpdated()
                            self.calculateActivityDates()
                        }
                    }
                }
            }
            
            //hide network indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        //// Returns the user record ID associated with the current user.
        container.fetchUserRecordIDWithCompletionHandler(completionHandler)
    }
    
    //calculate all of the workouts for this week and
    
    func calculateActivityDates() {
        
        //figure out the date
        let cal = NSCalendar.currentCalendar()
        
        //get current day of week
        if var dayOfWeek = self.getDayOfWeek(NSDate()) {
            
            print("\nToday is \(NSDate()), the \(dayOfWeek) day of the week ")
            
            //subtract 1 because we'll be subtracting from yesterday
            dayOfWeek = dayOfWeek - 1
            
            let components = NSDateComponents()
            components.day = -dayOfWeek
            
            let startOfWeek = cal.dateByAddingComponents(
                components,
                toDate: NSDate(),
                options: [])!
            
            self.startOfWeekAtMidnight = cal.startOfDayForDate(startOfWeek)
        }
        
        
        self.cuTotalRunDistance = 0.0
        
        for activity in myActivities {
            // user lifetime totals
            if activity.activityType == "run" {
                self.cuTotalRunDistance += activity.distance
            } else if activity.activityType == "bike" {
                self.cuTotalBikeDistance += activity.distance
            } else {
                self.cuTotalSwimDistance += activity.distance
            }
            
            // totals by date
            
            //if activity is not before the first day of the current week at midnight
            //if .NSOrderedDescending, then the activity date is AFTER the start of the current week at midnight
            
            // could probably clean this up with extensions
            // http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift
            
            if activity.timestamp.compare(self.startOfWeekAtMidnight!) == NSComparisonResult.OrderedDescending {
                self.cuAllActivitiesThisWeek.append(activity)
            }
        }
        
        for activity in cuAllActivitiesThisWeek {
            if activity.activityType == "run" {
                self.cuAllRunsThisWeek.append(activity)
            } else if activity.activityType == "bike" {
                self.cuAllRidesThisWeek.append(activity)
            } else {
                self.cuAllSwimsThisWeek.append(activity)
            }
        }
        
        
        // print totals
        // var items contains ALL-TIME data
        
        print("\n-- Current User lifetime data (Activities: \(self.myActivities.count)) -- ")
        print("Lifetime run distance: \(self.myActivities.filter({$0.activityType == "run"}).reduce(0){$0 + $1.distance})")
        print("Lifetime bike distance: \(self.myActivities.filter({$0.activityType == "bike"}).reduce(0){$0 + $1.distance})")
        print("Lifetime swim distance: \(self.myActivities.filter({$0.activityType == "swim"}).reduce(0){$0 + $1.distance})")
        
        print("\n -- User Data this week (Activities: \(self.cuAllActivitiesThisWeek.count)) -- ")
        
        //print("Runs:  \(self.cuAllRunsThisWeek.count), Distance: \(self.cuAllRunsThisWeek.reduce(0){ $0 + $1.distance })")
        
        
        // calculate run totals and count using crazy closures
        
        let runCount = self.myActivities
            .filter({$0.activityType == "run"})
            .filter({$0.timestamp.compare(self.startOfWeekAtMidnight!) == NSComparisonResult.OrderedDescending})
            .count
        
        let runDistance = self.myActivities.filter({$0.activityType == "run"}).filter({$0.timestamp.compare(self.startOfWeekAtMidnight!) == NSComparisonResult.OrderedDescending}).reduce(0){$0 + $1.distance}
        
        print("Runs:  \(runCount), Distance: \(runDistance)")
        print("Rides: \(self.cuAllRidesThisWeek.count), Distance: \(self.cuAllRidesThisWeek.reduce(0) {$0 + $1.distance })")
        print("Swims: \(self.cuAllSwimsThisWeek.count), Distance: \(self.cuAllSwimsThisWeek.reduce(0){$0 + $1.distance})")
    }
}

let modelSingletonGlobal = Model()