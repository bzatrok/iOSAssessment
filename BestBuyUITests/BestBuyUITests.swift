//
//  BestBuyUITests.swift
//  BestBuyUITests
//
//  Created by Ben Zatrok on 01/03/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import XCTest

class BestBuyUITests: XCTestCase {
        
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
 
        XCUIApplication().launch()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
}
