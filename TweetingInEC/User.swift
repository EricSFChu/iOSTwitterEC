//
//  User.swift
//  TweetingInEC
//
//  Created by EricDev on 2/10/16.
//  Copyright © 2016 EricDev. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var tagline: String?
    var dictionary: NSDictionary
    var profileURL: NSURL

    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
        profileURL = NSURL(string: profileImageUrl!)!
        
        
    }
    
    func logout() {
        User.currentUser = nil
        //remove all the permissions
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get{
            if _currentUser == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as! NSData?
                if data != nil {
                    if data != nil {
                        do {
                            let dictionary =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                            _currentUser = User(dictionary: dictionary)
                            } catch(let error) {
                                print(error)
                                assert(false)
                            }
                    }
                }
            }
                return _currentUser
        }
        
        set(user) {
            _currentUser = user
        
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions.PrettyPrinted)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                    } catch (let error) {
                    print(error)
                        assert(false)
                    }
            } else {
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
                    }
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
}


