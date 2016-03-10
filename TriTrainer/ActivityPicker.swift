//
//  ActivityPicker.swift
//  
//
//  Created by Razgaitis, Paul on 3/7/16.
//
//

import UIKit

class ActivityPicker: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(0.0, 0.0, 300.0, 300.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enter() {
        
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: .CurveEaseIn,
            animations: { () -> Void in
                self.center = (self.superview?.center)!
            })
            { (finished) -> Void in
                print("DOne moving")
        }
    }
    
    func exit() {
        
        let c = CGFloat((superview?.center.x)!)
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: .CurveEaseIn,
            animations: { () -> Void in
                self.center = CGPoint(x: c, y: -600)
            })
            { (finished) -> Void in
                self.removeFromSuperview()
        }
        
    }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
