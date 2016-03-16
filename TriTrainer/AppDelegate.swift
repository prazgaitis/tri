//
//  AppDelegate.swift
//  TriTrainer
//
//  Created by Razgaitis, Paul on 2/22/16.
//  Copyright © 2016 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Contacts


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var contactStore = CNContactStore()
    let model = Model.sharedInstance()
    let color = Colors()
    
    //test if currently tracking a workout
    var currentlyTrackingWorkout: Bool = false

    // Launch Screen
    var storyboard:UIStoryboard?
    // --


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //get the current user's contacts
        model.contactsPlease()
        
        //check for permission to access contacts
        model.getPermission()
            
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Set the splashScreen VC
        let splashController = storyboard!.instantiateViewControllerWithIdentifier("LaunchVC")
        
        if let window = self.window {
            window.rootViewController = splashController
        }
        
        //
        // Settings
        //
        // Register default values for settings
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let defaults = [ "name_preference" : "Johnny Appleseed","slider_preference" : 1.0 ]
        
        userDefaults.registerDefaults(defaults)
        userDefaults.synchronize()
        
        //launch counter
        
        if userDefaults.objectForKey("firstLaunch") != nil {
            //check how many times app has been launched
            var launchCount = userDefaults.objectForKey("launchCount") as! Int
            print("This app has been launched \(launchCount) times")
            
            //increment it
            launchCount += 1
            
            //save it
            userDefaults.setValue(launchCount, forKey: "launchCount")
            
            //send user to app ratings in App Store
            //TODO: Ask them if they want to review it with a UIAlertViewController first.
            
            if launchCount == 5 {
                UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\("com.paulrazgaitis.TriTrainer")&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!);
            }

        } else {
            //this will fire on first launch
            userDefaults.setValue(NSDate(), forKey: "initialLaunch")
            userDefaults.setValue(1, forKey: "launchCount")
            print("First Launch!")
            print("First Launch time: \(userDefaults.objectForKey("initialLaunch"))")
            
        }
        
        
        
    

        //---------------------
        
        // Override point for customization after application launch.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        //appearance
        UINavigationBar.appearance().translucent = true
        UINavigationBar.appearance().tintColor = UIColor.lightTextColor()
        
        UINavigationBar.appearance().tintColor = color.mainGreen
        UINavigationBar.appearance().backgroundColor = UIColor.blackColor()
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        
        UITabBar.appearance().barTintColor = UIColor.blackColor()
        UITabBar.appearance().tintColor = color.mainGreen
        
        /// - Attribution: http://stackoverflow.com/questions/24402000/uinavigationbar-text-color-in-swift
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        return true
        
        
    }
    
    func removeSplashView(){
        
        print("\n++ calling function removeSplashView() from AppDelegate.swift (line 91)\n")
        
        // Change the root controller to the feed
        let rootController = storyboard!.instantiateViewControllerWithIdentifier("mainVC")
        if let window = self.window {
            window.rootViewController = rootController
        }
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
//        window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        window?.makeKeyAndVisible()
//        
//        storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        // Set the splashScreen VC
//        let splashController = storyboard!.instantiateViewControllerWithIdentifier("LaunchVC")
//        
//        if let window = self.window {
//            window.rootViewController = splashController
//        }
        
        //if NOT in the middle of a workout, refresh the data
        
        if (!currentlyTrackingWorkout) {
            //get the current logged in user's info (in case logged out and back in as another user)
            //this will refresh data and redirect to the main feed
            model.getUserInfo()
            model.contactsPlease()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // --------------------
    
    
    // MARK: Custom functions
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "TriTrainer", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        let pushedViewControllers = (self.window?.rootViewController as! UITabBarController).viewControllers
        let presentedViewController = pushedViewControllers![pushedViewControllers!.count - 1]
        
        presentedViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            print("Contacts access denied - AppDelegate.swift")
                            let message = "\(accessError!.localizedDescription)\n\nIf you want to compete against your friends, you'll have to allow Tri Trainer to access your contacts."
                            print(message)
                            //self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }




}

