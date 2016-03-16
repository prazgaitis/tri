//
//  ActivityDetailVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/29/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import MapKit
import HealthKit


class ActivityDetailVC: UIViewController {
    
    var activity: Activity!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var activityType: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var swimIcon: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        if activity.activityType == "swim" {
            distance.center = swimIcon.center
            distance.center.y = swimIcon.center.y + 100
        } else {
            swimIcon.hidden = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        //placeLabels()
        
        print("Activity Type: \(activity?.activityType)")

        navigationBar.title = activity?.activityType.uppercaseString
        
        print("Locations: \(activity.locations?.count)")
        
        //check if activity needs a map
        
        // check if locations are nil
        if (activity.locations != nil) && (activity.locations?.count > 0) {
            print("setting up map")
            mapview.delegate = self
            setUpMap()
        } else {
            print("activity is a swim, no map")
            mapview.hidden = true
        }
        
        let distanceString = String(format: "%.2f", (activity!.distance / 1609.34))
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
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
        
        //set pace string
        let metersInMile = 1609.34
        let minutesPerMile = (activity.duration/60.0) / (activity.distance/metersInMile)
        let mins = minutesPerMile
        let secs = (minutesPerMile % 1) * 60.0
        
        paceLabel.text = String(format: "%2.f:%02.f /mi", mins, secs)

        
        // end duration -------------
        
        // labels
        activityType.text = "\(activity!.activityType) by \(activity.creatorName)"
        distance.text = String("\(distanceString) mi")
        timestamp.text = dateString
        duration.text = durationString


        // Do any additional setup after loading the view.
    }
    
//    func placeLabels(){
//        distance.frame = CGRectMake(0.0, 0.0, 200.0, 200.0)
//    }


    
    @IBAction func unwindToTableView(sender: AnyObject) {
        print("unwinding to feed")
        self.performSegueWithIdentifier("unwindToFeed", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: MapView stuff
    
    func mapRegion() -> MKCoordinateRegion {
        
        // activity should definitely have at least one location if we got to here
        let initialLocation = activity.locations!.first
        
        
        //testing map
        var minLat = initialLocation!.coordinate.latitude
        var minLng = initialLocation!.coordinate.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        // iterate through all locations.
        // this ensures mapview contains all bounds
        
        for point in activity.locations! {
            
            //check if current min is smaller than current point
            minLat = min(minLat, point.coordinate.latitude)
            minLng = min(minLng, point.coordinate.longitude)
            
            //same for max
            maxLat = max(maxLat, point.coordinate.latitude)
            maxLng = max(maxLng, point.coordinate.longitude)
        }
        
        let centerOfRun = CLLocationCoordinate2DMake((minLat + maxLat)/2, (minLng + maxLng)/2)
        
        let padding = 2.25
        
        let mapSpan = MKCoordinateSpan(latitudeDelta: (maxLat-minLat)*padding, longitudeDelta: (maxLng - minLng)*padding)
        
        return MKCoordinateRegionMake(centerOfRun, mapSpan)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if !overlay.isKindOfClass(MKPolyline) {
            print("overlay failed")
        }
        print("rendering overlay")
        
        let polyline = overlay as? MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline!)
        renderer.strokeColor = Colors().mainGreen
        renderer.lineWidth = 3
        
        return renderer

    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = activity.locations
        for location in locations! {
            coords.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude))
        }
        
        print("LOCATIONS COUNT: \(locations!.count)")
        return MKPolyline(coordinates: &coords, count: activity.locations!.count)
    }

    
    func setUpMap() {
        mapview!.region = mapRegion()
        mapview!.addOverlay(polyline())
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

// MARK: - MKMapViewDelegate
extension ActivityDetailVC: MKMapViewDelegate {
}

