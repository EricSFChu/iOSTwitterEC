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
            headerImage.setImageWith(URL(string: (tweet?.profileBackgroundURL!)!)!)
        }
        headerImage.sizeToFit()
        profileImage.setImageWith((tweet?.profileURL)! as URL)
        tweetCount.text = "\(tweet!.statusesCount)"
        FollowersCount.text = "\(tweet!.followersCount)"
        FollowingCount.text = "\(tweet!.following)"
        
        titleView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: 150.0, height: 44.0))
        titleView.contentSize = CGSize(width: 0.0, height: 88.0)
        self.view.addSubview(titleView)
        
        titleLabel = UILabel(frame: CGRect(x: 0.0, y: 44.0, width: titleView.frame.width, height: 44.0))
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont(name: "Helvetica", size: 20)
        titleLabel.text = self.title
        titleLabel.textColor = UIColor.white
        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
        TwitterClient.sharedInstance.getUserTweets(name: tweet!.username!, params: nil, completion: { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.tableView.estimatedRowHeight = 120
            self.tableView.rowHeight = UITableViewAutomaticDimension
            })
        self.tableView.reloadData()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
       contentOffset = CGPoint(x: 0.0, y: min(scrollView.contentOffset.y + 64.0, 44.0))
        self.titleView.contentOffset.y = scrollView.contentOffset.y + 64.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTweetCell", for: indexPath) as! UserTweetCell
        let tweet = tweets![indexPath.row]
        cell.profileImage.setImageWith(tweet.profileURL as URL)
        cell.messageSpecial.text = tweet.text
        cell.messageSpecial.sizeToFit()
        cell.layoutIfNeeded()
        
        return cell
    }

    @IBAction func onSegmentChange(_ sender: AnyObject) {
        switch(segmentedTweetsMentions.selectedSegmentIndex){
        case 0:
            print("Tweets Selected")
            TwitterClient.sharedInstance.getUserTweets(name: tweet!.username!, params: nil, completion: { (tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
                self.tableView.estimatedRowHeight = 120
                self.tableView.rowHeight = UITableViewAutomaticDimension
            })
            self.tableView.reloadData()
            
            break
            
        case 1:
            print("Likes Selected")
            TwitterClient.sharedInstance.getUserLikes(name: tweet!.username!, params: nil, completion: { (tweets, error) -> () in
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
