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
    
    var activity: GPSActivity!

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var activityType: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var mapview: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        let distanceString = String(format: "%.3f", (activity!.distance / 1609.34))
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
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

        
        // end duration -------------
        
        // labels
        activityType.text = activity!.activityType
        distance.text = String("\(distanceString) mi")
        timestamp.text = dateString
        duration.text = durationString


        // Do any additional setup after loading the view.
    }


    
    @IBAction func unwindToTableView(sender: AnyObject) {
        
        //self.performSegueWithIdentifier("unwindToFeed", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: MapView stuff
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLocation = activity.locations.first
        
        //testing map
        let startLat = activity.locations.first?.coordinate.latitude
        let startLng = activity.locations.first?.coordinate.longitude
        let startLL = CLLocationCoordinate2DMake(startLat!, startLng!)
        
        let startSpan = MKCoordinateSpanMake(Double(10.0), Double(10.0))
        
        //get the first coordinates Lat/Lng
        var minimumLat = initialLocation?.coordinate.latitude
        var minimumLng = initialLocation?.coordinate.longitude
        
        //set max == min before iterating through all
        var maximumLat = minimumLat
        var maximumLng = minimumLng
        
        for loc in activity.locations {
            minimumLat = min(minimumLat!, loc.coordinate.latitude)
            minimumLng = min(minimumLng!, loc.coordinate.longitude)
            maximumLat = max(maximumLat!, loc.coordinate.latitude)
            maximumLng = max(maximumLng!, loc.coordinate.longitude)
        }
        
        print(initialLocation)
        
        //get center of mapview
        //return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minimumLat! + maximumLat!)/2, longitude: (minimumLng! + maximumLat!)/2), span: MKCoordinateSpan(latitudeDelta: (maximumLat! - minimumLat!) * 1.1, longitudeDelta: (maximumLng! - minimumLng!) * 1.1))
        return MKCoordinateRegionMake(startLL, startSpan)
    }
    
//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKPolyline! {
//        if !overlay.isKindOfClass(MKPolyline) {
//            return nil
//        }
//        
//        let polyline = overlay as! MKPolyline
//        let renderer = MKPolyline()
//        return renderer
//    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = activity.locations
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude))
        }
        
        return MKPolyline(coordinates: &coords, count: activity.locations.count)
    }

    
    func setupView() {
        mapview.region = mapRegion()
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

