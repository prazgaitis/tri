//
//  FeedTableViewController.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/29/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import CloudKit
import Contacts

class FeedTableViewController: UITableViewController, ModelDelegate {

    
    let model: Model = Model.sharedInstance()
    let color: Colors = Colors()
    var activities = [Activity]()
    var contacts = [CNContact]()
    
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
                let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
                
                do {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print("got contacts")
                    })
                }
                catch {
                    print("Unable to refetch the contact")
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
            
        } else if feedSelector.selectedSegmentIndex == 1 {
            //show all activities
            model.refresh()
        } else {
            print("This should not happen")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ModelDelegate Protocol Methods
    
    func refreshTable() {
        model.refresh()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func errorUpdating(error: NSError) {
        print(error)
    }
    
    func modelUpdated() {
        print("updated!")
        activities = model.items
        
        if model.items.count > 0 {
            for activity in model.items {
                print("\(activity.activityType) -- \(activity.timestamp) -- \(activity.creatorName)")
            }
        } else {
            print("zero items, yo!")
        }
        self.tableView.reloadData()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activities.count
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: ActivityCell = tableView.cellForRowAtIndexPath(indexPath) as! ActivityCell
        selectedCell.backgroundColor = color.mainDarkGray
        selectedCell.nameLabel.textColor = color.mainGreen
        print("didSelect Cell")
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: ActivityCell = tableView.cellForRowAtIndexPath(indexPath) as! ActivityCell
        selectedCell.backgroundColor = color.mainDarkGray
        selectedCell.nameLabel.textColor = color.mainGreen
        print("did-DE-Select Cell")
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: ActivityCell = tableView.cellForRowAtIndexPath(indexPath) as! ActivityCell
        selectedCell.selectionStyle = .None
        selectedCell.contentView.backgroundColor = color.mainDarkGray
        selectedCell.nameLabel.textColor = color.mainGreen
        print("didHighlight Cell")
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "activityCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ActivityCell
        let activity = activities[indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
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
        
        cell.distance.textColor = color.mainGreen
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
