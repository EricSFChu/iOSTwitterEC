//
//  ProfileViewController.swift
//  TweetingInEC
//
//  Created by EricDev on 2/25/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var FollowingCount: UILabel!
    @IBOutlet weak var FollowersCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedTweetsMentions: UISegmentedControl!
    
    var tweet: Tweet?
    var tweets: [Tweet]?
    var titleView: UIScrollView!
    var titleLabel: UILabel!
    var contentOffset: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        if tweet?.profileBackgroundURL != "" {
        headerImage.setImageWithURL(NSURL(string: (tweet?.profileBackgroundURL)!)!)
        }
        headerImage.sizeToFit()
        profileImage.setImageWithURL((tweet?.profileURL)!)
        tweetCount.text = "\(tweet!.statusesCount)"
        FollowersCount.text = "\(tweet!.followersCount)"
        FollowingCount.text = "\(tweet!.following)"
        
        titleView = UIScrollView(frame: CGRectMake(0.0, 0.0, 150.0, 44.0))
        titleView.contentSize = CGSizeMake(0.0, 88.0)
        self.view.addSubview(titleView)
        
        titleLabel = UILabel(frame: CGRectMake(0.0, 44.0, CGRectGetWidth(titleView.frame), 44.0))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "Helvetica", size: 20)
        titleLabel.text = self.title
        titleLabel.textColor = UIColor.whiteColor()
        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
        TwitterClient.sharedInstance.getUserTweets(tweet!.username!, params: nil, completion: { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.tableView.estimatedRowHeight = 120
            self.tableView.rowHeight = UITableViewAutomaticDimension
            })
        self.tableView.reloadData()
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
       contentOffset = CGPointMake(0.0, min(scrollView.contentOffset.y + 64.0, 44.0))
        self.titleView.contentOffset.y = scrollView.contentOffset.y + 64.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTweetCell", forIndexPath: indexPath) as! UserTweetCell
        let tweet = tweets![indexPath.row]
        cell.profileImage.setImageWithURL(tweet.profileURL)
        cell.messageSpecial.text = tweet.text
        cell.messageSpecial.sizeToFit()
        cell.layoutIfNeeded()
        
        return cell
    }

    @IBAction func onSegmentChange(sender: AnyObject) {
        switch(segmentedTweetsMentions.selectedSegmentIndex){
        case 0:
            print("Tweets Selected")
            TwitterClient.sharedInstance.getUserTweets(tweet!.username!, params: nil, completion: { (tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
                self.tableView.estimatedRowHeight = 120
                self.tableView.rowHeight = UITableViewAutomaticDimension
            })
            self.tableView.reloadData()
            
            break
            
        case 1:
            print("Likes Selected")
            TwitterClient.sharedInstance.getUserLikes(tweet!.username!, params: nil, completion: { (tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
                self.tableView.estimatedRowHeight = 120
                self.tableView.rowHeight = UITableViewAutomaticDimension
            })
            self.tableView.reloadData()
            
            break
        default:
            break
        }
    }
    
}
