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
import CoreData
import CloudKit


class NewActivityViewController: UIViewController, UIGestureRecognizerDelegate, ModelDelegate {
    
    //whether we have new data in Cloudkit that needs to be pushed to the view
    // if dirty, then there is new data that needs to be shown
    static var dirty = true
    
    //model
    let model: Model = Model.sharedInstance()
    
    //MARK: Properties
    var gpsactivity: GPSActivity!
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
        CLM.distanceFilter = 10.0
        return CLM
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    //MARK: Activity Selectors

//    @IBOutlet weak var stackView: UIStackView!
//    @IBOutlet weak var selectRun: UIView!
//    @IBOutlet weak var selectSwim: UIView!
//    @IBOutlet weak var selectBike: UIView!
    
    //MARK: View LifeCycle Methods
    
    var uname: CKReference?
    
    override func viewWillAppear(animated: Bool) {
                
        startButton.backgroundColor = UIColor.greenColor()
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        resumeButton.backgroundColor = UIColor.greenColor()
        pauseButton.backgroundColor = UIColor.redColor()
        finishButton.backgroundColor = UIColor.blueColor()
        resumeButton.hidden = true
        pauseButton.hidden = true
        finishButton.hidden = true
        
        
        //timerImage.image = UIImage(named: "timer")
        //timerImage.hidden = true
        
        //CoreData stuff - probably don't need
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //self.managedObjectContext = appDelegate.managedObjectContext
        
        // Hide in-activity views
//        timeElapsedLabel.hidden = true
//        distanceLabel.hidden    = true
//        paceLabel.hidden        = true
//        startButton.hidden      = true
//        pauseButton.hidden      = true
//        stopButton.hidden       = true
        
//        //add tags & Tap Gesture Recognizers to UIViews
//        
//        let views = [selectRun, selectBike, selectSwim]
//        
//        for (index, view) in views.enumerate() {
//            addGesturesToView(view)
//            view.tag = index
//        }
        //will request to use location from user
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
        
        //show in-activity stuff
//        self.timeElapsedLabel.hidden = false
//        self.distanceLabel.hidden    = false
//        self.paceLabel.hidden        = false
//        self.startButton.hidden      = false
//        self.pauseButton.hidden      = false
//        self.stopButton.hidden       = false
//        self.timerImage.hidden       = false
        
        self.activityType = "run"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    //MARK: Gesture Recognizers
//    
//    func selectedActivity(recognizer: UITapGestureRecognizer) {
//        
//        //sender is UITapGestureRecognizer
//        
//        //change background color of selected view
//        if recognizer.state == UIGestureRecognizerState.Ended {
//            recognizer.view!.backgroundColor = UIColor.greenColor()
//        }
//        
//        //check tag to see which was selected
//        switch recognizer.view!.tag {
//        case 0:
//            print("run")
//            activityType = "run"
//        case 1:
//            print("bike")
//            activityType = "bike"
//        case 2:
//            print("swim")
//            //redirect to swim thing
//        default:
//            return
//        }
//        
//        //remove the View
//        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//            self.stackView.center.y = self.stackView.center.y - 600
//            }, completion: { (callback) -> Void in
//                
//                //do something when animation completes
//                //self.stackView.removeFromSuperview()
//                self.stackView.hidden = true
//                
//                //show in-activity stuff
//                self.timeElapsedLabel.hidden = false
//                self.distanceLabel.hidden    = false
//                self.paceLabel.hidden        = false
//                self.startButton.hidden      = false
//                self.pauseButton.hidden      = false
//                self.stopButton.hidden       = false
//                self.timerImage.hidden       = false
//        })
//    }
//    
//    func addGesturesToView(view: UIView) {
//        
//        let tap = UITapGestureRecognizer(target: self, action: "selectedActivity:")
//        tap.delegate = self
//        view.addGestureRecognizer(tap)
//        
//    }
    
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
        
        let paceString = String(format: "%2.f:%02.f min/mi", mins, secs)
        
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
    
    func saveActivity() {
        
        //create activity object to save
        //let savedActivity = NSEntityDescription.insertNewObjectForEntityForName("GPSActivity", inManagedObjectContext: managedObjectContext!) as! GPSActivity
        
        print(NSUserName())
        
        //save all of the location data
        let savedActivity = GPSActivity(duration: seconds, distance: distance, timestamp: NSDate(), locations: locations, activityType: activityType!, username: NSUserName())

        
        print("Saved!\n-----\n\nPoints:")
        
        for point in savedActivity.locations {
            print("Lat: \(point.coordinate.latitude), Lon: \(point.coordinate.longitude)")
        }
        
        print("Distance: \(savedActivity.distance)")
        print("Duration (s): \(savedActivity.duration)")
        print("Timestamp: \(savedActivity.timestamp)")
        print("Type: \(savedActivity.activityType)")
        print("UN: \(savedActivity.username)")
        
        gpsactivity = savedActivity
        
        stopUpdatingLocation()
        
        //save activity to cloudkit
        
        let publicDB = model.publicDB
        
        //create record
        var record : CKRecord!
        record = CKRecord(recordType: "GPSActivity")
        record.setValue(self.seconds, forKey: "Duration")
        record.setValue(self.distance, forKey: "Distance")
        record.setValue(NSDate(), forKey: "Timestamp")
        record.setValue(self.locations, forKey: "Locations")
        record.setValue(self.activityType!, forKey: "ActivityType")
        record.setValue(NSUserName(), forKey: "Username")

        
        
        //get username
        let username = model.userInfo.userID(){
            userID, error in
            if let userRecord = userID {
                let userRef = CKReference(recordID: userRecord,
                    action: .None)
                
                //set record attributes
//                record = CKRecord(recordType: "GPSActivity")
//                record.setValue(self.seconds, forKey: "Duration")
//                record.setValue(self.distance, forKey: "Distance")
//                record.setValue(NSDate(), forKey: "Timestamp")
//                record.setValue(self.locations, forKey: "Locations")
//                record.setValue(self.activityType!, forKey: "ActivityType")
//                record.setValue(NSUserName(), forKey: "Username")
                
            }
        }
        
        
        publicDB.saveRecord(record) { savedRecord, error in
            if error != nil {
                print("Error: \(error)")
            } else {
                //set flag to show we have new data to pass to the view
                NewActivityViewController.dirty = true
                print("Saved to cloudkit successfully!")
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("postWorkout", sender: self)
                    //self.seggit()
                })
            }
        }
        
    }
    
//    func doSegue(){
//        self.performSegueWithIdentifier("postWorkout", sender: self)
//    }
    
    //MARK: Cloudkit Stuff
    func errorUpdating(error: NSError) {
        print(error)
    }
    
    func modelUpdated() {
        print("updated! - from NewActivityVC")
    }
    
    func seggit() {
        let destinationVC = ActivityDetailVC()
        destinationVC.activity = gpsactivity
        
        let navController = UINavigationController(rootViewController: destinationVC)
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        navController.navigationItem.leftBarButtonItem = backButton
        self.presentViewController(navController, animated: true, completion: nil)
        
    }
    
    //segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "postWorkout"
        {
            if let destinationVC = segue.destinationViewController as? ActivityDetailVC {
                destinationVC.activity = gpsactivity!
                
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
