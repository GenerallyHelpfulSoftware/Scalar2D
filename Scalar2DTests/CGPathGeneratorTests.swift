//
//  CGPathGeneratorTests.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/8/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//
// The MIT License (MIT)

//  Copyright (c) 2016 Generally Helpful Software

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
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
        guard let _ = CGPath.path(fromSVGPath: "") else
        {
            return
        }
        XCTFail("Empty string created cgpath")
    }
    
    func testArc()
    {
        guard let _ = CGPath.path(fromSVGPath: "M0 0 a 20 20 0 1 1 20 0") else
        {
            XCTFail("Arc path not created")
            return
        }
    }
    
    func testBackToString()
    {
        guard let cgPath = CGPath.path(fromSVGPath: "M0 0 L 10 10 H 20 V20 Q 30 30 40 40 C 50 50 60 60 70 70 Z") else
        {
            XCTFail("Beziers not created")
            return
        }
        
        let asString = cgPath.asString()
        XCTAssert(!asString.isEmpty)
        XCTAssertEqual(asString, "M (0.0, 0.0)\nL (10.0, 10.0)\nL (20.0, 10.0)\nL (20.0, 20.0)\nQ (30.0, 30.0, 40.0, 40.0)\nC (50.0, 50.0, 60.0, 60.0, 70.0, 70.0)\nZ\n")
    }
    
    func testArcToString()
    {
        guard let cgPath = CGPath.path(fromSVGPath: "M0 0 a 10 20 30 0 0 10 10 a 20 20 0 0 1 10 10 a 30 30 0 1 1 25 25 a 40 40 0 1 0 20 20") else
        {
            XCTFail("Arc not created")
            return
        }
        
        let asString = cgPath.asString()
        XCTAssert(!asString.isEmpty)
    }
    
    
    func testCubicToArc()
    {
        guard let cgPath = CGPath.path(fromSVGPath: "M 170 207C139 183 40 199 41 109 A18 18 0 1 1 56 75") else
        {
            XCTFail("Arc not created")
            return
        }
        
        let asString = cgPath.asString()
        XCTAssert(!asString.isEmpty)
    }
    
    func testPerformanceLotsOfLines() {
        
        let aPath = "M 0 85 H18 m24 0 H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H42m-24 0 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H18 m24 0 H512 m0 20 H0m0 20H512M 0 85 H18 m24 0 H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H42m-24 0 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H512 m0 20 H0m0 20H18 m24 0 H512 m0 20 H0m0 20H512"
        
        
        self.measure {
            // Put the code you want to measure the time of here.
            let _ = CGPath.path(fromSVGPath: aPath)
            
            
        }
    }
    
    func testPerformanceLotsOfArcs() {
        
        let aPath = "M0 0 a 20 20 0 1 1 20 0 M0 0 a 33 20 34 1 0 20 0 M0 0 a 44 44 23 1 1 20 4 44 44 244 1 0 20 4 44 44 23 0 1 12 4M0 0 a 20 20 0 1 1 20 0 M0 0 a 33 20 34 1 0 20 0 M0 0 a 44 44 23 1 1 20 4 44 44 244 1 0 20 4 44 44 23 0 1 12 4M0 0 a 20 20 0 1 1 20 0 M0 0 a 33 20 34 1 0 20 0 M0 0 a 44 44 23 1 1 20 4 44 44 244 1 0 20 4 44 44 23 0 1 12 4"
        
        
        self.measure {
            // Put the code you want to measure the time of here.
            let _ = CGPath.path(fromSVGPath: aPath)
            
            
        }
    }
    
}
