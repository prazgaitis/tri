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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        paceLabel.hidden = true
        distance.hidden = false
        
        //add gesture recognizers to labels
        
        distance.userInteractionEnabled = true
        paceLabel.userInteractionEnabled = true
        
        distance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "swapLabels"))
        paceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "swapLabels"))
    }
    
    //when distance label is tapped, show the pace label and vice versa
    func swapLabels() {
        print("tapped label")
        if (paceLabel.hidden == true) {
            paceLabel.hidden = false
            distance.hidden = true
        } else {
            distance.hidden = false
            paceLabel.hidden = true
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
