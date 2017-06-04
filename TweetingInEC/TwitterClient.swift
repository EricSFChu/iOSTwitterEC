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
    
    var loginCompletion: ((_ user: User?, _ error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL! as URL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance!
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?)  -> ()) {
        
        get("1.1/statuses/home_timeline.json", parameters: params, success: { (URLSessionDataTask, response) -> Void in
            print("home timeline: \(String(describing: response))")
            let tweets = Tweet.tweetsWithArray((response as? [NSDictionary])!)
            completion(tweets, nil)
            
            for tweet in tweets {
                 print("text: \(String(describing: tweet.text)), created: \(String(describing: tweet.createdAt))")
            }
        }, failure: { (URLSessionDataTask, error) in
            print("error getting home timeline", error)
            completion(nil, error as NSError)
        })
        
    }
    
    //initiate login process and if it succeeds or fails call completion block
    //with either a user or error
    func loginWithCompletion(completion: @escaping (_ user: User?, _ error: NSError?) -> ()) {
        loginCompletion = completion
        
        //The twitter login dance which fetches request token and redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: NSURL(string: "tweetinginec://oauth")! as URL, scope: nil, success: {
            (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token")
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)")
            print(authURL!)
            UIApplication.shared.openURL(authURL! as URL)
            
        })
        {(error) -> Void in
            print("Failed to get request token")
            self.loginCompletion?(nil, error as NSError?)
        }
    }
    
    func openURL(url:  NSURL){
        TwitterClient.sharedInstance.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential (queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the Access Token")
            
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            TwitterClient.sharedInstance.get("1.1/account/verify_credentials.json", parameters: nil, success: { (URLSessionDataTask, response) -> Void in
                print("user: \(String(describing: response))")
                let user = User(dictionary: (response as? NSDictionary)!)
                //user persistence
                User.currentUser = user
                print("user: \(String(describing: user.name))")
                self.loginCompletion?(user, nil)
            }, failure: { (URLSessionDataTask, error) -> Void in
                print("error getting user")
                self.loginCompletion?(nil, error as NSError)
            })
        }) { (error) -> Void in
            print("Failed to receive access token")
            self.loginCompletion?(nil, error! as NSError)
        }
    }
    
    func retweet(id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/retweet/\(id).json", parameters: params, success: { (URLSessionDataTask, response) -> Void in
            print("Retweeted tweet with id: \(id)")
            completion(nil)
        }, failure: { (URLSessionDataTask, error) -> Void in
            print("cant retweet")
            completion(error as NSError)
        }
        )
    }
    
    func unretweet(id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/unretweet/\(id).json", parameters: params, success: { (URLSessionDataTask, response) -> Void in
            print("unretweeted tweet with id: \(id)")
            completion(nil)
        }, failure: { (URLSessionDataTask, error) -> Void in
            print("cant unretweet")
            completion(error as NSError)
        }
        )
    }
    
    func likeTweet(id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/favorites/create.json?id=\(id)", parameters: params, success: { (URLSessionDataTask, response) -> Void in
            print("Liked tweet with id: \(id)")
            completion(nil)
        }, failure: { (URLSessionDataTask, error) -> Void in
            print("Couldn't like tweet")
            completion(error as NSError)
        }
        )
    }
    
    func unlikeTweet(id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/favorites/destroy.json?id=\(id)", parameters: params, success: { (URLSessionDataTask, reponse) -> Void in
            print("Unliked tweet with id: \(id)")
            completion(nil)
        }, failure: { (URLSessionDataTask, error) -> Void in
            print("Couldn't unlike tweet")
            completion(error as NSError)
        }
        )
    }
    
    func tweeting(escapedTweet: String, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/update.json?status=\(escapedTweet)", parameters: params, success: { (URLSessionDataTask, response) -> Void in
            print("tweeted: \(escapedTweet)")
            completion(nil)
        }, failure: { (URLSessionDataTask, error) -> Void in
            print("Couldn't tweet")
            completion(error as NSError)
        }
        )
    }
    
    func reply(escapedTweet: String, statusID: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/update.json?in_reply_to_status_id=\(statusID)&status=\(escapedTweet)", parameters: params, success: { ( URLSessionDataTask, response) -> Void in
            print("tweeted: \(escapedTweet)")
            completion(nil)
        }, failure: { (URLSessionDataTask, error) -> Void in
            print("Couldn't tweet")
            completion(error as NSError)
        }
        )
    }
    func getUserTweets(name: String, params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?)  -> ()) {
        
        get("/1.1/statuses/user_timeline.json?screen_name=\(name)&count=25", parameters: params, success: { (URLSessionDataTask, response) -> Void in
            //print("user's tweets: \(response)")
            let tweets = Tweet.tweetsWithArray((response as? [NSDictionary])!)
            completion(tweets, nil)
            
            for tweet in tweets {
                print("text: \(String(describing: tweet.text)), created: \(String(describing: tweet.createdAt)), profileImageURL: \(tweet.profileURL)")
            }
        }, failure: { (URLSessionDataTask, error) -> Void in
            print("error getting user's tweets", error)
            completion(nil, error as NSError)
        })
        
    }
    
    func getUserLikes(name: String, params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?)  -> ()) {
        
        get("/1.1/favorites/list.json?screen_name=\(name)&count=25", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            //print("user's tweets: \(response)")
            let tweets = Tweet.tweetsWithArray((response as? [NSDictionary])!)
            completion(tweets, nil)
            
            for tweet in tweets {
                print("text: \(String(describing: tweet.text)), created: \(tweet.createdAt), profileImageURL: \(tweet.profileURL)")
            }
        } as? (URLSessionDataTask, Any?) -> Void, failure: { (URLSessionDataTask, error) -> Void in
            print("error getting user's likes", error)
            completion(nil, error as NSError)
        })
        
    }
    
    //"1.1/favorites/list.json?\(name)"
}
