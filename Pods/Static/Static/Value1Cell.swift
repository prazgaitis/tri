import UIKit

public class Value1Cell: UITableViewCell, CellType {
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.blackColor()
        textLabel?.textColor = UIColor.whiteColor()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
