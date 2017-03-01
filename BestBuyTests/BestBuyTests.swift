//
//  BestBuyTests.swift
//  BestBuyTests
//
//  Created by Ben Zatrok on 01/03/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import XCTest
@testable import BestBuy

class BestBuyTests: XCTestCase
{
    //MARK: Variables
    
    var storyboard              : UIStoryboard!
    var searchViewController    : BBSearchViewController!
    
    //MARK: Test Functions
    
    override func setUp()
    {
        super.setUp()
       
        storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BBSearchViewController") as? BBSearchViewController else
        {
            return
        }
        
        searchViewController                = vc
        searchViewController.loadView()
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        storyboard              = nil
        searchViewController    = nil
    }
    
    func testSearchButtonPressWithoutQueryText()
    {
        guard let searchViewController = searchViewController,
            let searchButton = searchViewController.searchButton else
        {
            XCTAssert(false)
            return
        }
        
        searchButton.sendActions(for: .touchUpInside)
        
        XCTAssert(searchViewController.searchBar.isFirstResponder)
    }
    
    func testSearchButtonPressWithQueryText()
    {
        guard let searchViewController = searchViewController,
            let searchButton = searchViewController.searchButton,
            let searchBar = searchViewController.searchBar else
        {
            XCTAssert(false)
            return
        }
        
        searchBar.text = "Macbook"
        searchButton.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 3, handler: nil)
        
        XCTAssert(searchViewController.productsList.count > 0)
    }
    
    func testPerformanceExample()
    {
        self.measure {
            
        }
    }
}
