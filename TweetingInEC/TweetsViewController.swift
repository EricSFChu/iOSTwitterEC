//
//  TweetsViewController.swift
//  TweetingInEC
//
//  Created by EricDev on 2/13/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit


class TweetsViewController: UIViewController {
    
    var tweets: [Tweet]?
    override func viewDidLoad() {
        super.viewDidLoad()
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            self.tweets = tweets
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
}
