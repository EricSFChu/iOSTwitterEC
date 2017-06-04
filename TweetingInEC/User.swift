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
    var profileURL: URL

    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
        profileURL = URL(string: profileImageUrl!)!
        
        
    }
    
    func logout() {
        User.currentUser = nil
        //remove all the permissions
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: userDidLogoutNotification), object: nil)
    }
    
    class var currentUser: User? {
        get{
            if _currentUser == nil {
                let data = UserDefaults.standard.object(forKey: currentUserKey) as! Data?
                if data != nil {
                    if data != nil {
                        do {
                            let dictionary =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
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
                    let data = try JSONSerialization.data(withJSONObject: user!.dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
                    UserDefaults.standard.set(data, forKey: currentUserKey)
                    } catch (let error) {
                    print(error)
                        assert(false)
                    }
            } else {
                    UserDefaults.standard.set(nil, forKey: currentUserKey)
                    }
            
            UserDefaults.standard.synchronize()
        }
        
    }
}


