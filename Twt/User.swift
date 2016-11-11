//
//  User.swift
//  Twt
//
//  Created by Tedmob IMac on 11/10/16.
//  Copyright © 2016 iOS Team. All rights reserved.
//

import UIKit

class User: NSObject {
    var screenName: String
    var profileImage: NSURL
    
    init(name: String, profile_Image: NSURL) {
        screenName = name
        profileImage = profile_Image
        
        super.init()
    }
}
