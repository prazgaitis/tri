//
//  ProfileVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/3/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import CloudKit

class ProfileVC: UIViewController {
    
    let model: Model = Model.sharedInstance()

    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var coverPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        if let usersName = model.currentLoggedInUser {
            usersNameLabel.text = usersName.uppercaseString
        }
        usersNameLabel.textColor = UIColor.whiteColor()
        
        if let numberOfFriends = model.friendsCount {
            if numberOfFriends == 1 {
                friendsLabel.text = "1 friend using Tri"
            } else {
                friendsLabel.text = "\(numberOfFriends) friends using Tri"
            }
        }
        friendsLabel.textColor = Colors().mainGreen
        
        
        //nameLabel.text = model.userInfo.userRecordID

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
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
