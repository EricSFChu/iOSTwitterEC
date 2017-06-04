//
//  AppDelegate.swift
//  TweetingInEC
//
//  Created by EricDev on 2/8/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        sleep(2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.userDidLogout), name: NSNotification.Name(rawValue: userDidLogoutNotification), object: nil)
        if User.currentUser != nil {
            // go to the logged in screen
            print("Current user detected", User.currentUser?.name! as Any)
            let vc = storyboard.instantiateViewController(withIdentifier: "TweetsView") as!
                UINavigationController
            //let vc2 = vc.topViewController as! TweetsViewController
                //UIViewController
           
            
            window?.rootViewController = vc
        }
        return true
    }
    
    //reset the view when user logs out
    func userDidLogout() {
        let vc = storyboard.instantiateInitialViewController()! as UIViewController
        window?.rootViewController = vc
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        TwitterClient.sharedInstance.openURL(url: url as NSURL)
        
        return true
    }

}

