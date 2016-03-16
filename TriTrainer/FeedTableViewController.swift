//
//  FeedTableViewController.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/29/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import CoreLocation
import CloudKit

class FeedTableViewController: UITableViewController, ModelDelegate {
    
    //TODO: SEPARATORS DISAPPEARING AFTER CELL IS SELECTED
    
    let model: Model = Model.sharedInstance()
    let color: Colors = Colors()
    var activities = [Activity]()
    var contacts = [CNContact]()
    
    // totals
    var totalRunDistance: Double = 0.0
    var totalSwimDistance: Double = 0.0
    var totalBikeDistance: Double = 0.0
    
    //activities by current week
    var allActivitiesThisWeek = [Activity]()
    var allRunsThisWeek = [Activity]()
    var allRidesThisWeek = [Activity]()
    var allSwimsThisWeek = [Activity]()
    
    @IBOutlet weak var feedSelector: UISegmentedControl!
    
    @IBAction func feedChanged(sender: AnyObject) {
        print("Changed! Feed: \(feedSelector.selectedSegmentIndex)")
        if (feedSelector.selectedSegmentIndex == 0) {
            model.showOnlyMyActivities()
        } else {
            model.refresh()
        }
    }
    
    @IBAction func unwindToTable(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        self.feedSelector.tintColor = color.mainGreen
        
        getTheContacts()
        
        model.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshTable", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl

    }
    
    func refetchContact(contact contact: CNContact, atIndexPath indexPath: NSIndexPath) {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                // let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
                let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
                
                do {
                    let contactRefetched = try AppDelegate.getAppDelegate().contactStore.unifiedContactWithIdentifier(contact.identifier, keysToFetch: keys)
                    self.contacts[indexPath.row] = contactRefetched
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print("i am here")
                    })
                }
                catch {
                    print("Unable to refetch the contact: \(contact)", separator: "", terminator: "\n")
                }
            }
        }
    }
    
    func getTheContacts() {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                // let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
                _ = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
                
                do {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print("got contacts")
                    })
                }
            }
        }
    }



    
    override func viewWillAppear(animated: Bool) {
        //refresh data from model
        //TODO: Only update if necessary
        
        print("firing view will appear")
        
        if (feedSelector.selectedSegmentIndex == 0) {
            //show only my activities
            model.showOnlyMyActivities()
            
        } else {
            //show all activities
            model.refresh()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ModelDelegate Protocol Methods
    
    func refreshTable() {
        
        if (feedSelector.selectedSegmentIndex == 0) {
            //show only my activities
            model.showOnlyMyActivities()
            
        } else {
            //show all activities
            model.refresh()
        }
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func errorUpdating(error: NSError) {
        print("Error updateing: \(error)")
        
        //throw alert if network is unreachable
        let alert = UIAlertController(title: "Error", message: "Unable to communicate with server", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func modelUpdated() {
        print("updated!")
        
        if (feedSelector.selectedSegmentIndex == 0) {
            activities = model.myActivities
        } else {
            activities = model.allActivities
        }
        
        print("\n\nActivities (\(activities.count))")
        print("---------------------\n")
        
        if activities.count > 0 {
            for (index, activity) in activities.enumerate() {
                
                //for print styling purposes
                if activity.activityType == "run" {
                    print("- \(activity.activityType)  -- \(activity.timestamp) -- \(activity.creatorName)")
                } else {
                    print("- \(activity.activityType) -- \(activity.timestamp) -- \(activity.creatorName)")
                }
            }
        } else {
            print("There were no activities returned")
        }
        self.tableView.reloadData()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: ActivityCell = tableView.cellForRowAtIndexPath(indexPath) as! ActivityCell
        selectedCell.selectionStyle = .None
        selectedCell.nameLabel.textColor = color.mainGreen
        print("didSelect Cell")
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: ActivityCell = tableView.cellForRowAtIndexPath(indexPath) as! ActivityCell
        selectedCell.nameLabel.textColor = UIColor.lightTextColor()
        print("did-DE-Select Cell")
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: ActivityCell = tableView.cellForRowAtIndexPath(indexPath) as! ActivityCell
        selectedCell.selectionStyle = .None
        selectedCell.nameLabel.textColor = color.mainGreen
        print("didHighlight Cell")
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "activityCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ActivityCell
        let activity = activities[indexPath.row]
        
        //calculate date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        
        //calculate pace - different if swimming or run/bike
        
        var paceString = ""
        
        if activity.activityType == "swim" {
            //meters per minute
            let metersPerMin = activity.distance / (activity.duration / 60)
            paceString = String(format: "%2.f m/min", metersPerMin)
            
        } else {
            let metersInMile = 1609.34
            let minutesPerMile = (activity.duration/60.0) / (activity.distance/metersInMile)
            let mins = minutesPerMile
            let secs = (minutesPerMile % 1) * 60.0
            paceString = String(format: "%2.f:%02.f /mi", mins, secs)
        }
        
        let dateString = formatter.stringFromDate(activity.timestamp)
        let creatorName = activity.creatorName

        // Configure the cell...
        
        cell.backgroundColor = UIColor.blackColor()
        if (activity.activityType == "swim") {
            let distanceString = String(format: "%.1f", activity.distance)
            cell.distance.text = String("\(distanceString) m")
        } else {
            let distanceString = String(format: "%.1f", (activity.distance / 1609.34))
            cell.distance.text = String("\(distanceString) mi")
        }
        
        cell.paceLabel.text = paceString
        cell.distance.textColor = color.mainGreen
        cell.paceLabel.textColor = color.mainGreen
        cell.dateLabel.text = dateString.uppercaseString
        cell.nameLabel.text = creatorName
        cell.nameLabel.textColor = UIColor.lightTextColor()
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

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


    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let activity = activities[indexPath.row]
                let controller = segue.destinationViewController as! ActivityDetailVC
                controller.activity = activity
            }
        }
    }

}
