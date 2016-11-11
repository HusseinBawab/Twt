//
//  Tweet.swift
//  Twt
//
//  Created by Tedmob IMac on 11/10/16.
//  Copyright © 2016 iOS Team. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User
    var retweeted: Int = 0
    var tweetText: String
    
    init(aUser: User, numberRetweeted: Int, text: String) {
        user = aUser
        retweeted = numberRetweeted
        tweetText = text
        
        super.init()
    }
}
