//
//  TwitterClient.swift
//
//
//  Created by EricDev on 2/8/16.
//
//

import BDBOAuth1Manager
import AFNetworking

let twitterConsumerKey = "kcx02Ecm64UUGvA34sL9vsmWP"
let twitterConsumerSecret = "DTUfUqZroeLuEWSTzRKk3nGBVuCmYlSoQhlpP0fpmuFz3VVnpX"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
}
