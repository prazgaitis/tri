//
//  LaunchVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/15/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
       logo.rotateImageNonstop()
        
        print("Launch VC did load!")
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "goToApp" {
            print("going to app")
        }
    }
    */

}

// great tutorial: https://www.andrewcbancroft.com/2014/10/15/rotate-animation-in-swift/

extension UIView {
    func rotateImageNonstop(duration: CFTimeInterval = 10.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 10.5)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}
