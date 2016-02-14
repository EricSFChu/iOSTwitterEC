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
    var refreshControl: UIRefreshControl!
    var tweets: [Tweet]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.tableView.estimatedRowHeight = 120
            self.tableView.rowHeight = UITableViewAutomaticDimension

        }
        self.tableView.reloadData()
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TweetCell
        
        let indexPath = tableView.indexPathForCell(cell)
        let tweet = tweets![indexPath!.row]
        let path = tweet.id
        let toTweetOrNotToTweet = tweet.retweeted
        if toTweetOrNotToTweet == 0 {
            TwitterClient.sharedInstance.retweet(path, params: nil) { (error) -> () in
                print("Retweeting")
            }
        } else if toTweetOrNotToTweet == 1 {
            TwitterClient.sharedInstance.unretweet(path, params: nil , completion: { (error) -> () in
                print("Unretweeting")
            })
        }
        

        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion:  { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        })
    }
    

    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
        cell.userName.text = tweet.name
        cell.screenNameLabel.text = tweet.username
        //print("Tweet user name", tweet.username)
        cell.message.text = tweet.text
        cell.timeLabel.text = tweet.createdAtString
        cell.profileImage.setImageWithURL(tweet.profileURL)
        cell.retweetLabel.text = "\(tweet.retweetCount)"
        cell.favoriteLabel.text = "\(tweet.favoriteCount)"
        
        return cell
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion:  { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        })
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
}
