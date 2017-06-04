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
    

    @IBOutlet weak var specialTextField: UITextView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!

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
        userNameLabel.text = "@" + (tweet?.username)!
        profileView.setImageWith(tweet!.profileURL as URL)

        specialTextField.text = tweet?.text
        specialTextField.sizeThatFits(CGSize(width: specialTextField.frame.width, height: CGFloat.greatestFiniteMagnitude))
        specialTextField.isScrollEnabled = false;
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
            favoriteButton.setImage(favoritableImage, for: UIControlState())
        } else if tweet!.favorited == 1 {
            favoriteButton.setImage(unfavoritableImage, for: UIControlState())
        }
        
        if tweet!.retweeted == 0 {
            retweetButton.setImage(likableImage, for: UIControlState())
        } else if tweet!.retweeted == 1 {
            retweetButton.setImage(unlikableImage, for: UIControlState())
        }
        
        if tweet!.mediaURL != nil {
            
            let imageRequest = URLRequest(url: tweet!.mediaURL! as URL)
            
            tweetImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.tweetImageView.alpha = 0.0
                        self.tweetImageView.image = image
                        self.tweetImageView.sizeToFit()
                        self.tweetImageView.layer.cornerRadius = 4
                        self.tweetImageView.clipsToBounds = true
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.tweetImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.tweetImageView.image = image
                        self.tweetImageView.sizeToFit()
                        self.tweetImageView.layer.cornerRadius = 4
                        self.tweetImageView.clipsToBounds = true
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            print("Image loaded")
        }
        tweetField.text = "@\(tweet!.username!) "
        
        helperView.sizeToFit()
        sv.contentSize = CGSize(width: self.sv.frame.size.width, height: 2*(helperView.frame.size.height))
        //self.sv.frame.origin.y + self.tweetImageView.frame.size.height)
        
        
    }

    @IBAction func onTweet(_ sender: AnyObject) {
        tweetMessage = tweetField.text
        let escapedTweetMessage = tweetMessage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        TwitterClient.sharedInstance.reply(escapedTweet: escapedTweetMessage!, statusID: tweet!.id, params: nil , completion: { (error) -> () in
            print("replying")
            print(error)
        })
        let alert = UIAlertController(title: "Tweet", message: "Replied!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: {action in
            self.dismiss(animated: false, completion: nil) }
            ))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func onDismiss(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onRetweet(_ sender: AnyObject) {
        
        let path = tweet!.id
        let toTweetOrNotToTweet = tweet!.retweeted
        if toTweetOrNotToTweet == 0 {
            TwitterClient.sharedInstance.retweet(id: path, params: nil) { (error) -> () in
                print("Retweeting")
                self.tweet?.retweetCount+=1
                self.retweetLabel.text = "\(self.tweet!.retweetCount)"
                self.tweet!.retweeted = 1
            }
        } else if toTweetOrNotToTweet == 1 {
            TwitterClient.sharedInstance.unretweet(id: path, params: nil , completion: { (error) -> () in
                print("Unretweeting")
                self.tweet?.retweetCount-=1
                self.retweetLabel.text = "\(self.tweet!.retweetCount)"
                self.tweet!.retweeted = 0
            })
        }
        
    }
    
    @IBAction func onFavorite(_ sender: AnyObject) {
        let path = tweet!.id
        let toFavoriteOrNotToFavorite = tweet!.favorited
        if toFavoriteOrNotToFavorite == 0 {
            TwitterClient.sharedInstance.likeTweet(id: path, params: nil) { (error) -> () in
                print("Liking")
                self.tweet?.favoriteCount += 1
                self.favoriteLabel.text = "\(self.tweet!.favoriteCount)"
                self.tweet!.favorited = 1
            }
        } else if toFavoriteOrNotToFavorite == 1 {
            TwitterClient.sharedInstance.unlikeTweet(id: path, params: nil , completion: { (error) -> () in
                print("unliking")
                self.tweet?.favoriteCount -= 1
                self.favoriteLabel.text = "\(self.tweet!.favoriteCount)"
                self.tweet!.favorited = 0
            })
        }
    }
}
