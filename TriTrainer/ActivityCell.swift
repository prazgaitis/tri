//
//  ActivityCell.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/29/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    //MARK: Properties

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var pill: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    
    var labelIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        paceLabel.hidden = true
        distance.hidden = false
        typeLabel.hidden = true
        pill.backgroundColor = UIColor.whiteColor()
        
        //add gesture recognizers to labels
        
        distance.userInteractionEnabled = true
        paceLabel.userInteractionEnabled = true
        typeLabel.userInteractionEnabled = true
        
        distance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "swapLabels"))
        paceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "swapLabels"))
        typeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "swapLabels"))
    }
    
    //when distance label is tapped, show the pace label and vice versa
    func swapLabels() {
        print("tapped label")
        switch labelIndex {
        case 0:
            paceLabel.hidden = false
            typeLabel.hidden = true
            distance.hidden = true
            labelIndex += 1
        case 1:
            paceLabel.hidden = true
            typeLabel.hidden = false
            distance.hidden = true
            labelIndex += 1
        case 2:
            paceLabel.hidden = true
            typeLabel.hidden = true
            distance.hidden = false
            labelIndex = 0
        default: break
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
