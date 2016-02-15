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
    var retweetCount: Int
    var id: Int
    var retweeted: Int
    var favorited: Int
    var entities: NSDictionary?
    var media: [NSDictionary]?
    var mediaURLString: String
    var mediaURL: NSURL?
    
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
        retweetCount = dictionary["retweet_count"] as! Int
        retweeted = dictionary["retweeted"] as! Int
        favorited = dictionary["favorited"] as! Int
        mediaURLString = ""
        var key: NSDictionary?
        //extract media info
        entities = dictionary["entities"] as? NSDictionary
        media = entities!["media"] as? [NSDictionary]
        if media?.count > 0 {
            for key in media! {
            mediaURLString = (key["media_url"] as? String)!
            mediaURL = NSURL(string: mediaURLString)
            }
        } else {
            mediaURLString = ""
            mediaURL = nil
        }
        
        
        //print(dictionary)
        //print(entities)
        //print(media)
        //print("URL GOT IT: ", mediaURL)
        
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
