//
//  UserTweetCell.swift
//  TweetingInEC
//
//  Created by EricDev on 2/26/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit

class UserTweetCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var retweet: UIButton!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var messageSpecial: UITextView!



    
    override func awakeFromNib() {
        //photoView.layer.cornerRadius = 4
       // photoView.clipsToBounds = true
        
        
    }
}

