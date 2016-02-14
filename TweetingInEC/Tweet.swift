//
//  Tweet.swift
//  TweetingInEC
//
//  Created by EricDev on 2/10/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String!
    var createdAt: NSDate?
    var username: String?
    var insideUser: NSDictionary?
    var name: String?
    var profileURLString: String?
    var profileURL: NSURL
    var favoriteCount: IntegerLiteralType
    var id: Int
    
    init(dictionary: NSDictionary) {
        user = User(dictionary: (dictionary["user"] as? NSDictionary)!)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as! String
        insideUser = dictionary["user"] as? NSDictionary
        username = insideUser!["screen_name"] as? String
        username = "@" + username!
        name = insideUser!["name"] as? String
        profileURLString = insideUser!["profile_image_url"] as? String
        profileURL = NSURL(string: profileURLString!)!
        favoriteCount = dictionary["favorite_count"] as! IntegerLiteralType
        id = dictionary["id"] as! Int
        print(id)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        
        //we can get a date from a string or a string from a date
        createdAt = formatter.dateFromString(createdAtString!)
        
        //we can take elements from the dictionaries and place it in the tweet object which then 
        //can be used in the tweet view controller.
        
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
                //print("DICTIONARY#########  \(dictionary)")

        }

        return tweets
    }
}
