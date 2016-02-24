//
//  DetailsViewController.swift
//  TweetingInEC
//
//  Created by EricDev on 2/15/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    var tweetMessage: String = ""
    var tweet: Tweet?
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var sv: UIScrollView!
    @IBOutlet weak var tweetField: UITextView!
    @IBOutlet weak var helperView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.sv.directionalLockEnabled = true;
        //sv.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
        
        userLabel.text = tweet?.name
        userNameLabel.text = (tweet?.username)!
        profileView.setImageWithURL(tweet!.profileURL)
        tweetLabel.text = tweet?.text
        dateLabel.text = tweet?.createdAtString
        favoriteLabel.text = "\(tweet!.favoriteCount)"
        retweetLabel.text = "\(tweet!.retweetCount)"
        profileView.layer.cornerRadius = 4
        profileView.clipsToBounds = true

        
        let favoritableImage = UIImage(named: "favoritable") as UIImage?
        let unfavoritableImage = UIImage(named: "unfavoritable") as UIImage?
        let likableImage = UIImage(named: "likable") as UIImage?
        let unlikableImage = UIImage(named: "unlikable") as UIImage?
        
        if tweet!.favorited == 0 {
            favoriteButton.setImage(favoritableImage, forState: .Normal)
        } else if tweet!.favorited == 1 {
            favoriteButton.setImage(unfavoritableImage, forState: .Normal)
        }
        
        if tweet!.retweeted == 0 {
            retweetButton.setImage(likableImage, forState: .Normal)
        } else if tweet!.retweeted == 1 {
            retweetButton.setImage(unlikableImage, forState: .Normal)
        }
        
        if tweet!.mediaURL != nil {
            tweetImageView.setImageWithURL(tweet!.mediaURL!)
            tweetImageView.sizeToFit()
            print("Image loaded")
            tweetImageView.layer.cornerRadius = 4
            tweetImageView.clipsToBounds = true
        }
        tweetField.text = "\(tweet!.username!) "
        
        helperView.sizeToFit()
        sv.contentSize = CGSize(width: self.sv.frame.size.width, height: 2*(helperView.frame.size.height))
        //self.sv.frame.origin.y + self.tweetImageView.frame.size.height)
        
        
    }

    @IBAction func onTweet(sender: AnyObject) {
        tweetMessage = tweetField.text
        let escapedTweetMessage = tweetMessage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        TwitterClient.sharedInstance.reply(escapedTweetMessage!, statusID: tweet!.id, params: nil , completion: { (error) -> () in
            print("replying")
            print(error)
        })

    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
