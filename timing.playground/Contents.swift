//: Playground - noun: a place where people can play

import UIKit
import HealthKit

var str = "Hello, playground"

var seconds = 60.0
seconds = seconds + 770
let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)

let totalSeconds = secondsQuantity.doubleValueForUnit(HKUnit.secondUnit())
let numSeconds = totalSeconds % 60

print("Minutes:")
let numMinutes = floor((totalSeconds / 60) % 60)

let numHours = floor(totalSeconds / 3600)

var secondsString = String(format: "%.1f", numSeconds)
var minutesString = String(format: "%.0f", numMinutes)
var hoursString = String(format: "%.0f", numHours)
//
//
//
//if (Int(secondsString) < 10 ){
//    secondsString = "0\(secondsString)"
//}
//if (Int(minutesString) < 10 ){
//    minutesString = "0\(minutesString)"
//}
//if (Int(hoursString) < 10 ){
//    hoursString = "0\(hoursString)"
//}
//
//
//let finalString = "\(hoursString):\(minutesString):\(secondsString)"
//
//var totalDistanceInMeters = 123456.00
//
//var distanceInMiles = (totalDistanceInMeters / 1609.34)
//let stringer = String(format: "%0.2f mi", distanceInMiles)


////---
//
//class Location {
//    
//    var timestamp: NSDate
//    var latitude: Double
//    var longitude: Double
//    var gpsactivity: GPSActivity
//    
//    init(timestamp: NSDate, latitude: Double, longitude: Double, gpsactivity: GPSActivity) {
//        self.timestamp = timestamp
//        self.latitude = latitude
//        self.longitude = longitude
//        self.gpsactivity = gpsactivity
//    }
//    
//    convenience init() {
//        self.init()
//    }
//    
//}
//
//class GPSActivity {
//    
//    var duration: Double
//    var distance: Double
//    var timestamp: NSDate
//    var locations: [Location]
//    
//    init(duration: Double, distance: Double, timestamp: NSDate, locations: [Location]) {
//        self.timestamp = timestamp
//        self.distance = distance
//        self.duration = duration
//        self.locations = locations
//    }
//    
//    convenience init() {
//        self.init()
//    }
//    
//}
//
//let loc = Location()
//print(loc.timestamp)
//
//
//let act = GPSActivity()
//act.timestamp = NSDate()


//--------------

//let seconds = 3.0
//let distance = 0.0
//var paceLabel : String
//
//
////Calculate Average pace
//// TODO: FIX PACE
//let metersInMile = 1609.34
//let minutesPerMile = (seconds/60.0) / (distance/metersInMile)
//let mins = minutesPerMile
//let secs = (minutesPerMile % 1) * 60.0
//
//let paceString = String(format: "%2.f:%02.f", mins, secs)
//
//print("Pace: \(distance) || \(seconds) -- > m/s = \(distance/seconds)")
//
//if secs.isNaN {
//    paceLabel = "0:00:00"
//} else {
//    paceLabel = paceString
//}
//
//
//var username = NSUserName()
//
//var hh: Int = 0
//var mm: Int = 0
//var ss: Int = 0
//var hString = String(00)
//var mString = String(00)
//var sString = String(00)
//
//
//mString = String(format: "%02d", mm)
//sString = String(format: "%02d", ss)
//hString = String(format: "%02d", hh)
//
//var theString = "\(hString):\(mString):\(sString)"

let sSun = "2016-03-13"
let sMon = "2016-03-14"
let sTue = "2016-03-15"
let sWed = "2016-03-16"
let sThu = "2016-03-17"
let sFri = "2016-03-18"
let sSat = "2016-03-19"

let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd"
//dateFormatter.dateStyle = .LongStyle
//dateFormatter.timeStyle = .ShortStyle

let mon = dateFormatter.dateFromString(sMon) as NSDate!
let tue = dateFormatter.dateFromString(sTue) as NSDate!
let weds = dateFormatter.dateFromString(sWed) as NSDate!
let thu = dateFormatter.dateFromString(sThu) as NSDate!
let fri = dateFormatter.dateFromString(sFri) as NSDate!
let sat = dateFormatter.dateFromString(sSat) as NSDate!
let sun = dateFormatter.dateFromString(sSun) as NSDate!

func getDayOfWeek(today: NSDate)->Int? {
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let components = calendar.components(.Weekday, fromDate: today)
    let weekDay = components.weekday
    return weekDay
}

let dayOfWeek1 = getDayOfWeek(sun)
let dayOfWeek2 = getDayOfWeek(mon)
let dayOfWeek3 = getDayOfWeek(tue)
let dayOfWeek4 = getDayOfWeek(weds)
let dayOfWeek5 = getDayOfWeek(thu)
let dayOfWeek6 = getDayOfWeek(fri)
let dayOfWeek7 = getDayOfWeek(sat)

print("Day of week: \(dayOfWeek1!)", terminator: "")

// Get the date for the start of the week



let cal = NSCalendar.currentCalendar()

//get current day of week
if var dayOfWeek = getDayOfWeek(NSDate()) {
    
    print("Today is day \(dayOfWeek) of the week ")
    
    //subtract 1 because we'll be subtracting from yesterday
    dayOfWeek = dayOfWeek - 1

    let components = NSDateComponents()
    components.day = -dayOfWeek
    
    let startOfWeek = cal.dateByAddingComponents(
        components,
        toDate: NSDate(),
        options: [])!
    
    let startOfWeekMidnight = cal.startOfDayForDate(startOfWeek)
    
}
    


//- (dayOfWeek! * (60*60*24))





