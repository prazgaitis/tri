//
//  SwimDataEntryVC.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 3/11/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import Foundation
import UIKit

class SwimDataEntryTVC: UITableViewController, UITextFieldDelegate {
    
    var swimDelegate: SwimDataDelegate?
    
    weak var delegate: SwimDataDelegate?
    
    
    @IBOutlet weak var lapLengthCell: UITableViewCell!
    @IBOutlet weak var lapCountCell: UITableViewCell!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var paceCell: UITableViewCell!

    @IBOutlet weak var lapLengthField: UITextField!
    @IBOutlet weak var lapCountField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!

    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        print("loaded Swim data table")
        lapCountField.delegate = self
        lapCountField.attributedPlaceholder = NSAttributedString(string:"0 laps",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        lapLengthField.delegate = self
        lapLengthField.attributedPlaceholder = NSAttributedString(string:"0 meters",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        
        let dateString = formatter.stringFromDate(NSDate())
        dateLabel.text = dateString
        
        setColors()

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.showPicker(indexPath.row)
    }
    
    func setColors() {
        let cellsArray = [lapLengthCell, lapCountCell, dateCell, timeCell, paceCell]
        let labelsArray = [timeLabel, dateLabel, paceLabel]
        
        for cell in cellsArray {
            cell.backgroundColor = UIColor.blackColor()
            cell.selectionStyle = .None
        }
        
        for label in labelsArray {
            label.textColor = UIColor.whiteColor()
        }
        
        tableview.backgroundColor = UIColor.blackColor()
    }
    
    func findFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder() {
            return view
        } else {
            for sub in view.subviews {
                if let subview = sub as? UIView,
                    found = findFirstResponder(subview) {
                        return found
                }
            }
        }
        return nil
    }

    
    //MARK: TextField Delegate methods

    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("should begin egiting")
        delegate?.makeToolbar(self)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
//        print("textfield did end editing")
        if textField == lapCountField {
            print("lapcountfield")
            delegate?.setTheLapCount(Int(textField.text!)!)
        } else {
            print("laplengthfield")
            delegate?.setTheLapLength(Int(textField.text!)!)
        }
    }

    
    
}

protocol SwimDataDelegate: class {
    
    func writeValue(value: String) -> Void
    
    func showPicker(tag: Int) -> Void
    
    func makeToolbar(sender: AnyObject?) -> Void
    
    func setTheLapCount(int: Int) -> Void
    
    func setTheLapLength(int: Int) -> Void
}