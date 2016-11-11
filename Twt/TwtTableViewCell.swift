//
//  TwtTableViewCell.swift
//  Twt
//
//  Created by Tedmob IMac on 11/10/16.
//  Copyright © 2016 iOS Team. All rights reserved.
//

import UIKit
import ActiveLabel
import SDWebImage

protocol TwtTableViewCellDelegate {
    func tapped(hashtag: String)
}

class TwtTableViewCell: UITableViewCell {
    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var lblUsername: ActiveLabel!
    @IBOutlet weak var lblTweetText: ActiveLabel!
    @IBOutlet weak var lblRetweets: UILabel!
    
    var delegate: TwtTableViewCellDelegate?

    var tweet: Tweet!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(WithObject: Tweet){
        tweet = WithObject
        
        lblUsername.text = WithObject.user.screenName
    
        lblTweetText.text = WithObject.tweetText
        lblTweetText.handleHashtagTap { hashtag in
            self.delegate!.tapped(hashtag)
        }
        
        lblRetweets.text = "\(WithObject.retweeted) retweets"
        
        imgProfilePicture.sd_setImageWithURL(WithObject.user.profileImage, placeholderImage: nil)
    }
}
