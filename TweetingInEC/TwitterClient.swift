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
let twitterBaseURL = URL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((_ user: User?, _ error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance!
    }
    
    func homeTimelineWithParams(_ params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?)  -> ()) {
        
        get("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
        //print("home timeline: \(response)")
        let tweets = Tweet.tweetsWithArray((response as? [NSDictionary])!)
            completion(tweets: tweets, error: nil)
            
        for tweet in tweets {
       // print("text: \(tweet.text), created: \(tweet.createdAt)")
        }
    } as! (URLSessionDataTask, Any?) -> Void, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
        print("error getting home timeline", error)
        completion(tweets: nil, error: error)
    })
        
    }
    
    //initiate login process and if it succeeds or fails call completion block
    //with either a user or error
    func loginWithCompletion(_ completion: @escaping (_ user: User?, _ error: NSError?) -> ()) {
        loginCompletion = completion
        
        //The twitter login dance which fetches request token and redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "tweetinginec://oauth"), scope: nil, success: {
            (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token")
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.shared.openURL(authURL!)
            
            })
            {(error: NSError!) -> Void in
                print("Failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        } as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void
    }
    
    func openURL(_ url:  URL){
        TwitterClient.sharedInstance.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential (queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the Access Token")
            
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            TwitterClient.sharedInstance.get("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
                //print("user: \(response)")
                let user = User(dictionary: (response as? NSDictionary)!)
                //user persistence 
                User.currentUser = user
                print("user: \(user.name)")
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                    print("error getting user")
                    self.loginCompletion?(user: nil, error: error)
            })
        }) { (error: NSError!) -> Void in
            print("Failed to receive access token")
            self.loginCompletion?(user: nil, error: error)
                } as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void as! (Error?) -> Void
    }
    
    func retweet(_ id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/retweet/\(id).json", parameters: params, success: { (operation: URLSessionDataTask!, response: AnyObject?) -> Void in
            print("Retweeted tweet with id: \(id)")
            completion(error: nil)
            }, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("cant retweet")
                completion(error: error)
            }
        )
    }
    
    func unretweet(_ id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/unretweet/\(id).json", parameters: params, success: { (operation: URLSessionDataTask!, response: AnyObject?) -> Void in
            print("unretweeted tweet with id: \(id)")
            completion(error: nil)
            }, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("cant unretweet")
                completion(error: error)
            }
        )
    }
    
    func likeTweet(_ id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/favorites/create.json?id=\(id)", parameters: params, success: { (operation: URLSessionDataTask!, response: AnyObject?) -> Void in
            print("Liked tweet with id: \(id)")
            completion(error: nil)
            }, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("Couldn't like tweet")
                completion(error: error)
            }
        )
    }
    
    func unlikeTweet(_ id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/favorites/destroy.json?id=\(id)", parameters: params, success: { (operation: URLSessionDataTask!, response: AnyObject?) -> Void in
            print("Unliked tweet with id: \(id)")
            completion(error: nil)
            }, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("Couldn't unlike tweet")
                completion(error: error)
            }
        )
    }
    
    func tweeting(_ escapedTweet: String, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/update.json?status=\(escapedTweet)", parameters: params, success: { (operation: URLSessionDataTask!, response: AnyObject?) -> Void in
            print("tweeted: \(escapedTweet)")
            completion(error: nil)
            }, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("Couldn't tweet")
                completion(error: error)
            }
        )
    }
    
    func reply(_ escapedTweet: String, statusID: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/update.json?in_reply_to_status_id=\(statusID)&status=\(escapedTweet)", parameters: params, success: { (operation: URLSessionDataTask!, response: AnyObject?) -> Void in
            print("tweeted: \(escapedTweet)")
            completion(error: nil)
            }, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("Couldn't tweet")
                completion(error: error)
            }
        )
    }
    func getUserTweets(_ name: String, params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?)  -> ()) {
        
        get("/1.1/statuses/user_timeline.json?screen_name=\(name)&count=25", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            //print("user's tweets: \(response)")
            let tweets = Tweet.tweetsWithArray((response as? [NSDictionary])!)
            completion(tweets: tweets, error: nil)
            
            for tweet in tweets {
                //print("text: \(tweet.text), created: \(tweet.createdAt), profileImageURL: \(tweet.profileURL)")
            }
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("error getting user's tweets", error)
                completion(tweets: nil, error: error)
        })
        
    }
    
    func getUserLikes(_ name: String, params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?)  -> ()) {
        
        get("/1.1/favorites/list.json?screen_name=\(name)&count=25", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            //print("user's tweets: \(response)")
            let tweets = Tweet.tweetsWithArray((response as? [NSDictionary])!)
            completion(tweets: tweets, error: nil)
            
            for tweet in tweets {
                //print("text: \(tweet.text), created: \(tweet.createdAt), profileImageURL: \(tweet.profileURL)")
            }
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (operation: URLSessionDataTask?, error: NSError!) -> Void in
                print("error getting user's likes", error)
                completion(tweets: nil, error: error)
        })
        
    }
    
    //"1.1/favorites/list.json?\(name)"

}
