//
//  NewActivityViewController.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/22/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import CloudKit


class NewActivityViewController: UIViewController, UIGestureRecognizerDelegate, ModelDelegate {
    
    //whether we have new data in Cloudkit that needs to be pushed to the view
    // if dirty, then there is new data that needs to be shown
    static var dirty = true
    
    //model
    let model: Model = Model.sharedInstance()
    
    //AppDelegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //MARK: Properties
    var activity: Activity?
    var activityType: String?
    var seconds = 0.0
    var distance = 0.0
    
    //MARK: UI
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    /*

    From Apple Docs:
    
    A lazy stored property is a property whose initial value is not calculated until the first time it is used. You indicate a lazy stored property by writing the lazy modifier before its declaration.
    
    */
    
    lazy var locationManager: CLLocationManager = {
        var CLM = CLLocationManager()
        CLM.delegate = self
        CLM.desiredAccuracy = kCLLocationAccuracyBest
        CLM.activityType = .Fitness
        
        //How often to update events
        CLM.distanceFilter = 5.0
        return CLM
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    //MARK: View LifeCycle Methods
    
    var uname: CKReference?
    
    override func viewWillAppear(animated: Bool) {
                
        startButton.backgroundColor = Colors().mainGreen
        resumeButton.backgroundColor = Colors().mainGreen
        pauseButton.backgroundColor = Colors().mainMagenta
        finishButton.backgroundColor = Colors().mainBlue
        
        resumeButton.hidden = true
        pauseButton.hidden = true
        finishButton.hidden = true
        
        locationManager.requestAlwaysAuthorization()
        //locationManager.requestWhenInUseAuthorization()
    }
    
    // stop timer if user navigates away from View
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //stop timer if view disappears
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("TYPE: \(activityType)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    //MARK: CLLocationManager stuff
    
    func fireEachSecond(timer: NSTimer) {
        seconds++
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        
        // --------------
        //THIS IS A HACK JOB: FIX IT!
        let totalSeconds = secondsQuantity.doubleValueForUnit(HKUnit.secondUnit())
        let numSeconds = totalSeconds % 60
        let numMinutes = floor((totalSeconds / 60) % 60)
        let numHours = floor(totalSeconds / 3600)
        
        var secondsString = String(format: "%.0f", numSeconds)
        var minutesString = String(format: "%.0f", numMinutes)
        var hoursString = String(format: "%.0f", numHours)
        
        
        
        if (Int(secondsString) < 10 ){
            secondsString = "0\(secondsString)"
        }
        if (Int(minutesString) < 10 ){
            minutesString = "0\(minutesString)"
        }
        if (Int(hoursString) < 10 ){
            hoursString = "0\(hoursString)"
        }
        
        
        let finalString = "\(hoursString):\(minutesString):\(secondsString)"
        totalTimeLabel.text = finalString
        
        // --------------
        
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        let totalDistanceInMeters = distanceQuantity.doubleValueForUnit(HKUnit.meterUnit())
        let distanceInMiles = (totalDistanceInMeters / 1609.34)
        distanceLabel.text = String(format: "%0.2f mi", distanceInMiles)
        
        //Calculate Average pace
        // TODO: FIX PACE
        let metersInMile = 1609.34
        let minutesPerMile = (seconds/60.0) / (distance/metersInMile)
        let mins = minutesPerMile
        let secs = (minutesPerMile % 1) * 60.0
        
        let paceString = String(format: "%2.f:%02.f /mi", mins, secs)
        
        print("Pace: \(distance) || \(seconds) -- > m/s = \(distance/seconds)")
        
        //if pace is NaNm 
        if secs.isNaN {
            paceLabel.text = "0:00 min/mi"
        } else {
            paceLabel.text = paceString
        }
        
        //print(locations.last?.coordinate.latitude)
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: Start/Stop/Pause
    
    @IBAction func startRecording(sender: AnyObject) {
        
        //set currently tracking workout to TRUE
        print("\n\nSetting currentlyTrackingWorkout = TRUE\n\n")
        self.appDelegate.currentlyTrackingWorkout = true
        
        
        //start with a fresh data
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        
        //update UI
        startButton.hidden = true
        pauseButton.hidden = false
        
        //start timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "fireEachSecond:",
            userInfo: nil,
            repeats: true)
        startUpdatingLocation()
    }
    
    @IBAction func pauseRecording(sender: AnyObject) {
        pauseButton.hidden = true
        
        //pause recording
        stopUpdatingLocation()
        timer.invalidate()
        
        //update UI
        pauseButton.hidden = true
        resumeButton.hidden = false
        finishButton.hidden = false
    }
    
    @IBAction func resumeRecording(sender: AnyObject) {
        
        //resume recording
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "fireEachSecond:",
            userInfo: nil,
            repeats: true)
        startUpdatingLocation()
        
        //update UI
        resumeButton.hidden = true
        finishButton.hidden = true
        pauseButton.hidden = false
    }
    

    @IBAction func stopRecording(sender: AnyObject) {
        
        print("Stopping!")
        timer.invalidate()
        saveActivity()
        
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
    }
    
    @IBAction func cancelActivity(sender: AnyObject) {
        
        //throw alert if no value was entered
        let alert = UIAlertController(title: "You sure?", message: "This workout will not be saved.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Resume", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel Workout", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            
            //cancel current workout
            print("\n\nSetting currentlyTrackingWorkout = FALSE\n\n")
            self.appDelegate.currentlyTrackingWorkout = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func saveActivity() {
        
        //check to make sure we know who is logging the activity
        if (model.currentLoggedInUser == nil) && (model.currentLoggedInUserID == nil)  {
            print("CAN'T GET USERS DATA")
            return
        }
        
        //save all of the location data
        let savedActivity = Activity(duration: seconds, distance: distance, timestamp: NSDate(), locations: locations, activityType: activityType!, creatorName: model.currentLoggedInUser!, creatorID: model.currentLoggedInUserID!)

        
        print("Saved!\n-----\n\nPoints:")
        
        if savedActivity.locations != nil {
            for point in savedActivity.locations! {
                print("Lat: \(point.coordinate.latitude), Lon: \(point.coordinate.longitude)")
            }
        } else {
            print("there are no locations. This is probably a swim activity type")
        }
        
        
        print("Distance: \(savedActivity.distance)")
        print("Duration (s): \(savedActivity.duration)")
        print("Timestamp: \(savedActivity.timestamp)")
        print("Type: \(savedActivity.activityType)")
        print("User: \(savedActivity.creatorName)")
        
        activity = savedActivity
        
        stopUpdatingLocation()
        
        //save activity to cloudkit
        
        let publicDB = model.publicDB
        
        //create record
        var record : CKRecord!
        record = CKRecord(recordType: "Activity")
        record.setValue(self.seconds, forKey: "Duration")
        record.setValue(self.distance, forKey: "Distance")
        record.setValue(NSDate(), forKey: "Timestamp")
        record.setValue(self.locations, forKey: "Locations")
        record.setValue(self.activityType!, forKey: "ActivityType")
        
        //add users name to object
        if let user = model.currentLoggedInUser {
            record.setValue(user, forKey: "CreatorName")
        } else {
            record.setValue("First Last", forKey: "CreatorName")
        }
        
        //add users unique ID name to object
        if let user = model.currentLoggedInUserID {
            record.setValue(user, forKey: "CreatorID")
        } else {
            record.setValue("thisIDisNil", forKey: "CreatorID")
        }

        
        //save record
        publicDB.saveRecord(record) { savedRecord, error in
            if error != nil {
                print("Error: \(error)")
            } else {
                //set flag to show we have new data to pass to the view
                NewActivityViewController.dirty = true
                print("Saved to cloudkit successfully!")
                
                //cancel current workout
                print("\n\nSetting currentlyTrackingWorkout = FALSE\n\n")
                self.appDelegate.currentlyTrackingWorkout = false
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("postGPSActivity", sender: self)
                })
            }
        }
        
    }
    
    //MARK: Cloudkit Stuff
    func errorUpdating(error: NSError) {
        print(error)
    }
    
    func modelUpdated() {
        print("updated! - from NewActivityVC")
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "postGPSActivity"
        {
            if let destinationVC = segue.destinationViewController as? ActivityDetailVC {
                destinationVC.activity = activity!
                let navController = UINavigationController(rootViewController: destinationVC)
                self.presentViewController(navController, animated: true, completion: nil)
            }
        }
    }
}

//MARK: CLLocationManagerDelegate

extension NewActivityViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //iterate through all locations in array
        for location in locations {
            //if we can determine the accuracy to within 20 meters..
            if (location.horizontalAccuracy < 20) {
                //update the distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                }
                
                //add current location
                self.locations.append(location)
                print("current location -> \(location)")
            }
        }
    }
}
