//
//  TwtSearchController.swift
//  Twt
//
//  Created by Tedmob IMac on 11/10/16.
//  Copyright © 2016 iOS Team. All rights reserved.
//

import UIKit

class TwtSearchController: UISearchController {

    var _searchBar: TwtSearchBar
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self._searchBar = TwtSearchBar()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(searchResultsController: UIViewController?) {
        self._searchBar = TwtSearchBar()
        super.init(searchResultsController: searchResultsController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var searchBar: UISearchBar {
        return self._searchBar
    }

}
