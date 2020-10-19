//
//  TweetCellTableViewCell.swift
//  Twitter
//
//  Created by Chenning Li on 10/11/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var tweetContent: UILabel!
    var favorited:Bool = false
    var retweeted:Bool = false
    var tweetId:Int = -1
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func favTweet(_ sender: Any) {
        let toBeFav = !favorited
        if(toBeFav){
            TwitterAPICaller.client?.favTweet(tweetId: tweetId, success: {
                self.setFav(true)
            }, failure: { (Error) in
                print("Favorite did not succeed:\(Error)")
            })
        }
        else{
            TwitterAPICaller.client?.favTweetDestroy(tweetId: tweetId, success: {
                self.setFav(false)
            }, failure: { (Error) in
                print("Unfavorite did not succeed:\(Error)")
            })
        }
    }
    
    @IBAction func reTweet(_ sender: Any) {
        TwitterAPICaller.client?.reTweet(tweetId: tweetId, success: {
            self.setRetweeted(true)
        }, failure: { (Error) in
            print("Retweet did not succeed:\(Error)")
        })
    }
    
    func setRetweeted(_ isRetweeted: Bool){
        if(isRetweeted){
            retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: UIControl.State.normal)
            retweetButton.isEnabled = false
        }
        else {
            retweetButton.setImage(UIImage(named: "retweet-icon-grey"), for: UIControl.State.normal)
            retweetButton.isEnabled = true
        }
    }
    
    func setFav(_ isFavorited:Bool){
        favorited=isFavorited
        if(favorited){
            favButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
        }
        else {
            favButton.setImage(UIImage(named: "favor-icon-grey"), for: UIControl.State.normal)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
