//
//  PathGeneratorTests.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/7/16.
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

class PathGeneratorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimple() {
        let pathString = "M 170 207C139 183 40 199 41 109A18 18 0 1 1 56 75Q67 53 91 45A18 18 0 1 1 127 40C170 29 193 62 212 173L225 110Q241 70 252 120L253 156 C253 180 265 223 235 214Q210 210 215 242 C222 265 161 249 125 248z"
        
        do
        {
            let tokens = try pathString.asPathTokens()
            XCTAssertEqual(tokens.count, 13)
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLeadingPeriodSeparator()
    {
        
        let stressfullSeparators = "M0,0L.1.2.1.2ZM0,0 L1.2 3 .4 5.6 z"
        do
        {
            let tokens = try stressfullSeparators.asPathTokens()
            XCTAssertEqual(tokens.count, 8)
            
            XCTAssertEqual(tokens[0].operand, "M")
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSeparators()
    {
        let stressfullSeparators = " \tM-20.2.35,L+33-21.2.4e2-44-22+21 .1 0.1"
        do
        {
            let tokens = try stressfullSeparators.asPathTokens()
            XCTAssertEqual(tokens.count, 5)
            
            XCTAssertEqual(tokens[0].operand, "M")
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAllOperands()
    {
        let allOperandsPath = "M 0 0 m 5 5 L 10 10 l 20 20 h 30 H 40 v 50 V 60 q 70 70 80 80 Q 90 90 100 100 t 110 110 T 120 120 C 130 130 140 140 150 150 c 170 170 180 180 190 190 S 200 200 210 210 s 220 220 230 230 A 240 240 250 0 0 260 260 a 270 270 280 1 1 290 290 z"
        
        do
        {
            let tokens = try allOperandsPath.asPathTokens()
            XCTAssertEqual(tokens.count, 19)
            
            XCTAssertEqual(tokens[0].operand, "M")
            XCTAssertEqual(tokens[1].operand, "m")
            XCTAssertEqual(tokens[2].operand, "L")
            XCTAssertEqual(tokens[3].operand, "l")
            XCTAssertEqual(tokens[4].operand, "h")
            XCTAssertEqual(tokens[5].operand, "H")
            XCTAssertEqual(tokens[6].operand, "v")
            XCTAssertEqual(tokens[7].operand, "V")
            XCTAssertEqual(tokens[8].operand, "q")
            XCTAssertEqual(tokens[9].operand, "Q")
            XCTAssertEqual(tokens[10].operand, "t")
            XCTAssertEqual(tokens[11].operand, "T")
            XCTAssertEqual(tokens[12].operand, "C")
            XCTAssertEqual(tokens[13].operand, "c")
            XCTAssertEqual(tokens[14].operand, "S")
            XCTAssertEqual(tokens[15].operand, "s")
            XCTAssertEqual(tokens[16].operand, "A")
            XCTAssertEqual(tokens[17].operand, "a")
            XCTAssertEqual(tokens[18].operand, "z")
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testImpliedOperands()
    {
        let pathString = "M0 0 10 10 20 20z"
        
        do
        {
            let tokens = try pathString.asPathTokens()
            
            XCTAssertEqual(tokens.count, 4)
            
            XCTAssertEqual(tokens[0].operand, "M")
            XCTAssertEqual(tokens[1].operand, "L")
            XCTAssertEqual(tokens[2].operand, "L")
            XCTAssertEqual(tokens[3].operand, "z")
            
            
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    
    func testImpliedOperands1()
    {
        let pathString = "m0 0 10 10 20 20z"
        
        do
        {
            let tokens = try pathString.asPathTokens()
            
            XCTAssertEqual(tokens.count, 4)
            
            XCTAssertEqual(tokens[0].operand, "M")
            XCTAssertEqual(tokens[1].operand, "L")
            XCTAssertEqual(tokens[2].operand, "L")
            XCTAssertEqual(tokens[3].operand, "z")
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testImpliedOperands2()
    {
        let pathString = "M 0 10 l 10 20 20 44 z"
        
        do
        {
            let tokens = try pathString.asPathTokens()
            
            XCTAssertEqual(tokens.count, 4)
            
            XCTAssertEqual(tokens[0].operand, "M")
            XCTAssertEqual(tokens[1].operand, "l")
            XCTAssertEqual(tokens[2].operand, "l")
            XCTAssertEqual(tokens[3].operand, "z")
            
            
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testEdges()
    {
        let pathString = "   M 170, 207C-139+183 40E+1 199 41 109             "
        
        do
        {
            let tokens = try pathString.asPathTokens()
            XCTAssertEqual(tokens.count, 2)
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testNoLeadingMove()
    {
        let noLeadingMovePath = "C139 183 40 199 41 109"
        
        do
        {
            _ = try noLeadingMovePath.asPathTokens()
            XCTFail("Should have a leading move operand")
        }
        catch
        {
        }
    }
    
    func testNotACompleteNumber1()
    {
        let incompleteNumberPath = "M 170 207C+ 183 40 199 41 109"
        
        do
        {
            _ = try incompleteNumberPath.asPathTokens()
            XCTFail("C+  should fail")
        }
        catch
        {
        }
    }
    
    func testNotACompleteNumber2()
    {
        let incompleteNumberPath = "M 170 207C -. 183 40 199 41 109"
        
        do
        {
            _ = try incompleteNumberPath.asPathTokens()
            XCTFail("-.  should fail")
        }
        catch
        {
        }
    }
    
    func testNotACompleteNumber3()
    {
        let incompleteNumberPath = "M 170 207C 139.5E 183 40 199 41 109"
        
        do
        {
            _ = try incompleteNumberPath.asPathTokens()
            XCTFail("139.5E  should fail")
        }
        catch
        {
        }
    }
    
    func testBadlyFormedNumber1() {
        let pathString = "M 170 207C139 ++183 40 199 41 109"
        
        do
        {
            _ =  try pathString.asPathTokens()
            XCTFail("++183.  should fail")
        }
        catch
        {
        }
    }
    
    func testBadlyFormedNumber2()
    {
        let badNumberPath = "M 170 207C 139E. 183 40 199 41 109"
        
        do
        {
            _ = try badNumberPath.asPathTokens()
            XCTFail("139E.  should fail")
        }
        catch
        {
        }
    }
    
    func testMissingParameter()
    {
        let missingParameterPath = "M 170 207C139 183 40 199 41 z"
        
        do
        {
            _ = try missingParameterPath.asPathTokens()
            XCTFail("C missing a parameter")
        }
        catch
        {
        }
    }
    
    func testUnknownOperand()
    {
        let whatsAGPath = "M 170 207 G139 183 40 199 41 8"
        
        do
        {
            _ = try whatsAGPath.asPathTokens()
            XCTFail("G is not an SVG Path Operand (that I know of)")
        }
        catch
        {
        }
    }
    
    func testBadNumberCharacter()
    {
        let whyApPath = "M 170 207C139 1p3 40 199 41 Z"
        
        do
        {
            _ = try whyApPath.asPathTokens()
            XCTFail("p doesn't belong in SVG paths")
        }
        catch
        {
        }
    }
    
    func testBadArcFlag()
    {
        let badFlagArcPath = "M 170 207a 40 40 45 1 2 220 209 Z"
        
        do
        {
            _ = try badFlagArcPath.asPathTokens()
            XCTFail("flags should be 1 or 0 not 2")
        }
        catch
        {
        }
    }
    
    func testBadArcFlag2()
    {
        let badFlagArcPath = "M 170 207a 40 40 45 5-1 0 220 209 Z"
        
        do
        {
            _ = try badFlagArcPath.asPathTokens()
            XCTFail("flags should be 1 or 0 not -1")
        }
        catch
        {
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
