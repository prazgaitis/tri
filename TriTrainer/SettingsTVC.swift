//
//  SettingsTVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/15/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Static

class SettingsTVC: UITableViewController {
    
//    // MARK: - Properties
//    
//    private let customAccessory: UIView = {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
//        view.backgroundColor = .redColor()
//        return view
//    }()
//    
//    
//    // MARK: - Initializers
//    
//    convenience init() {
//        self.init(style: .Grouped)
//    }
    
    
    // MARK: - UIViewController
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        title = "Settings"
//        
//        tableView.rowHeight = 50
//        
//        dataSource.sections = [
//            
//            Section(header: "", rows: [
//                Row(text: "Go to Settings app", accessory: .DisclosureIndicator, selection: { [unowned self] in
//                    self.goToSettings()
//                    }),
//                Row(text: "App instructions", accessory: .DisclosureIndicator, selection: { [unowned self] in
//                    let title = "Welcome to Tri!"
//                    let instructions = "You can use Tri to track your runs, rides, and swims as you train for your next triathlon.\n\nUse the Feed tab to see an updated feed of all of your and your friends' workouts.\n\nTo see more personal stats, check out the Profile tab.\n\nWhen you're ready to track a new workout, tap the + Track Workout tab and select an workout type. \n\nCheers!"
//                    self.showAlert(title: title, message: instructions, button: "Sounds good!")
//                    }),
//                Row(text: "Developer: Paul Razgaitis"),
//                //                Row(text: "Detail Button", accessory: .DetailButton({ [unowned self] in
//                //                    self.showAlert(title: "Detail Button")
//                //                })),
//                //                Row(text: "Custom View", accessory: .View(customAccessory))
//                ])
//        ]
//    }
    
    
    // MARK: - Private
    
    private func showAlert(title title: String? = nil, message: String? = "You tapped it. Good work.", button: String = "Thanks") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: button, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func goToSettings(){
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
        
    }


    @IBOutlet weak var nameLabel: UILabel!
    @IBAction func goToSettings(sender: AnyObject) {
        
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        showDefaults()
        
        // Register for notification about settings changes
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "defaultsChanged",
            name: NSUserDefaultsDidChangeNotification,
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = NSUserDefaults.standardUserDefaults().stringForKey("name_preference")
    }
    
    func showDefaults() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let namePreference = defaults.stringForKey("name_preference")
        let sliderPreference = defaults.doubleForKey("slider_preference")
        let enabledPreference = defaults.boolForKey("enabled_preference")
        
        print("Name: \(namePreference)")
        print("Slider: \(sliderPreference)")
        print("Enabled: \(enabledPreference)")
        
        
    }
    
    //
    // MARK: - Notification Handlers
    //
    
    /// Called when user defaults is changed via a `NSNotification` broadcast.
    /// You don't get information about what was changed, you have to get all
    /// relevant values yourself and then use them accordingly.  In this case, we
    /// update a label on the screen.
    ///
    func defaultsChanged() {
        let namePreference = NSUserDefaults.standardUserDefaults().stringForKey("name_preference")
        nameLabel.text = "Name Preference: \(namePreference!)"
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
