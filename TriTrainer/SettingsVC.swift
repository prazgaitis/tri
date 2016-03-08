//
//  SettingsVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/3/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import CloudKit

class SettingsVC: UIViewController {
    
    let model: Model = Model.sharedInstance()
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        model.getContacts()
        
        
        //nameLabel.text = model.userInfo.userRecordID

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        updateLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLogin() {
        //let ip = NSIndexPath(forRow: 0, inSection: 0)
        //let cell = self.tableView.cellForRowAtIndexPath(ip)! as UITableViewCell
//        Model.sharedInstance().userInfo.loggedInToICloud { //1
//            accountStatus, error in
//            var text  = "Not logged in to iCloud" //2
//            if accountStatus == .Available { //3[sz
//                text = "Logged in to iCloud"
//                print(text)
//                Model.sharedInstance().userInfo.userInfo() { //4
//                    userInfo, error in
//                    if userInfo != nil {
//                        dispatch_async(dispatch_get_main_queue()) {
//                            let nameText = "Logged in as \(userInfo.displayContact?.givenName) \(userInfo.displayContact?.familyName)" //5
//                            self.nameLabel.text = nameText
//                        }
//                    }
//                }
//            }
//            else {
//                print("account not available")
//            }
//            dispatch_async(dispatch_get_main_queue()) {
//                //cell.textLabel.text = text
//                let enableSwitch = accountStatus == .Available //6
//                print("dispatch async")
//                //self.tableView.reloadData()
//            }
//        }
        
//        let username = model.userInfo.userID(){
//            userID, error in
//            if let userRecord = userID {
//                let userRef = CKReference(recordID: userRecord,
//                    action: .None)
//                //self.uname = userRef
//                
//                print("USER ID:")
//                print(userRef)
//                //self.nameLabel.text = userRef.dictionaryWithValuesForKeys("u")
//            }
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


