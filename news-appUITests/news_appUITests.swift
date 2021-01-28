//
//  news_appUITests.swift
//  news-appUITests
//
//  Created by Vadim Brik on 22.01.2021.
//

import XCTest

class news_appUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
