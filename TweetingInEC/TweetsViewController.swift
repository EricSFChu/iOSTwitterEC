//
//  TweetsViewController.swift
//  TweetingInEC
//
//  Created by EricDev on 2/13/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit


class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var tweets: [Tweet]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            
            //we have the tweet objects
            for tweet in tweets! {
                //print("Tweee ", tweet.text)
            }

        }
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
        
    }
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        let tweet = tweets![indexPath.row]
        cell.userName.text = tweet.username
        //print("Tweet user name", tweet.username)
        cell.message.text = tweet.text
        cell.timeLabel.text = "\(tweet.createdAt)"
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
}
