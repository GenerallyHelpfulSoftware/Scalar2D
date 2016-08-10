//
//  CGPathGeneratorTests.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/8/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import XCTest
import Scalar2D

class CGPathGeneratorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let _ = CGPath.pathFromSVGPath(svgPath: "") else
        {
            return
        }
        XCTFail("Empty string created cgpath")
    }
    
    func testArc()
    {
        guard let _ = CGPath.pathFromSVGPath(svgPath: "M0 0 a 20 20 0 1 1 20 0") else
        {
            XCTFail("Arc path not created")
            return
        }
        
    }
    
    func testPerformanceLotsOfLines() {
        
        let aPath = "M 0 85 H18 m24 0 H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H42m-24 0 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H18 m24 0 H512 m0 20 H0m0 20H512M 0 85 H18 m24 0 H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H42m-24 0 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H18 m24 0 H512 m0 20 H0m0 20H512"
        
        
        self.measure {
            // Put the code you want to measure the time of here.
            let _ = CGPath.pathFromSVGPath(svgPath: aPath)
            
            
        }
    }
    
    func testPerformanceLotsOfArcs() {
        
        let aPath = "M0 0 a 20 20 0 1 1 20 0 M0 0 a 33 20 34 1 0 20 0 M0 0 a 44 44 23 1 1 20 4 44 44 244 1 0 20 4 44 44 23 0 1 12 4M0 0 a 20 20 0 1 1 20 0 M0 0 a 33 20 34 1 0 20 0 M0 0 a 44 44 23 1 1 20 4 44 44 244 1 0 20 4 44 44 23 0 1 12 4M0 0 a 20 20 0 1 1 20 0 M0 0 a 33 20 34 1 0 20 0 M0 0 a 44 44 23 1 1 20 4 44 44 244 1 0 20 4 44 44 23 0 1 12 4"
        
        
        self.measure {
            // Put the code you want to measure the time of here.
            let _ = CGPath.pathFromSVGPath(svgPath: aPath)
            
            
        }
    }
    
}
