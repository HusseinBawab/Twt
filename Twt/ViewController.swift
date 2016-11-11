//
//  ViewController.swift
//  Twt
//
//  Created by Tedmob IMac on 11/10/16.
//  Copyright © 2016 iOS Team. All rights reserved.
//

import UIKit
import TwitterKit
import SVProgressHUD

class ViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, TwtTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var btnSettings: UIBarButtonItem!
    
    var results = Array<Tweet>()
    
    let filters : [String] = ["No Refresh", "2 Seconds", "5 Seconds", "30 Seconds", "1 Minute"]
    
    let refreshCollection = [0,2,5,30,60]
    
    var refreshRate = 30
    
    var tempRefreshRate = 30
    
    var picker: HBPickerView!
    
    var searchController: TwtSearchController!
    
    var searchResults = Array<AnyObject>()
    
    var searchString:String?
    
    var isRefreshing = false
    
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.hidden = true

        setupSearchController()
        
        setupNavigationBar()
        
        setupPickerView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set Up
    func setupSearchController(){
        searchController = TwtSearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
    }
    
    func setupNavigationBar(){
        btnSettings = UIBarButtonItem(title: "Settings", style: .Done, target: self, action: #selector(self.settingsButtonTapped(_:)))
        btnSettings.title = "Settings"
        navigationItem.rightBarButtonItems = [btnSettings]
        setupPickerView()
    }
    
    func settingsButtonTapped(sender: UIBarButtonItem) {
        picker.presentPicker()
        picker.selectedPicker(refreshCollection.indexOf(refreshRate)!)
    }
    
    func setupPickerView(){
        picker = HBPickerView(parent: self)
        picker.hasToolbar = true
        picker.hasBackgroundBlur = true
        
        picker!.pickerNumberOfRows = { component in
            return self.filters.count
        }
        
        picker!.pickerNumberOfComponents = {
            return 1
        }
        
        picker!.pickerRowTitle = { forRow, inComponent in
            return self.filters[forRow]
        }
        
        picker!.pickerDidSelect = { row, component in
            self.tempRefreshRate = self.refreshCollection[row]
        }
        
        picker!.didDismiss = { flag in
            if self.refreshRate != self.tempRefreshRate{
                self.refreshRate = self.tempRefreshRate
                
                if self.refreshRate == 0{
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.isRefreshing = true
                        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                        self.refreshControl.addTarget(self, action: #selector(self.loadQuery), forControlEvents: UIControlEvents.ValueChanged)
                        self.tableView?.addSubview(self.refreshControl)
                    })
                } else{
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.isRefreshing = false
                        self.refreshControl.removeFromSuperview()
                        NSTimer.scheduledTimerWithTimeInterval(Double(self.refreshRate), target: self, selector: #selector(self.refresh), userInfo: nil, repeats: false)
                    })
                }
            }
        }
    }
    
    // MARK: Queries & Refresh
    func refresh(){
        if DataManager.sharedInstance.searchState == .TWTSearchStateComplete{
            isRefreshing = true
            loadQuery()
        } else{
            if !isRefreshing{
                NSTimer.scheduledTimerWithTimeInterval(Double(self.refreshRate), target: self, selector: #selector(self.refresh), userInfo: nil, repeats: false)
            }
        }
    }
    
    func loadQuery(){
        let count = self.results.count > 0 ? "\(self.results.count)" : "10"
        
        DataManager.sharedInstance.loadQuery(forString: searchString, count: count, withQueryCompletiomHandler: { (success, tweets) in
            if success{
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.searchController.active = false
                    
                    self.refreshControl.endRefreshing()
                    self.results.removeAll()
                    self.results.appendContentsOf(tweets!)
                    if self.results.count == 0{
                        self.tableView.hidden = true
                    } else{
                        self.tableView.reloadData()
                        self.tableView.hidden = false
                    }
                    if self.isRefreshing{
                        self.isRefreshing = false
                        if self.refreshRate != 0{
                            NSTimer.scheduledTimerWithTimeInterval(Double(self.refreshRate), target: self, selector: #selector(self.refresh), userInfo: nil, repeats: false)
                        }
                    }
                })
            }
            }) { (succes) in
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    let alert = UIAlertController(title: "Twiter Access Denied", message: "Please Enable Twitter Access in Settings", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
        }
    }
    
    func loadMore(){
        DataManager.sharedInstance.loadMore { (success, tweets) in
            if success{
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.tableView.hidden = false
                    self.results.appendContentsOf(tweets!)
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    //MARK: UITableViewDatasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweet", forIndexPath: indexPath) as! TwtTableViewCell
        
        cell.setupCell(self.results[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
            //you reached end of the table
            if self.results.count > 0{
                loadMore()
            }
        }
    }
    
    //MARK: TwtTableViewCellDelegate Methods
    func tapped(hashtag: String) {
        searchString = "#\(hashtag)"
        self.results.removeAll()
        self.tableView.reloadData()
        loadQuery()
    }
    
    // MARK: UISearchResultsUpdating Methods
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: UISearchBarDelegate Methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text{
            searchController.searchBar.endEditing(true)
            searchController.dismissViewControllerAnimated(true, completion: {
                self.searchString = "#\(searchText)"
                self.loadQuery()
            })
        }
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        navigationItem.rightBarButtonItems = [btnSettings]
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        navigationItem.rightBarButtonItems?.append(btnSettings)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
    }
}

