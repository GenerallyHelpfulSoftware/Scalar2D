//
//  CSSPropertyTests.swift
//  Scalar2DTests
//
//  Created by Glenn Howes on 9/5/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
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

class CSSPropertyTests: XCTestCase {
    
    var parser : SVGPropertyInterpreter!
    override func setUp() {
        super.setUp()
        parser = SVGPropertyInterpreter()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFontProperty() {
        
        let property = "ultra-condensed italic small-caps bold 16px/1.4 Georgia \"Times New Roman\" serif SAN-SERIF system"
        let buffer = property.unicodeScalars
        
        do
        {
            let (parsed, _) = try parser.interpret(key: "font", buffer: buffer, valueRange: buffer.startIndex..<buffer.endIndex)
            XCTAssertEqual(parsed.count, 7, "Expected 7 got \(parsed.count)")
            XCTAssert(parsed.contains(GraphicStyle(key: "font-size", value: StyleProperty.fontSize(FontSize.pixel(16)))))
            XCTAssert(parsed.contains(GraphicStyle(key: "font-weight", value: StyleProperty.fontWeight(FontWeight.bold))))
            XCTAssert(parsed.contains(GraphicStyle(key: "font-style", value: StyleProperty.fontStyle(FontStyle.italic))))
            XCTAssert(parsed.contains(GraphicStyle(key: "font-variant", value: StyleProperty.fontVariant(FontVariant.smallCaps))))
            XCTAssert(parsed.contains(GraphicStyle(key: "line-height", value: StyleProperty.lineHeight(LineHeight.multiplier(1.4)))))
            XCTAssert(parsed.contains(GraphicStyle(key: "font-stretch", value: StyleProperty.fontStretch(FontStretch.ultraCondensed))))
            
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func propertyTest(named name: String, withPayload payload: String, expectingStyles styles: [GraphicStyle])
    {
        let buffer = payload.unicodeScalars
        do
        {
            let (parsed, _) = try parser.interpret(key: name, buffer: buffer, valueRange: buffer.startIndex..<buffer.endIndex)
            
            XCTAssertEqual(parsed.count, styles.count, "Expected 1 got \(parsed.count)")
            for aStyle in styles
            {
                XCTAssert(parsed.contains(aStyle), "Expected \(aStyle)")
            }
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFillProperty()
    {
        propertyTest(named: "fill", withPayload: "#FF3", expectingStyles: [GraphicStyle(key: "fill", hexColour: "#FF3")])
        propertyTest(named: "fill", withPayload: "black !important", expectingStyles: [GraphicStyle(key: "fill", webColour: "black", important: true)])
        propertyTest(named: "stroke", withPayload: "#FF00FF !important", expectingStyles: [GraphicStyle(key: "stroke", hexColour: "#FF00FF", important: true)])
        propertyTest(named: "stroke-width", withPayload: "5pt", expectingStyles: [GraphicStyle(key: "stroke-width", value: .unitNumber(5, .point))])
        propertyTest(named: "stroke", withPayload: "none", expectingStyles: [GraphicStyle(key: "stroke", value: StyleProperty.colour(Colour.clear, Colour.clear.nativeColour))])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
