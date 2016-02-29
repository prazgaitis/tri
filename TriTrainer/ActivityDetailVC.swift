//
//  ActivityDetailVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/29/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit

class ActivityDetailVC: UIViewController {
    
    var activity: GPSActivity?

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var activityType: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let distanceString = String(format: "%.3f", (activity!.distance / 1609.34))
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        let dateString = formatter.stringFromDate(activity!.timestamp)
        
        //duration --------------
        
        let totalSeconds = activity!.duration
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
        
        
        let durationString = "\(hoursString):\(minutesString):\(secondsString)"

        
        // end duration -------------
        
        // labels
        activityType.text = activity!.activityType
        distance.text = String("\(distanceString) mi")
        timestamp.text = dateString
        duration.text = durationString


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
