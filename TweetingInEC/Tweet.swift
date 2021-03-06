//
//  Tweet.swift
//  TweetingInEC
//
//  Created by EricDev on 2/10/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String!
    var createdAt: Date?
    var username: String?
    var insideUser: NSDictionary?
    var name: String?
    var profileURLString: String?
    var profileURL: URL
    var favoriteCount: IntegerLiteralType
    var retweetCount: Int
    var id: Int
    var retweeted: IntegerLiteralType
    var favorited: Int
    var entities: NSDictionary?
    var otherInfo: NSDictionary?
    var media: [NSDictionary]?
    var mediaURLString: String
    var mediaURL: URL?
    var followersCount: Int
    var following: Int
    var statusesCount: Int
    var profileBackgroundURL: String?
    
    init(dictionary: NSDictionary) {
        user = User(dictionary: (dictionary["user"] as? NSDictionary)!)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as! String
        insideUser = dictionary["user"] as? NSDictionary
        username = insideUser!["screen_name"] as? String
        name = insideUser!["name"] as? String
        profileURLString = insideUser!["profile_image_url"] as? String
        profileURL = URL(string: profileURLString!)!
        favoriteCount = dictionary["favorite_count"] as! IntegerLiteralType
        id = dictionary["id"] as! Int
        retweetCount = dictionary["retweet_count"] as! Int
        if dictionary["retweeted"] != nil && dictionary["retweeted"] as? NSNull == nil {
               // retweeted = dictionary["retweeted"] as! IntegerLiteralType
            retweeted = 0
        } else {
            
            retweeted = 0
            
        }
        favorited = 0

        mediaURLString = ""
        
        otherInfo = dictionary["user"] as! NSDictionary?
        followersCount = otherInfo!["followers_count"] as! Int
        following = otherInfo!["friends_count"] as! Int
        statusesCount = otherInfo!["statuses_count"] as! Int
        profileBackgroundURL = ""
        
        if let val = otherInfo!["profile_banner_url"]{
        profileBackgroundURL = (self.otherInfo!["profile_banner_url"] as? String)!
        }
        var key: NSDictionary?
        //extract media info
        entities = dictionary["entities"] as? NSDictionary
        media = entities!["media"] as? [NSDictionary]
        if media?.count > 0 {
            for key in media! {
            mediaURLString = (key["media_url"] as? String)!
            mediaURL = URL(string: mediaURLString)
            }
        } else {
            mediaURLString = ""
            mediaURL = nil
        }
        
        
        //print(following)
        //print(entities)
        //print(media)
        //print("URL GOT IT: ", mediaURL)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        
        //we can get a date from a string or a string from a date
        createdAt = formatter.date(from: createdAtString!)
        
        //we can take elements from the dictionaries and place it in the tweet object which then 
        //can be used in the tweet view controller.
        
    }
    
    class func tweetsWithArray(_ array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
                //print("DICTIONARY#########  \(dictionary)")

        }

        return tweets
    }
}
