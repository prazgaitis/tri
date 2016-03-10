//
//  NewSwimVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/8/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Foundation
import CloudKit

class NewSwimVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var hoursPicker: UIPickerView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var totalTimeInSeconds: Double = 0.0
    var distance: Double = 50.0
    var hours:[Int] = []
    var pickerData = ["Hours", "Minutes", "Seconds"]
    
    var hh: Int = 0
    var mm: Int = 0
    var ss: Int = 0
    var hString = String(00)
    var mString = String(00)
    var sString = String(00)
    
    var activity = Activity()
    let activityType = "swim"
    
    let model = Model.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPicker()
        
        saveButton.addTarget(self, action: "saveActivity", forControlEvents: .TouchUpInside)
    }
    
    func setUpPicker(){
        for index in 0..<60 {
            hours.append(index)
        }
        hoursPicker.dataSource = self
        hoursPicker.delegate = self
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Picker Delegates & Data
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //replace this stub
        return hours.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(hours[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected: \(String(pickerData[component])) \(row)")
    
        if (component == 0) {
            hh = row
            mString = String(format: "%02d", mm)
            sString = String(format: "%02d", ss)
            hString = String(format: "%02d", hh)
            
            timeLabel.text = "\(hString):\(mString):\(sString)"
        } else if (component == 1) {
            mm = row
            mString = String(format: "%02d", mm)
            sString = String(format: "%02d", ss)
            hString = String(format: "%02d", hh)
            timeLabel.text = "\(hString):\(mString):\(sString)"
        } else {
            ss = row
            mString = String(format: "%02d", mm)
            sString = String(format: "%02d", ss)
            hString = String(format: "%02d", hh)
            timeLabel.text = "\(hString):\(mString):\(sString)"
        }
        
        totalTimeInSeconds = Double(ss + (mm * 60) + (hh * 3600))
        print("Totaltimeinseconds: \(totalTimeInSeconds)")
        
    }
    
    func saveActivity() {
        
        //check to make sure we know who is logging the activity
        if (model.currentLoggedInUser == nil) && (model.currentLoggedInUserID == nil)  {
            print("CAN'T GET USERS DATA")
            return
        }
        
        //save all of the location data
        let savedActivity = Activity(duration: totalTimeInSeconds, distance: distance, timestamp: NSDate(), locations: nil, activityType: activityType, creatorName: model.currentLoggedInUser!, creatorID: model.currentLoggedInUserID!)
        
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
        
        let locations = [CLLocation]()
        
        let publicDB = model.publicDB
        
        //create record
        var record : CKRecord!
        record = CKRecord(recordType: "Activity")
        record.setValue(self.totalTimeInSeconds, forKey: "Duration")
        record.setValue(self.distance, forKey: "Distance")
        record.setValue(NSDate(), forKey: "Timestamp")
        record.setValue(locations, forKey: "Locations")
        record.setValue(self.activityType, forKey: "ActivityType")
        
        //save username
        if let user = model.currentLoggedInUser {
            record.setValue(user, forKey: "CreatorName")
        } else {
            record.setValue("First Last", forKey: "CreatorName")
        }
        
        //save creator ID
        if let userID = model.currentLoggedInUserID {
            record.setValue(userID, forKey: "CreatorID")
        } else {
            record.setValue("First Last", forKey: "CreatorID")
        }

        
        publicDB.saveRecord(record) { savedRecord, error in
            if error != nil {
                print("Error: \(error)")
            } else {
                //set flag to show we have new data to pass to the view
                NewActivityViewController.dirty = true
                print("Saved to cloudkit successfully!")
                
                dispatch_async(dispatch_get_main_queue(),{
                    print("we got here")
                    self.performSegueWithIdentifier("postSwim", sender: self)
                })
            }
        }
        
    }
    

    // MARK: - Navigation
    
    //segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "postSwim"
        {
            if let destinationVC = segue.destinationViewController as? ActivityDetailVC {
                destinationVC.activity = activity
                
                let navController = UINavigationController(rootViewController: destinationVC)
                
                self.presentViewController(navController, animated: true, completion: nil)
                
            }
        }
    }
}
