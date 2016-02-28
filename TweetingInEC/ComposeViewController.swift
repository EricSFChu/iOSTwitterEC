//
//  ComposeViewController.swift
//  TweetingInEC
//
//  Created by EricDev on 2/24/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var profileImage: UIView!
    @IBOutlet weak var composeField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.composeField.delegate = self
        
    }
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    @IBAction func onTweet(sender: AnyObject) {
        let tweetMessage = composeField.text
        let escapedTweetMessage = tweetMessage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        TwitterClient.sharedInstance.tweeting(escapedTweetMessage!, params: nil , completion: { (error) -> () in
            print("chirping")
            print(error)
        })
        let alert = UIAlertController(title: "Tweet", message: "Chirp Chirp!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: {action in
            self.dismissViewControllerAnimated(false, completion: nil) }
            ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        let newLength = 140 - composeField.text.characters.count
        print(newLength)
        //change the value of the label
        tweetCount.text =  "\(newLength)"
    }
}
