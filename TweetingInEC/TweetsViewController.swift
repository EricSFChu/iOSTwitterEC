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
        refreshControl.addTarget(self, action: #selector(TweetsViewController.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        TwitterClient.sharedInstance.homeTimelineWithParams(params: nil) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.tableView.estimatedRowHeight = 120
            self.tableView.rowHeight = UITableViewAutomaticDimension
            print(tweets)

        }
        tableView.reloadData()

    }
    
    
    @IBAction func onFavorite(_ sender: AnyObject) {
        
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TweetCell
        
        let indexPath = tableView.indexPath(for: cell)
        let tweet = tweets![indexPath!.row]
        let path = tweet.id
        let toFavoriteOrNotToFavorite = tweet.favorited
        if toFavoriteOrNotToFavorite == 0 {
            TwitterClient.sharedInstance.likeTweet(id: path, params: nil) { (error) -> () in
                print("Liking")
                self.tweets![indexPath!.row].favoriteCount += 1
                tweet.favorited = 1
                self.tableView.reloadData()
            }
        } else if toFavoriteOrNotToFavorite == 1 {
            TwitterClient.sharedInstance.unlikeTweet(id: path, params: nil , completion: { (error) -> () in
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
        let index = IndexPath(row: indexPath!.row, section: 0)
        self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)
        self.tableView.reloadData()
    }
    
    @IBAction func onRetweet(_ sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TweetCell
        
        let indexPath = tableView.indexPath(for: cell)
        let tweet = tweets![indexPath!.row]
        let path = tweet.id
        let toTweetOrNotToTweet = tweet.retweeted
        if toTweetOrNotToTweet == 0 {
            TwitterClient.sharedInstance.retweet(id: path, params: nil) { (error) -> () in
                print("Retweeting")
                self.tweets![indexPath!.row].retweetCount += 1
                tweet.retweeted = 1
                self.tableView.reloadData()
            }
        } else if toTweetOrNotToTweet == 1 {
            TwitterClient.sharedInstance.unretweet(id: path, params: nil , completion: { (error) -> () in
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
            let index = IndexPath(row: indexPath!.row, section: 0)
            self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)
        }
        self.tableView.reloadData()
    }
   /*
    func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
       
                performSegueWithIdentifier("To Profile Other", sender: nil)
    }
*/
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
        
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let tweet = tweets![indexPath.row]
        cell.userName.text = tweet.name
        cell.screenNameLabel.text = "@" + tweet.username!
        //print("Tweet user name", tweet.username)
        cell.messageSpecial.text = tweet.text
        cell.messageSpecial.sizeThatFits(CGSize(width: cell.messageSpecial.frame.width, height: CGFloat.greatestFiniteMagnitude))
        cell.messageSpecial.isScrollEnabled = false
        cell.timeLabel.text = tweet.createdAtString
        cell.profileImage.setImageWith(tweet.profileURL as URL)
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
        cell.profileImage.isUserInteractionEnabled = true

        
        if tweet.favorited == 0 {
            cell.favoriteButton.setImage(favoritableImage, for: UIControlState())
        } else if tweet.favorited == 1 {
            cell.favoriteButton.setImage(unfavoritableImage, for: UIControlState())
        }
        
        if tweet.retweeted == 0 {
            cell.retweet.setImage(likableImage, for: UIControlState())
        } else if tweet.retweeted == 1 {
            cell.retweet.setImage(unlikableImage, for: UIControlState())
        }
        
        
        if tweet.mediaURL != nil {
            let imageRequest = URLRequest(url: tweet.mediaURL! as URL)
            cell.photoView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        cell.photoView.alpha = 0.0
                        cell.photoView.image = image
                        cell.photoView.sizeToFit()
                        cell.photoView.layer.cornerRadius = 4
                        cell.photoView.clipsToBounds = true
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.photoView.alpha = 1.0
                        })
                        
                    } else {
                        cell.photoView.image = image
                        cell.photoView.sizeToFit()
                        cell.photoView.layer.cornerRadius = 4
                        cell.photoView.clipsToBounds = true
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })

            cell.setNeedsLayout()
        }
            //cell.photoView.setImageWithURL(tweet.mediaURL!)
        
        cell.layoutIfNeeded()
        return cell
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        tableView.reloadData()
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimelineWithParams(params: nil, completion:  { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        })
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogout(_ sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "To Details Page" {
            print("Details Segue called")
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let tweet = tweets![indexPath!.row]
            
            let detailViewController = segue.destination as! DetailsViewController
            detailViewController.tweet = tweet
        }
        if segue.identifier == "To Profile Other" {
            print("Profile Other Segue Called")
            let button = sender as! UIButton
            let view = button.superview!
            let cell = view.superview as! TweetCell
            let indexPath = tableView.indexPath(for: cell)
            let tweet = tweets![indexPath!.row]
            
            let profileViewController = segue.destination as! ProfileViewController
            profileViewController.tweet = tweet
        }
        if segue.identifier == "To Profile" {
            print("Profile Segue Called By ME")
        }
    }
}
