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
        
        //if no option was selected, clear the picker from the view 
        if (self.view?.viewWithTag(100) != nil ) {
            self.view?.viewWithTag(100)?.removeFromSuperview()
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
        
        let defaultButtonColor = UIColor.lightGrayColor()
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.frame
        backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissVC"))
        
        let activityPicker = ActivityPicker(frame: CGRectMake(0, 0, 300.0, 300.0))
        activityPicker.center = CGPointMake(c, -600)
        activityPicker.tag = 100
        //activityPicker.layer.borderWidth = 1
        //activityPicker.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        let titleBar = UIButton()
        titleBar.setTitle("Select a Workout", forState: .Normal)
        titleBar.backgroundColor = UIColor.whiteColor()
        titleBar.frame = CGRectMake(0.0, 0.0, 300.0, 30.0)
        titleBar.setTitleColor(UIColor.blackColor(), forState: .Normal)
        titleBar.userInteractionEnabled = false
        
        
        let runButton = UIButton()
        runButton.setTitle("RUN", forState: .Normal)
        runButton.backgroundColor = defaultButtonColor
        runButton.frame = CGRectMake(0.0, 30.0, 300.0, 90.0)
        runButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        runButton.userInteractionEnabled = true
        runButton.tag = 200
        runButton.addTarget(self, action: "pickActivity:", forControlEvents: .TouchDown)
        runButton.addTarget(self, action: "dismissActivityPicker:", forControlEvents: .TouchUpInside)
        
        let bikeButton = UIButton()
        bikeButton.setTitle("BIKE", forState: .Normal)
        bikeButton.backgroundColor = defaultButtonColor
        bikeButton.frame = CGRectMake(0.0, 120.0, 300.0, 90.0)
        bikeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        bikeButton.userInteractionEnabled = true
        bikeButton.tag = 201
        bikeButton.addTarget(self, action: "pickActivity:", forControlEvents: .TouchDown)
        bikeButton.addTarget(self, action: "dismissActivityPicker:", forControlEvents: .TouchUpInside)
        
        let swimButton = UIButton()
        swimButton.setTitle("SWIM", forState: .Normal)
        swimButton.backgroundColor = defaultButtonColor
        swimButton.frame = CGRectMake(0.0, 210.0, 300.0, 90.0)
        swimButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        swimButton.userInteractionEnabled = true
        swimButton.tag = 202
        swimButton.addTarget(self, action: "pickActivity:", forControlEvents: .TouchDown)
        swimButton.addTarget(self, action: "dismissActivityPicker:", forControlEvents: .TouchUpInside)

        
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
    
    
    func pickActivity(sender: UIButton!) {
        sender.backgroundColor = UIColor.blackColor()
        switch sender.tag {
        case 200:
            print("run")
            performSegueWithIdentifier("newGPSActivity", sender: sender)
        case 201:
            print("bike")
            performSegueWithIdentifier("newGPSActivity", sender: sender)
        case 202:
            print("swim")
            //let vc = NewSwimVC()
            //self.presentViewController(vc, animated: true, completion: nil)
            performSegueWithIdentifier("newSwim", sender: nil)
            //redirect to swim thing
        default:
            return
        }
        
        //sender.backgroundColor = UIColor.redColor()

    }
    
    func dismissActivityPicker(sender: UIButton!) {
        let sv = sender.superview as? ActivityPicker
        sv?.exit()
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
                
                //self.presentViewController(dvc, animated: true, completion: nil)
                
            }
        }
    }

}
