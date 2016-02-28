//
//  TweetsViewController.swift
//  TweetingInEC
//
//  Created by EricDev on 2/13/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit


class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
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
        tableView.reloadData()

    }
    
    
    @IBAction func onFavorite(sender: AnyObject) {
        
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TweetCell
        
        let indexPath = tableView.indexPathForCell(cell)
        let tweet = tweets![indexPath!.row]
        let path = tweet.id
        let toFavoriteOrNotToFavorite = tweet.favorited
        if toFavoriteOrNotToFavorite == 0 {
            TwitterClient.sharedInstance.likeTweet(path, params: nil) { (error) -> () in
                print("Liking")
                self.tweets![indexPath!.row].favoriteCount += 1
                tweet.favorited = 1
                self.tableView.reloadData()
            }
        } else if toFavoriteOrNotToFavorite == 1 {
            TwitterClient.sharedInstance.unlikeTweet(path, params: nil , completion: { (error) -> () in
                print("unliking")
                self.tweets![indexPath!.row].favoriteCount -= 1
                tweet.favorited = 0
                self.tableView.reloadData()
            })
        }
        /*
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion:  { (tweets, error) -> () in
            self.tweets = tweets
            //self.tableView.reloadData()
            let index = NSIndexPath(forRow: indexPath!.row, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
        })
*/
        let index = NSIndexPath(forRow: indexPath!.row, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
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
                self.tweets![indexPath!.row].retweetCount += 1
                tweet.retweeted = 1
                self.tableView.reloadData()
            }
        } else if toTweetOrNotToTweet == 1 {
            TwitterClient.sharedInstance.unretweet(path, params: nil , completion: { (error) -> () in
                print("Unretweeting")
                self.tweets![indexPath!.row].retweetCount -= 1
                tweet.retweeted = 0
                self.tableView.reloadData()
            })
        }

        /*
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion:  { (tweets, error) -> () in
            self.tweets = tweets
            let index = NSIndexPath(forRow: indexPath!.row, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
            //self.tableView.reloadData()
        })
        */
        if tweets!.count != 0 {
            let index = NSIndexPath(forRow: indexPath!.row, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
        }
        self.tableView.reloadData()
    }
   /*
    func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
       
                performSegueWithIdentifier("To Profile Other", sender: nil)
    }
*/
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
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
        cell.screenNameLabel.text = "@" + tweet.username!
        //print("Tweet user name", tweet.username)
        cell.messageSpecial.text = tweet.text
        cell.messageSpecial.sizeThatFits(CGSize(width: cell.messageSpecial.frame.width, height: CGFloat.max))
        cell.messageSpecial.scrollEnabled = false
        cell.timeLabel.text = tweet.createdAtString
        cell.profileImage.setImageWithURL(tweet.profileURL)
        cell.retweetLabel.text = "\(tweet.retweetCount)"
        cell.retweetLabel.sizeToFit()
        cell.favoriteLabel.text = "\(tweet.favoriteCount)"
        cell.photoView.image = nil
        let favoritableImage = UIImage(named: "favoritable") as UIImage?
        let unfavoritableImage = UIImage(named: "unfavoritable") as UIImage?
        let likableImage = UIImage(named: "likable") as UIImage?
        let unlikableImage = UIImage(named: "unlikable") as UIImage?
        cell.profileImage.layer.cornerRadius = 4
        cell.profileImage.clipsToBounds = true
        
        //Tap gesture recognition on profile picture
        let tapGesture = UITapGestureRecognizer(target: self, action: "imageTapped:")
        // add it to the image view;
        cell.profileImage.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        cell.profileImage.userInteractionEnabled = true

        
        if tweet.favorited == 0 {
            cell.favoriteButton.setImage(favoritableImage, forState: .Normal)
        } else if tweet.favorited == 1 {
            cell.favoriteButton.setImage(unfavoritableImage, forState: .Normal)
        }
        
        if tweet.retweeted == 0 {
            cell.retweet.setImage(likableImage, forState: .Normal)
        } else if tweet.retweeted == 1 {
            cell.retweet.setImage(unlikableImage, forState: .Normal)
        }
        
        if tweet.mediaURL != nil {
            let imageRequest = NSURLRequest(URL: tweet.mediaURL!)
            cell.photoView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        cell.photoView.alpha = 0.0
                        cell.photoView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.photoView.alpha = 1.0
                        })
                        cell.photoView.sizeToFit()
                    } else {
                        cell.photoView.image = image
                        cell.photoView.sizeToFit()
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            cell.photoView.sizeToFit()
            cell.photoView.layer.cornerRadius = 4
            cell.photoView.clipsToBounds = true
            cell.setNeedsLayout()
        }
            //cell.photoView.setImageWithURL(tweet.mediaURL!)
        
        cell.layoutIfNeeded()
        return cell
        
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        tableView.reloadData()
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "To Details Page" {
            print("Details Segue called")
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets![indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailsViewController
            detailViewController.tweet = tweet
        }
        if segue.identifier == "To Profile Other" {
            print("Profile Other Segue Called")
            let button = sender as! UIButton
            let view = button.superview!
            let cell = view.superview as! TweetCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets![indexPath!.row]
            
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.tweet = tweet
        }
        if segue.identifier == "To Profile" {
            print("Profile Segue Called By ME")
        }
    }
}
