//
//  ProfileVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/3/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import CloudKit
import PNChartSwift

class ProfileVC: UIViewController, PNChartDelegate {
    
    let model: Model = Model.sharedInstance()

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var barChartContainer: UIView!
    @IBOutlet weak var weekDistanceLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    let runButton = UIButton()
    let bikeButton = UIButton()
    let swimButton = UIButton()
    var buttons = [UIButton]()
    var buttonUnderlines = [UIView]()
    
    //total run distances
    var totalWeekRunDistance = 0.0
    var totalWeekSwimDistance = 0.0
    var totalWeekBikeDistance = 0.0
    
    // CGRectMake(x, y, width, height)
    var barChart = PNBarChart(frame: CGRectMake(0, 135.0, 320.0, 200.0))
    var runLineChart = PNLineChart(frame: CGRectMake(0, 0, 320.0, 200.0))
    var bikeLineChart = PNLineChart(frame: CGRectMake(0, 0, 320.0, 200.0))
    var swimLineChart = PNLineChart(frame: CGRectMake(0, 0, 320.0, 200.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupButtons()
        
        //create line graphs
        createRunLineChart()
        createBikeLineChart()
        createSwimLineChart()
        
        print("Start of week at midnight: \(model.startOfWeekAtMidnight)")
    }
    
    override func viewWillAppear(animated: Bool) {
        animateChartOnShow()
    }
    
    func animateChartOnShow() {
        let charts = [runLineChart, bikeLineChart, swimLineChart]
        for c in charts {
            if c.hidden == false {
                c.strokeChart()
                c.userInteractionEnabled = false
            }
        }
    }
    
    func setupButtons() {
        settingsButton.addTarget(self, action: #selector(ProfileVC.showSettings), forControlEvents: .TouchUpInside)
        
        print("setting up buttons")
        let screenwidth = self.view.frame.width
        let third = screenwidth / 3.0
        let horizontal = barChartContainer.frame.maxY + 50
    
        runButton.frame = CGRectMake(0.0, horizontal, third, 40.0)
        runButton.setTitle("RUN", forState: .Normal)
        runButton.backgroundColor = UIColor.blackColor()
        runButton.alpha = 0.85
        
        bikeButton.frame = CGRectMake(third, horizontal, third, 40.0)
        bikeButton.setTitle("BIKE", forState: .Normal)
        bikeButton.backgroundColor = UIColor.blackColor()
        bikeButton.alpha = 0.85
        
        swimButton.frame = CGRectMake(third * 2.0, horizontal, third, 40.0)
        swimButton.setTitle("SWIM", forState: .Normal)
        swimButton.backgroundColor = UIColor.blackColor()
        swimButton.alpha = 0.85
        
        buttons = [runButton, bikeButton, swimButton]
        
        for (i, b) in buttons.enumerate() {
            b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            b.setTitleColor(Colors().mainGreen, forState: .Highlighted)
            b.tag = i + 100
            b.addTarget(self, action: "tappedButton:", forControlEvents: .TouchUpInside)
        }
        
        let runUnderline = UIView(frame: runButton.frame)
        runUnderline.center.y += 3
        runUnderline.backgroundColor = Colors().mainGreen
        
        let swimUnderline = UIView(frame: swimButton.frame)
        swimUnderline.center.y += 3
        swimUnderline.backgroundColor = UIColor.blackColor()
        
        let bikeUnderline = UIView(frame: bikeButton.frame)
        bikeUnderline.center.y += 3
        bikeUnderline.backgroundColor = UIColor.blackColor()
        
        buttonUnderlines = [runUnderline, bikeUnderline, swimUnderline]
        
        self.view.addSubview(runUnderline)
        self.view.addSubview(bikeUnderline)
        self.view.addSubview(swimUnderline)
        
        self.view.addSubview(runButton)
        self.view.addSubview(bikeButton)
        self.view.addSubview(swimButton)
        
    }
    
    func tappedButton(sender: UIButton) {
        print("button tapped")
        
        buttonUnderlines.forEach({$0.backgroundColor = UIColor.blackColor()})
        print(sender.tag)
        
        //set underline
        buttonUnderlines[sender.tag - 100].backgroundColor = Colors().mainGreen
        
        //run tapped
        if sender.tag == 100 {
            
            let distString = String(format: "%.1f", totalWeekRunDistance)
            weekDistanceLabel.text = "\(distString) mi"
            
            runLineChart.hidden = false
            bikeLineChart.hidden = true
            swimLineChart.hidden = true
        }
            
        //bike tapped
        else if sender.tag == 101 {
            
            let distString = String(format: "%.1f", totalWeekBikeDistance)
            weekDistanceLabel.text = "\(distString) mi"
            
            bikeLineChart.hidden = false
            runLineChart.hidden = true
            swimLineChart.hidden = true
        }
            
        //swim tapped
        else {
            
            let distString = String(format: "%.1f", totalWeekSwimDistance)
            weekDistanceLabel.text = "\(distString) mi"
            
            swimLineChart.hidden = false
            runLineChart.hidden = true
            bikeLineChart.hidden = true
        }
    }
    
    func showSettings() {
        let settingsVC = SettingsTVC()
        let nav = UINavigationController(rootViewController: settingsVC)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func setupView() {
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
    }
    
    
    func createRunLineChart() {
        
        let runData = model.myActivities.filter({$0.activityType == "run"}).filter({$0.timestamp.compare(model.startOfWeekAtMidnight!) == NSComparisonResult.OrderedDescending})
        let runDistances = runData.map({$0.distance})
        let runTimestamps = runData.map({$0.timestamp})
        
        //set initial value for distance label
        totalWeekRunDistance = model.cuAllRunsThisWeek.reduce(0){$0 + $1.distance} / 1609.0
        
        let distString = String(format: "%.1f", totalWeekRunDistance)
        weekDistanceLabel.text = "\(distString) mi"
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        let runTimestampStrings = runTimestamps.map({formatter.stringFromDate($0)})
        
        runLineChart.yLabelFormat = "%1.1f"
        runLineChart.showLabel = true
        runLineChart.backgroundColor = UIColor.clearColor()
        runLineChart.xLabels = runTimestampStrings.reverse()
        runLineChart.showCoordinateAxis = true
        runLineChart.delegate = self
        
        // Line Chart Nr.1
        let data01Array = runDistances
        let data01:PNLineChartData = PNLineChartData()
        data01.color = Colors().mainGreen
        data01.itemCount = runDistances.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            let yValue:CGFloat = CGFloat(Double(runDistances[index]))
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        runLineChart.chartData = [data01].reverse()
        runLineChart.strokeChart()
        
        runLineChart.delegate = self
        
        runLineChart.center.x = self.view.center.x - 20
        
        barChartContainer.addSubview(runLineChart)
        
    }
    
    func createSwimLineChart() {
        
        let runData = model.myActivities.filter({$0.activityType == "swim"}).filter({$0.timestamp.compare(model.startOfWeekAtMidnight!) == NSComparisonResult.OrderedDescending})
        let runDistances = runData.map({$0.distance})
        
        totalWeekSwimDistance = runDistances.reduce(0){$0 + $1} / 1609
        
        let runTimestamps = runData.map({$0.timestamp})
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        let runTimestampStrings = runTimestamps.map({formatter.stringFromDate($0)})
        
        //var lineChart:PNLineChart = PNLineChart(frame: CGRectMake(0, 135.0, 320, 200.0))
        swimLineChart.yLabelFormat = "%1.1f"
        swimLineChart.showLabel = true
        swimLineChart.backgroundColor = UIColor.clearColor()
        swimLineChart.xLabels = runTimestampStrings.reverse()
        swimLineChart.showCoordinateAxis = true
        swimLineChart.delegate = self
        
        // Line Chart Nr.1
        var data01Array = runDistances.reverse()
        var data01:PNLineChartData = PNLineChartData()
        data01.color = Colors().mainGreen
        data01.itemCount = runDistances.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            var yValue:CGFloat = CGFloat(Double(runDistances[index]))
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        swimLineChart.chartData = [data01]
        swimLineChart.strokeChart()
        
        swimLineChart.delegate = self
        
        swimLineChart.center.x = self.view.center.x - 20
        
        barChartContainer.addSubview(swimLineChart)
        swimLineChart.hidden = true
        
    }
    
    func createBikeLineChart() {
        
        let runData = model.myActivities.filter({$0.activityType == "bike"}).filter({$0.timestamp.compare(model.startOfWeekAtMidnight!) == NSComparisonResult.OrderedDescending})
        let runDistances = runData.map({$0.distance})
        let runTimestamps = runData.map({$0.timestamp})
        
        //bike distances
        totalWeekBikeDistance = runDistances.reduce(0){$0 + $1} / 1609
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        let runTimestampStrings = runTimestamps.map({formatter.stringFromDate($0)})
        
        //var lineChart:PNLineChart = PNLineChart(frame: CGRectMake(0, 135.0, 320, 200.0))
        bikeLineChart.yLabelFormat = "%1.1f"
        bikeLineChart.showLabel = true
        bikeLineChart.backgroundColor = UIColor.clearColor()
        bikeLineChart.xLabels = runTimestampStrings.reverse()
        bikeLineChart.showCoordinateAxis = true
        bikeLineChart.delegate = self
        
        // Line Chart Nr.1
        var data01Array = runDistances.reverse()
        var data01:PNLineChartData = PNLineChartData()
        data01.color = Colors().mainGreen
        data01.itemCount = runDistances.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            var yValue:CGFloat = CGFloat(Double(runDistances[index]))
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        bikeLineChart.chartData = [data01]
        bikeLineChart.strokeChart()
        
        bikeLineChart.delegate = self
        
        bikeLineChart.center.x = self.view.center.x - 20
        
        barChartContainer.addSubview(bikeLineChart)
        bikeLineChart.hidden = true
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // MARK: PNChartDelegate Methods
    
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, keyPointIndex: Int) {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex) and point index is \(keyPointIndex)")
    }
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int) {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex)")
    }
    
    func userClickedOnBarChartIndex(barIndex: Int){
        print("Click  on bar \(barIndex), \(barChart.yValues[barIndex])")
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

//tutorial on extending UIView to allow partial border on buttons

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(CGColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }
    
    @IBInspectable var bottomBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: 0.0, y: bounds.height, width: bounds.width, height: newValue))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[line]|", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[line(==lineWidth)]|", options: [], metrics: metrics, views: views))
        }
    }
}