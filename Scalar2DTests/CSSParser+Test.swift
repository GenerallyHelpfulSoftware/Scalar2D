//
//  CSSParser+Test.swift
//  Scalar2D
//
//  Created by Glenn Howes on 11/5/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//
//
//
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

class CSSParser_Test: XCTestCase {
    var cssString: String!
    var testBlocks : [StyleBlock]!
    override func setUp() {
        super.setUp()
        let myBundle = Bundle(for: type(of: self))
        let testFile = myBundle.url(forResource: "Test", withExtension: "css")

        cssString = try! String(contentsOf: testFile!)
        
        
        testBlocks = buildTestBlocks()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    fileprivate func buildTestBlocks() -> [StyleBlock]
    {
        let result : [StyleBlock] = [
            StyleBlock(selectors: [StyleSelector(element: .any)],
                       styles: [GraphicStyle(key: "fill", value: "transparent"), GraphicStyle(key: "stroke", hexColour: "#FF0"), GraphicStyle(key: "stroke-width", value:.number(3.0))]),
            
            StyleBlock(selectors: [StyleSelector("text"), StyleSelector("tspan")],
                       styles: [GraphicStyle(key: "font-family", value:.array([.string("Georgia"), .string("system")])), GraphicStyle(key: "font-size", value:.unitNumber(31.0, .point)), GraphicStyle(key: "fill", hexColour: "#FF1")]),
            
            StyleBlock(selectors: [StyleSelector("rect")],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF2"), GraphicStyle(key: "stroke", value: "none")]),
            
            
            StyleBlock(selectors: [StyleSelector(className: "named")],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF3"), GraphicStyle(key: "stroke-width", value: .number(1.0))]),
            
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "path"), identifier: "specified")],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF4"), GraphicStyle(key: "stroke-width", value: .number(3.0))]),
            
            StyleBlock(selectors: [StyleSelector("circle"), StyleSelector("path")],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF5"), GraphicStyle(key: "stroke", webColour: "blue")]),
            
            StyleBlock(combinators: [[.selector(StyleSelector(className: "named")), .descendant, .selector(StyleSelector("path"))]],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF6"), GraphicStyle(key: "stroke", webColour: "green")]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "g"), pseudoClasses: [.first_child])],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF7")]),
            
            
            StyleBlock(combinators: [[.selector(StyleSelector("switch")), .child, .selector(StyleSelector("g")), .child, .selector(StyleSelector("rect"))]],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF8")]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "g"), pseudoClasses: [.nth_child(.odd)])],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FF9"), GraphicStyle(key: "stroke-width", value: .number(5.0)), GraphicStyle(key: "stroke", webColour: "red")]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "g"), pseudoClasses: [.nth_child(.linear(3, 2))])],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FFA"), GraphicStyle(key: "stroke-width", value: .number(2.0)), GraphicStyle(key: "stroke", webColour: "lightblue")]),
            
            StyleBlock(combinators: [[.selector(StyleSelector(className: "named")), .descendant, .selector(StyleSelector(element: .element(name: "rect")
                , pseudoClasses: [.first_of_type]))]],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FFB"), GraphicStyle(key: "stroke", webColour: "darkgray")]),
            
            StyleBlock(combinators: [[.selector(StyleSelector(className: "named")), .descendant, .selector(StyleSelector(element: .element(name: "rect")
                , pseudoClasses: [.last_of_type]))]],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FFC"), GraphicStyle(key: "stroke", webColour: "teal")]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "circle"), pseudoClasses: [.not(StyleSelector(className: "named"))])],
                       styles: [GraphicStyle(key: "fill", hexColour: "#FFD"), GraphicStyle(key: "stroke", webColour: "magenta")]),
            StyleBlock(selectors: [StyleSelector(element: .element(name: "button"), pseudoClasses: [.hover])],
                       styles: [GraphicStyle(key: "fill", hexColour: "#CCC")])
            
        ]
        
        return result
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRemoveComments()
    {
        let testString = "Test/String /*** ** test/ */ a test"
        let strippedString = testString.substringWithoutComments()
        XCTAssertEqual(strippedString, "Test/String  a test")
    }
    
    func testParsing()
    {
        do
        {
            let blocks = try cssString.asStyleBlocks()
            XCTAssert(blocks.count > 0, "Expected css parsed to blocks")
            XCTAssert(blocks.count == self.testBlocks.count, "Expected css parsed to blocks")
            
            for index in 0..<blocks.count
            {
                let parsedBlock = blocks[index]
                let testBlock = self.testBlocks[index]
                
                XCTAssertEqual(parsedBlock, testBlock, "Expected equivalent block at index \(index)")
            }
        }
        catch
        {
            let failureReason = error as? CSSParser.FailureReason
            XCTAssertNotNil(failureReason, "Expected an FailureReason")
            
            XCTFail(failureReason!.description)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
