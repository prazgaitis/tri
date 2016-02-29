//
//  SecondViewController.swift
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

    // CoreData thing - probably don't need this:
    // var managedObjectContext: NSManagedObjectContext?
    
    let model: Model = Model.sharedInstance()
    
    //MARK: Properties
    var gpsactivity: GPSActivity!
    var activityType: String?
    var seconds = 0.0
    var distance = 0.0
    
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
    
    //MARK: In-Activity Items

    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    //MARK: Activity Selectors

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var selectRun: UIView!
    @IBOutlet weak var selectSwim: UIView!
    @IBOutlet weak var selectBike: UIView!
    
    //MARK: View LifeCycle Methods
    
    override func viewWillAppear(animated: Bool) {

        stackView.layer.borderWidth = 2
        stackView.layer.borderColor = UIColor.blackColor().CGColor
        
        //CoreData stuff - probably don't need
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //self.managedObjectContext = appDelegate.managedObjectContext
        
        // Hide in-activity views
        timeElapsedLabel.hidden = true
        distanceLabel.hidden    = true
        paceLabel.hidden        = true
        startButton.hidden      = true
        pauseButton.hidden      = true
        stopButton.hidden       = true
        
        //add tags & Tap Gesture Recognizers to UIViews
        
        let views = [selectRun, selectBike, selectSwim]
        
        for (index, view) in views.enumerate() {
            addGesturesToView(view)
            view.tag = index
        }
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Gesture Recognizers
    
    func selectedActivity(recognizer: UITapGestureRecognizer) {
        
        //sender is UITapGestureRecognizer
        
        //change background color of selected view
        if recognizer.state == UIGestureRecognizerState.Ended {
            recognizer.view!.backgroundColor = UIColor.greenColor()
        }
        
        //check tag to see which was selected
        switch recognizer.view!.tag {
        case 0:
            print("run")
            activityType = "run"
        case 1:
            print("bike")
            activityType = "bike"
        case 2:
            print("swim")
            //redirect to swim thing
        default:
            return
        }
        
        //remove the View
        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.stackView.center.y = self.stackView.center.y - 600
            }, completion: { (callback) -> Void in
                
                //do something when animation completes
                //self.stackView.removeFromSuperview()
                self.stackView.hidden = true
                
                //show in-activity stuff
                self.timeElapsedLabel.hidden = false
                self.distanceLabel.hidden    = false
                self.paceLabel.hidden        = false
                self.startButton.hidden      = false
                self.pauseButton.hidden      = false
                self.stopButton.hidden       = false
        })
    }
    
    func addGesturesToView(view: UIView) {
        
        let tap = UITapGestureRecognizer(target: self, action: "selectedActivity:")
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
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
        timeElapsedLabel.text = finalString
        
        // --------------
        
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        let totalDistanceInMeters = distanceQuantity.doubleValueForUnit(HKUnit.meterUnit())
        let distanceInMiles = (totalDistanceInMeters / 1609.34)
        distanceLabel.text = String(format: "%0.2f mi", distanceInMiles)
        
        //Calculate Average pace
        let minutesPerMile = (seconds/60.0) / (distance/1609.34)
        let mins = Int(minutesPerMile)
        let secs = Int((minutesPerMile % 1) * 60.0)
        
        let paceString = String(format: "%02d:%02d", mins, secs)
        
        print("Pace: \(mins):\(secs)")

        paceLabel.text = paceString
        
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
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "fireEachSecond:",
            userInfo: nil,
            repeats: true)
        startUpdatingLocation()
    }
    
    @IBAction func pauseRecording(sender: AnyObject) {
        
    }

    @IBAction func stopRecording(sender: AnyObject) {
        print("Stopping!")
        timer.invalidate()
        saveActivity()
    }
    
    func saveActivity() {
        
        //create activity object to save
        //let savedActivity = NSEntityDescription.insertNewObjectForEntityForName("GPSActivity", inManagedObjectContext: managedObjectContext!) as! GPSActivity
        
        //save all of the location data
        let savedActivity = GPSActivity(duration: seconds, distance: distance, timestamp: NSDate(), locations: locations, activityType: activityType!)

        
        print("Saved!\n-----\n\nPoints:")
        
        for point in savedActivity.locations {
            print("Lat: \(point.coordinate.latitude), Lon: \(point.coordinate.longitude)")
        }
        
        print("Distance: \(savedActivity.distance)")
        print("Duration (s): \(savedActivity.duration)")
        print("Timestamp: \(savedActivity.timestamp)")
        print("Type: \(savedActivity.activityType)")
        
        gpsactivity = savedActivity
        
        stopUpdatingLocation()
        
        //save activity to cloudkit
        
        let publicDB = model.publicDB
        
        //create record
        let record : CKRecord!
        
        //set record attributes
        record = CKRecord(recordType: "GPSActivity")
        record.setValue(seconds, forKey: "Duration")
        record.setValue(distance, forKey: "Distance")
        record.setValue(NSDate(), forKey: "Timestamp")
        record.setValue(locations, forKey: "Locations")
        record.setValue(activityType!, forKey: "ActivityType")
        
        
        publicDB.saveRecord(record) { savedRecord, error in
            if error != nil {
                print("Error: \(error)")
            } else {
                print("Saved to cloudkit successfully!")
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
