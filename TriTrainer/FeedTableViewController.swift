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
    
    //count dates to sort table by date
    var numberOfDates = 0
    var arrDates: [String] = []
    var arrActivities: [[Activity]] = [[]]
    var dateIndex: Int = 0
    
    //dictionary of activities
    var dateDictionary: [String: [Activity]] = [:]
    
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
        
        //dont think this is necessary. if it is, it should be in the model
        //getTheContacts()
        
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
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appdelegate.showMessage("Error: \(error)")
        
        
        /*
        
        curl https://docs.google.com/forms/d/1-T-bHj1sjJp6Df1nwYXYyZsKGvR3-OF6XX6k/formResponse
        -d ifq
        -d entry.276372852  = test
        -d entry.1434010333 = test
        -d entry.2064025692 = test
        -d submit           = Submit
        
        -------
        
        curl "https://docs.google.com/forms/d/1-T-bHj1sjJp6Df1nwYXfyZsKGvR3-OF6XX6k/formResponse?ifq&entry.276372852=Hello1&entry.1434010333=Hello2&entry.2064025692=Helo3&submit=Submit"
        
        */
        
        //user data
        let userName = model.currentLoggedInUser as String?
        
        if let userName = userName {
            model.postData(userName, field2: "test", field3: "test")
        } else {
            model.postData("no username yet", field2: "test", field3: "test")
        }
        
//        //throw alert if network is unreachable
//        let alert = UIAlertController(title: "Error", message: "Unable to communicate with server", preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func modelUpdated() {
        
        print("model updated! line 150 - FeedTableViewController.swift")
        
        if (feedSelector.selectedSegmentIndex == 0) {
            activities = model.myActivities
        } else {
            activities = model.allActivities
        }
        
        print("\n\nActivities (\(activities.count))")
        print("---------------------\n")
        
        //clear out arrays for table sorting
        arrActivities.removeAll(keepCapacity: false)
        arrDates.removeAll(keepCapacity: false)
        numberOfDates = 0
        
        if activities.count > 0 {
            for (index, activity) in activities.enumerate() {
                
                //for print styling purposes
                if activity.activityType == "run" {
                    print("- \(activity.activityType)  -- \(activity.timestamp) -- \(activity.creatorName)")
                } else {
                    print("- \(activity.activityType) -- \(activity.timestamp) -- \(activity.creatorName)")
                }
                
                //get date
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
                formatter.dateStyle = .MediumStyle
                formatter.timeStyle = .NoStyle
                
                let dateString = formatter.stringFromDate(activity.timestamp)
                
                //sort by date for the table
                
//                //count dates to sort table by date
//                var numberOfDates = 0
//                var datesArray: [String] = []
//                var actByDate: [[Activity]] = [[]]
//                var dateIndex: Int = 0
                
                //store each unique date in datesArray
                //store all activities in arrActivities matrix
                
                /*
                
                datesArray: 
                
                [ "2016-03-21", "2016-03-22", "2016-03-23", ... ]
                
                arrActivities: 
                [
                    [ activity, activity, activity ]
                    [ activity, activity, activity, activity, activity, activity ]
                    [ activity, activity, activity, activity, activity ]
                ]
                
                data structure:
                
                "2016-03-21" => [ activity, activity, activity ]
                "2016-03-22" => [ activity, activity, activity, activity, activity, activity ]
                "2016-03-23" => [ activity, activity, activity, activity, activity ]
                

                */
                
                //two arrays - one containing dates, the other an..array of arrays?
                if arrDates.contains(dateString) {
                    //get index of date
                    dateIndex = arrDates.indexOf(dateString)!
                    arrActivities[dateIndex].append(activity)
                    print("appended activity to \(arrDates[dateIndex]) => \(arrActivities[dateIndex])")
                } else {
                    //else if it's not in the array, append it
                    arrDates.append(dateString)
                    dateIndex = arrDates.indexOf(dateString)!
                    print("FAILS HERE. \(arrDates.indexOf(dateString)!)")
                    print(arrDates)
                    let newArr = [activity]
                    arrActivities.append(newArr)
                    print("created date \(arrDates[dateIndex]) => \(arrActivities[dateIndex])")
                    numberOfDates++
                }
            }
        } else {
            print("There were no activities returned")
        }
        self.tableView.reloadData()
    
        
        print("PRINTING DATES: ")
        
        for (index, date) in arrDates.enumerate() {
            print("\(date) -> \(arrActivities[index])")
        }
    }
    
    //
    // MARK: - Table view data source
    //

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if numberOfDates > 1 {
            //print("number of dates: \(numberOfDates)")
            return numberOfDates
        } else {
            //print("number of dates: \(numberOfDates)")
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrActivities.count == 0 {
            return 0
        } else {
            return self.arrActivities[section].count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if arrDates.count == 0 {
            //print("LOADING!")
            return "Loading"
        } else {
            //print("arrDates.count: \(arrDates.count)")
            //print("section count: \(section)")
            return arrDates[section]
        }
    }
    
    //style the tableview headers
//    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//        header.contentView.backgroundColor = UIColor.blackColor()
//        header.textLabel?.textColor = UIColor.whiteColor()
//        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17)
//        header.alpha = 0.5
//    }
    
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
        
        //get items in this section
        let activitiesOnThisDay = arrActivities[indexPath.section]
        let activity = activitiesOnThisDay[indexPath.row]
        
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
        cell.distance.textColor = .blackColor()
        cell.pill.backgroundColor = .whiteColor()
        //cell.paceLabel.textColor = color.mainGreen

        //removed dateLabel
        //cell.dateLabel.text = dateString.uppercaseString
        cell.nameLabel.text = creatorName
        cell.nameLabel.textColor = UIColor.lightTextColor()
        cell.pill.layer.cornerRadius = 5.0
        cell.pill.backgroundColor = Colors().mainGreen
        cell.typeLabel.text = activity.activityType.uppercaseString
        
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
                let activity = arrActivities[indexPath.section][indexPath.row]
                let controller = segue.destinationViewController as! ActivityDetailVC
                controller.activity = activity
            }
        }
    }

}