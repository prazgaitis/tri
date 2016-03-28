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

class NewSwimVC: UIViewController, SwimDataDelegate {
    
    //set these all to false for form validation
    var dateSet: Bool = true
    var lapLengthSet: Bool = false
    var numberOfLapsSet: Bool = false
    var timeSet: Bool = false
    
    
    var activity = Activity()
    let activityType = "swim"
    let activityTimestamp = NSDate()
    
    var delegate: SwimDataDelegate?
    weak var embeddedVC: SwimDataEntryTVC?
    
    var totalTimeInSeconds: Double = 0.0
    var distance: Double = 0.0
    var lapLength = 0
    var lapCount = 0
    
    var hours:[Int] = []
    var lapLengthPickerData: [Int] = []
    var numberOfLapsPickerData: [Int] = []
    
    var durationPickerData = ["Hours", "Minutes", "Seconds"]
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var xButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // pickers via storyboard
    
    @IBOutlet weak var datePicker2: UIDatePicker!
    
    @IBAction func datePicker2Changed(sender: AnyObject) {
        print("datepicker2 changed")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        
        let dateString = formatter.stringFromDate(datePicker2.date)
        embeddedVC?.dateLabel.text = dateString
        
        //set activity timestamp
        activity.timestamp = datePicker2.date
        dateSet = true
    }
    
    @IBOutlet weak var lapLengthPicker: UIPickerView!
   // @IBOutlet weak var numberOfLapsPicker: UIPickerView!
    
    @IBOutlet weak var durationPicker: UIPickerView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    var uiPickerViews: [UIPickerView] = []
    
    var numberOfLaps = 0
    
    var hh: Int = 0
    var mm: Int = 0
    var ss: Int = 0
    var hString = String(00)
    var mString = String(00)
    var sString = String(00)
    
    var screenWidth: CGFloat?
    var screenHeight: CGFloat?
    
    let model = Model.sharedInstance()
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = .blackColor()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.backgroundColor = Colors().mainGreen
        saveButton.userInteractionEnabled = false
        saveButton.alpha = 0.5
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        xButton.tintColor = Colors().mainGreen
        xButton.addTarget(self, action: "dismissVC", forControlEvents: .TouchUpInside)
        setUpPickers()
        
        saveButton.addTarget(self, action: "saveActivity", forControlEvents: .TouchUpInside)
    }
    
    func tappedDateTimePicker(int: Int) {
        print("tapped me \(int)")
    }
    
    
    // Create the pickers off screen
    
    func setUpPickers(){
        toolbar.hidden = true
        toolbar.tintColor = Colors().mainGreen
        toolbar.barTintColor = UIColor.blackColor()
        
        datePicker2.hidden = true
        durationPicker.hidden = true
        lapLengthPicker.hidden = true
        
        //set colors
        datePicker2.backgroundColor = UIColor.blackColor()
        datePicker2.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        durationPicker.backgroundColor = UIColor.blackColor()
        lapLengthPicker.backgroundColor = UIColor.blackColor()
        
        //need this for hiding/showing
        uiPickerViews = [durationPicker,lapLengthPicker]
        
        for index in 0..<60 {
            hours.append(index)
        }
    
        durationPicker.dataSource = self
        durationPicker.delegate = self
        
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func dismissVC(){
        print("calling dismissVC")
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    func dismissKeypad() {
        if let embedded = embeddedVC {
            //find which field is active
            if let activeField = embedded.findFirstResponder(self.view) as? UITextField {
                if activeField.text == "" {
                    //throw alert
                    print("THROW ALERT")
                } else {
                    //remove toolbar
                    if let toolbar = view.viewWithTag(111) {
                        toolbar.removeFromSuperview()
                    }
                    //resign the textfields FR status
                    activeField.resignFirstResponder()
                }
            }
        }
    }
    
    
    @IBAction func dismissPickers(sender: AnyObject) {
        
        for picker in uiPickerViews {
            if picker.hidden == false {
                picker.hidden = true
            }
            if datePicker2.hidden == false {
                datePicker2.hidden = true
            }
        }
        toolbar.hidden = true
        
        //validate that form is complete
        
        if (dateSet && lapLengthSet && numberOfLapsSet && timeSet) {
            print("form is ready to save")
            
            saveButton.alpha = 1.0
            saveButton.userInteractionEnabled = true
        } else {
            print("form is NOT ready to save")
        }
        
        saveButton.hidden = false
    }
    
    //MARK: SwimDataDelegate methods
    
    
    func writeValue(value: String){
        print("\(value) IS BEING WRITTEN from NEWSWIMVC")
    }
    
    func showPicker(tag: Int) {
        print("firing showPicker")
        dismissKeypad()
        
        toolbar.hidden = false
        saveButton.hidden = true
        switch tag {
        case 0:
            print("picker 0")
            
            for picker in uiPickerViews {
                print(picker)
                picker.hidden = true
            }
            datePicker2.hidden = false
        case 2:
            print(tag)
            for picker in uiPickerViews {
                print(picker)
                picker.hidden = true
            }
        case 3:
            print(tag)
            for picker in uiPickerViews {
                print(picker)
                picker.hidden = true
            }
            durationPicker.hidden = false
        default:
            print("default case")
        }
    }
    
    
    func doneClicked() {
        print("doneclicked")
        
        //dismiss keypad
        dismissKeypad()
        distance = Double(lapCount * lapLength)
        
        print("Distance: \(distance)")
    }
    
    func setTheLapCount(int: Int) {
        lapCount = int
        numberOfLapsSet = true
        print("lapcount is ----> \(lapCount)")
    }
    
    func setTheLapLength(int: Int) {
        lapLength = int
         lapLengthSet = true
        print("laplength is ----> \(lapLength)")
    }
    
    var keyboardHeight: CGFloat = 0.0
    
    func keyboardWillShow(notification: NSNotification){
        print("calling keyboardwillshow")
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRect = keyboardFrame.CGRectValue()
        keyboardHeight = keyboardRect.height
    }

    
    func makeToolbar(sender: AnyObject?) {
        
        dismissPickers(self)
        
        print("making toolbar")
        
        let keyboardDoneBar = UIToolbar()
        keyboardDoneBar.sizeToFit()
        keyboardDoneBar.tag = 111
        keyboardDoneBar.barTintColor = UIColor.blackColor()
        keyboardDoneBar.tintColor = Colors().mainGreen
        
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("doneClicked"))
        
        var items = [UIBarButtonItem]()
        items.append(flexBarButton)
        items.append(doneButton)
        
        print("keyboard height: \(keyboardHeight)")
        
        keyboardDoneBar.items = items
        keyboardDoneBar.center = CGPointMake(self.view.center.x, self.view.center.y + 100)
        self.view.addSubview(keyboardDoneBar)
        
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
        
        if segue.identifier == "swimTableContainer"
        {
            let dataTable = segue.destinationViewController as! SwimDataEntryTVC
            dataTable.delegate = self
            self.embeddedVC = dataTable
        }
    }
}

extension NewSwimVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Picker Delegates & Data
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        if pickerView == lapLengthPicker {
            print("lapLengthPickerData.count = \(lapLengthPickerData.count)")
            return 1
        } else if pickerView == durationPicker {
            print("durationPickerData.ct = \(durationPickerData.count)")
            return 3
        } else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == durationPicker {
            return hours.count
        } else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                
        if pickerView == durationPicker {
            return String(hours[row])
        } else {
            return "No title"
        }
    }
    
//    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        if pickerView == lapLengthPicker {
//            return NSAttributedString(string: String(lapLengthPickerData[row]), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//        } else if pickerView == durationPicker {
//            return NSAttributedString(string: String(hours[row]), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//        } else {
//            return NSAttributedString(string: "no title", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//        }
//
//    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == durationPicker {
            print("Selected: \(String(durationPickerData[component])) \(row)")
            if (component == 0) {
                hh = row
                mString = String(format: "%02d", mm)
                sString = String(format: "%02d", ss)
                hString = String(format: "%02d", hh)
                
                embeddedVC?.timeLabel.text = "\(hString):\(mString):\(sString)"
            } else if (component == 1) {
                mm = row
                mString = String(format: "%02d", mm)
                sString = String(format: "%02d", ss)
                hString = String(format: "%02d", hh)
                embeddedVC?.timeLabel.text = "\(hString):\(mString):\(sString)"
            } else {
                ss = row
                mString = String(format: "%02d", mm)
                sString = String(format: "%02d", ss)
                hString = String(format: "%02d", hh)
                embeddedVC?.timeLabel.text = "\(hString):\(mString):\(sString)"
            }
            
            //set activity duration
            timeSet = true
            totalTimeInSeconds = Double(ss + (mm * 60) + (hh * 3600))
            print("Totaltimeinseconds: \(totalTimeInSeconds)")

            totalTimeInSeconds / distance
            
//        }
//        else if pickerView == lapLengthPicker {
//            print("doing something")
//            embeddedVC?.lapLengthLabel.text = String(lapLengthPickerData[row])
//            
//            //set lap length
//            lapLengthSet = true
//            lapLength = lapLengthPickerData[row]
        }
        else {
            //do something
            print("crashing here?")
        }
        
        //calculate pace after any picker is changed
        
        let metersPerMin = distance / (totalTimeInSeconds / 60)
        var paceString = ""
        
        if metersPerMin.isNaN {
            paceString = "0 m/min"
        } else {
            paceString = String(format: "%2.f m/min", metersPerMin)
        }
        
        embeddedVC?.paceLabel.text = paceString
        
    }
    
    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = .Center
        
        if pickerView == lapLengthPicker {
            let titleData = String(lapLengthPickerData[row])
            pickerLabel.backgroundColor = UIColor.blackColor()
            
            let labelTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            pickerLabel.attributedText = labelTitle
            
            return pickerLabel
            
        } else if pickerView == durationPicker {
            let titleData = String(hours[row])
            pickerLabel.backgroundColor = UIColor.blackColor()
            
            let labelTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            pickerLabel.attributedText = labelTitle
            return pickerLabel
            
        } else {
            let titleData = "nothing"
            pickerLabel.backgroundColor = UIColor.blackColor()
            
            let labelTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            pickerLabel.attributedText = labelTitle
            return pickerLabel
        }
    }
}
