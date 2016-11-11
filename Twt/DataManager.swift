//
//  DataManager.swift
//  Twt
//
//  Created by Tedmob IMac on 11/11/16.
//  Copyright © 2016 iOS Team. All rights reserved.
//

import UIKit

import TwitterKit

import SVProgressHUD

enum TWTSearchState {
    case TWTSearchStateLoading
    case TWTSearchStateNotFound
    case TWTSearchStateRefused
    case TWTSearchStateFailed
    case TWTSearchStateComplete
}

class DataManager: NSObject {
    static let sharedInstance = DataManager()
    
    let accountStore = ACAccountStore()
    
    var searchState:TWTSearchState = .TWTSearchStateRefused
    
    var searchTextString: String?
    
    var nextSearchResultMicroLink: String?
    
    var connection: NSURLSession!
    
    override init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.connection = NSURLSession(configuration: configuration)
        
        super.init()
    }
    
    func loadQuery(forString searchString: String?, count: String, withQueryCompletiomHandler handler: (success:Bool, tweets:[Tweet]?)->Void, twitterAccessHandler: (succes: Bool)->Void){
        // Initialize search state
        searchState = .TWTSearchStateLoading
        
        //let encodedSearch = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        // Prompt the user for permission to their twitter account stored in the phone's settings
        self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
            granted, error in
            if granted {
                if let searchText = searchString{
                    self.searchTextString = searchText
                    
                    // Load user twitter account
                    let twitterAccounts = self.accountStore.accountsWithAccountType(accountType)
                    
                    if twitterAccounts?.count == 0
                    {
                        // Twitter is not logged in
                        self.searchState = .TWTSearchStateNotFound
                        print("User not logged into twitter")
                    }
                    else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            SVProgressHUD.show()
                        })
                        
                        // User is logged into twitter on device
                        let twitterAccount = twitterAccounts[0] as! ACAccount
                        
                        // Load twitter search url
                        let url = "https://api.twitter.com/1.1/search/tweets.json"
                        // Define parameters for search as defined by twitter API
                        let param = [
                            "q": searchText,
                            "result_type": "recent",
                            "count": count
                        ]
                        
                        // Load request
                        let slRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: NSURL(string: url), parameters: param)
                        // Load twitter account into request
                        slRequest.account = twitterAccount
                        
                        // Prepare request for connection
                        let request = slRequest .preparedURLRequest()
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            // Define connection and initalize
                            //self.connection = NSURLConnection(request: request, delegate: self)
                            let task = self.connection.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                                
                                if (error != nil){
                                    //error occured
                                    self.searchState = .TWTSearchStateFailed
                                    handler(success: false, tweets: nil)
                                } else{
                                    //no error
                                    let jsonResults: AnyObject = (try! NSJSONSerialization.JSONObjectWithData(data!, options:  NSJSONReadingOptions.MutableContainers))
                                    
                                    // Save statuses for table use
                                    self.nextSearchResultMicroLink = (jsonResults["search_metadata"] as! NSDictionary)["next_results"] as? String
                                    let data = jsonResults["statuses"] as! NSMutableArray
                                    
                                    //self.results.removeAll()
                                    
                                    var results = Array<Tweet>()
                                    
                                    for tweet in data{
                                        let userProfileImage = NSURL(string: tweet["user"]!!["profile_image_url_https"] as! String)
                                        
                                        let userScreenName = tweet["user"]!!["screen_name"] as! String
                                        
                                        let user = User(name: userScreenName, profile_Image: userProfileImage!)
                                        
                                        let retweets = Int(tweet["retweeted"] as! NSInteger)
                                        
                                        let tweetText = tweet["text"] as! String
                                        
                                        let newTweet = Tweet(aUser: user, numberRetweeted: retweets, text: tweetText)
                                        
                                        results.append(newTweet)
                                    }
                                    
                                    self.searchState = .TWTSearchStateComplete
                                    
                                    handler(success: true, tweets: results)
                                }
                                
                                SVProgressHUD.dismiss()
                            })
                            task.resume()
                            [UIApplication .sharedApplication().networkActivityIndicatorVisible = true]
                        });
                    }
                }
            } else {
                self.searchState = .TWTSearchStateRefused
                handler(success: false, tweets: nil)
                print("Access denied by user")
                twitterAccessHandler(succes: false)
            }
        }
    }
    
    func loadMore(withCompletion handler:(success: Bool, tweets: [Tweet]?)->Void){
        // Initialize search state
        searchState = .TWTSearchStateLoading
        
        //let encodedSearch = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        // Prompt the user for permission to their twitter account stored in the phone's settings
        self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
            granted, error in
            if granted {
                if let _ = self.searchTextString{
                    // Load user twitter account
                    let twitterAccounts = self.accountStore.accountsWithAccountType(accountType)
                    
                    if twitterAccounts?.count == 0
                    {
                        // Twitter is not logged in
                        self.searchState = .TWTSearchStateNotFound
                        print("User not logged into twitter")
                    }
                    else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            SVProgressHUD.show()
                        })
                        
                        // User is logged into twitter on device
                        let twitterAccount = twitterAccounts[0] as! ACAccount
                        
                        // Load twitter search url
                        let url = "https://api.twitter.com/1.1/search/tweets.json"+self.nextSearchResultMicroLink!
                        
                        // Load request
                        let slRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: NSURL(string: url), parameters: nil)
                        // Load twitter account into request
                        slRequest.account = twitterAccount
                        
                        // Prepare request for connection
                        let request = slRequest .preparedURLRequest()
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            // Define connection and initalize
                            //self.connection = NSURLConnection(request: request, delegate: self)
                            let task = self.connection.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                                
                                if (error != nil){
                                    //error occured
                                    self.searchState = .TWTSearchStateFailed
                                } else{
                                    //no error
                                    let jsonResults: AnyObject = (try! NSJSONSerialization.JSONObjectWithData(data!, options:  NSJSONReadingOptions.MutableContainers))
                                    
                                    // Save statuses for table use
                                    self.nextSearchResultMicroLink = (jsonResults["search_metadata"] as! NSDictionary)["next_results"] as? String
                                    let data = jsonResults["statuses"] as! NSMutableArray
                                    
                                    var results = Array<Tweet>()
                                    
                                    for tweet in data{
                                        let userProfileImage = NSURL(string: tweet["user"]!!["profile_image_url_https"] as! String)
                                        
                                        let userScreenName = tweet["user"]!!["screen_name"] as! String
                                        
                                        let user = User(name: userScreenName, profile_Image: userProfileImage!)
                                        
                                        let retweets = Int(tweet["retweeted"] as! NSInteger)
                                        
                                        let tweetText = tweet["text"] as! String
                                        
                                        let newTweet = Tweet(aUser: user, numberRetweeted: retweets, text: tweetText)
                                        
                                        results.append(newTweet)
                                    }
                                    
                                    self.searchState = .TWTSearchStateComplete
                                    
                                    handler(success: true, tweets: results)
                                }
                                
                                SVProgressHUD.dismiss()
                            })
                            task.resume()
                            [UIApplication .sharedApplication().networkActivityIndicatorVisible = true]
                        });
                    }
                }
            } else {
                self.searchState = .TWTSearchStateRefused
                handler(success: false, tweets: nil)
                print("Access denied by user")
            }
        }
    }
}
