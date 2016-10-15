//
//  CGColor+Test.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/14/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import XCTest

class CGColor_Test: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testColorCreation() {
        let goodColors = ["device-rgb(1.0, 0.0, 0.5)", "device-cmyk(1.0, 0.5, 0.5, 0.5)", "rgb(1.0, 0.0, 0.0)", "#FFF", "#AABBCC", "icc-color(p3, 1.0, 0.0, 1.0)"]
        
        for aColorDefinition in goodColors
        {
            XCTAssertNotNil(CGColor.fromString(string: aColorDefinition), "Expected a CGColor for \(aColorDefinition)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
