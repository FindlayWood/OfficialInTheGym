//
//  SearchViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SearchViewController: UIViewController {

    var display = SearchView()
    
    var viewModel = SearchViewModel()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}


// MARK: - IMPORTANT!
/// Text search is not supported by Firebase which makes this feature tricky
/// They have some suggestions to use third parties to search but these seem to be for Firestore and cost money
/// So the only solution i can see that might work is as follows
///
/// Create three separate searches for firstname, lastname and username using the below method
/// Ending the query with uf8ff is a very high code point in the Unicode range and it is after most regular characters in Unicode
///
/// databaseReference.orderByChild('_searchFirstName')
///    .startAt(queryText)
///    .endAt(queryText+"uf8ff")
