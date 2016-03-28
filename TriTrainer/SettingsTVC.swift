import UIKit
import Static

class SettingsTVC: TableViewController {
    
    // MARK: - Properties
    
    private let customAccessory: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        view.backgroundColor = .redColor()
        return view
    }()
    
    
    // MARK: - Initializers
    
    convenience init() {
        self.init(style: .Grouped)
    }
    
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .blackColor()
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("dismissSettings"))
        self.navigationItem.leftBarButtonItem = cancel
        
        title = "Settings"
        
        showDefaults()
        
        // Register for notification about settings changes
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "defaultsChanged",
            name: NSUserDefaultsDidChangeNotification,
            object: nil)

        
        tableView.rowHeight = 50
        
        dataSource.sections = [
            
            Section(header: "", rows: [
                Row(text: "Go to Settings app", cellClass: Value1Cell.self, accessory: .DisclosureIndicator, selection: { [unowned self] in
                    self.goToSettings()
                    }),
                Row(text: "App instructions", cellClass: Value1Cell.self, accessory: .DisclosureIndicator, selection: { [unowned self] in
                    let title = "Welcome to Tri!"
                    let instructions = "You can use Tri to track your runs, rides, and swims as you train for your next triathlon.\n\nUse the Feed tab to see an updated feed of all of your and your friends' workouts.\n\nTo see more personal stats, check out the Profile tab.\n\nWhen you're ready to track a new workout, tap the + Track Workout tab and select an workout type. \n\nCheers!"
                    self.showAlert(title: title, message: instructions, button: "Sounds good!")
                    }),
                Row(text: "Developer: Paul Razgaitis", cellClass: Value1Cell.self)
                
                ])
        ]
    }
    
    func dismissSettings() {
        print("calling dismiss settings")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showDefaults() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let namePreference = defaults.stringForKey("name_preference")
        let sliderPreference = defaults.doubleForKey("slider_preference")
        let enabledPreference = defaults.boolForKey("enabled_preference")
        
        print("Name: \(namePreference)")
        print("Slider: \(sliderPreference)")
        print("Enabled: \(enabledPreference)")
        
        
    }
    
    // MARK: CellType Protocol Methods

    
    //
    // MARK: - Notification Handlers
    //
    
    /// Called when user defaults is changed via a `NSNotification` broadcast.
    /// You don't get information about what was changed, you have to get all
    /// relevant values yourself and then use them accordingly.  In this case, we
    /// update a label on the screen.
    ///
    func defaultsChanged() {
        let namePreference = NSUserDefaults.standardUserDefaults().stringForKey("name_preference")
        //            nameLabel.text = "Name Preference: \(namePreference!)"
    }
    
    // MARK: - Private
    
    private func showAlert(title title: String? = nil, message: String? = "You tapped it. Good work.", button: String = "Thanks") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: button, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func goToSettings(){
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
        
    }
}

