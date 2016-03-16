//
//  ActivityPickerVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/7/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import MapKit

class ActivityPickerVC: UIViewController {

    @IBOutlet weak var backgroundMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        print("appearing")
        
        showActivityOptions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        fadeToBlack()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        //if no option was selected, clear the picker from the view 
        if (self.view?.viewWithTag(99) != nil ) {
            //self.view?.viewWithTag(99)?.removeFromSuperview()
            print("removing black background view")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //show a custom View
    func showActivityOptions() {

        
        //create the box containing the message
        //center of superview
        let c = CGFloat((self.view.center.x))
        
        let defaultButtonColor = Colors().mainDarkGray
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.frame
        backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        backgroundView.tag = 99
        
        let activityPicker = ActivityPicker(frame: CGRectMake(0, 0, 300.0, 300.0))
        activityPicker.center = CGPointMake(c, -600)
        activityPicker.tag = 100
        activityPicker.layer.borderWidth = 2
        activityPicker.layer.borderColor = Colors().mainGreen.CGColor
        
        let titleBar = UIButton()
        titleBar.setTitle("Select a Workout", forState: .Normal)
        titleBar.backgroundColor = UIColor.blackColor()
        titleBar.frame = CGRectMake(0.0, 0.0, 300.0, 60.0)
        titleBar.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleBar.userInteractionEnabled = false
        titleBar.layer.borderColor = Colors().mainGreen.CGColor
        
        
        let runButton = UIButton()
        runButton.setTitle("RUN", forState: .Normal)
        runButton.backgroundColor = defaultButtonColor
        runButton.frame = CGRectMake(0.0, 60.0, 300.0, 80.0)
        runButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        runButton.userInteractionEnabled = true
        runButton.tag = 200
        runButton.addTarget(self, action: "pickActivity:", forControlEvents: .TouchUpInside)
        runButton.addTarget(self, action: "dismissActivityPicker:", forControlEvents: .TouchUpInside)
        
        let bikeButton = UIButton()
        bikeButton.setTitle("BIKE", forState: .Normal)
        bikeButton.backgroundColor = defaultButtonColor
        bikeButton.frame = CGRectMake(0.0, 140.0, 300.0, 80.0)
        bikeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        bikeButton.userInteractionEnabled = true
        bikeButton.tag = 201
        bikeButton.addTarget(self, action: "pickActivity:", forControlEvents: .TouchUpInside)
        bikeButton.addTarget(self, action: "changeBackgroundColor:", forControlEvents: .TouchDown)
        
        let swimButton = UIButton()
        swimButton.setTitle("SWIM", forState: .Normal)
        swimButton.backgroundColor = defaultButtonColor
        swimButton.frame = CGRectMake(0.0, 220.0, 300.0, 80.0)
        swimButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        swimButton.userInteractionEnabled = true
        swimButton.tag = 202
        swimButton.addTarget(self, action: "pickActivity:", forControlEvents: .TouchUpInside)
        swimButton.addTarget(self, action: "changeBackgroundColor:", forControlEvents: .TouchDown)
        
        
        
        activityPicker.backgroundColor = UIColor.grayColor()
        self.view.addSubview(backgroundView)
        backgroundView.addSubview(activityPicker)
        activityPicker.addSubview(titleBar)
        activityPicker.addSubview(runButton)
        activityPicker.addSubview(bikeButton)
        activityPicker.addSubview(swimButton)

        //add subviews
        activityPicker.enter()
        
    }
    
    func changeBackgroundColor(sender: UIButton!) {
        sender.backgroundColor = Colors().mainGreen
    }
    
    func fadeToBlack() {
        UIView.animateWithDuration(0.2,
            delay: 2.0,
            options: .CurveEaseOut,
            animations: { () -> Void in
                self.view?.viewWithTag(99)?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(1.0)
                print("animating fadeToBlack() in ActivityPickerVC.swift (line 131)")
            })
            { (finished) -> Void in
                self.view?.viewWithTag(99)?.removeFromSuperview()
                print("removed ActivityPicker View")
        }

    }
    
    func pickActivity(sender: UIButton!) {
        
        //fadeToBlack()
        self.view?.viewWithTag(99)?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(1.0)
        
        let sv = sender.superview as? ActivityPicker
        sv?.exit()
        
        switch sender.tag {
        case 200:
            print("run")
            performSegueWithIdentifier("newGPSActivity", sender: sender)
        case 201:
            print("bike")
            performSegueWithIdentifier("newGPSActivity", sender: sender)
        case 202:
            print("swim")
            performSegueWithIdentifier("newSwim", sender: nil)
        default:
            return
        }
        
        sender.backgroundColor = Colors().mainGreen

    }
    
    func dismissActivityPicker(sender: UIButton!) {
//        let sv = sender.superview as? ActivityPicker
//        sv?.exit()
    }
    
    func dismissVC(){
        print("dismissing viewcontroller")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "newGPSActivity"
        {
            if let dvc = segue.destinationViewController as? NewActivityViewController {
                
                print("sender: \(sender!), \(sender!.tag)")
                
                if sender!.tag == 200 {
                    dvc.activityType = "run"
                    print("chose run")
                } else {
                    dvc.activityType = "bike"
                    print("chose bike")
                }
            }
        }
    }
}
