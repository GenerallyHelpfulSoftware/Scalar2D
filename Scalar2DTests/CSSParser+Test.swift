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
        // These correspond to the items in Test.css
        let result : [StyleBlock] = [
            StyleBlock(selectors: [StyleSelector(element: .any)],
                       styles: [GraphicStyle(key: .fill, webColour: "transparent"), GraphicStyle(key: .stroke, hexColour: "#FF0"), GraphicStyle(key: .stroke_width, value:.number(3.0))]),
            
            StyleBlock(selectors: [StyleSelector("text"), StyleSelector("tspan")],
                       styles: [GraphicStyle(key: .font_family, value:.fontFamilies([FontFamily.named("Georgia"), FontFamily.system])), GraphicStyle(key: .font_size, value:.fontSize(.point(31.0))),
                                GraphicStyle(key: .font_weight, value: .fontWeight(.bold)),
                                GraphicStyle(key: .fill, hexColour: "#FF1"),
                                GraphicStyle(key: .font_stretch, value: .fontStretch(.extraExpanded)),
                
                ]),
            
            StyleBlock(selectors: [StyleSelector("rect")],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FF2"), GraphicStyle(key: .stroke, webColour:"none")]),
            
            
            StyleBlock(selectors: [StyleSelector(className: "named")],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FF3"), GraphicStyle(key: .stroke_width, value: .number(1.0))]),
            
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "path"), identifier: "specified")],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FF4"),
                                GraphicStyle(key: .stroke_width, value: .number(3.0)),
                                GraphicStyle(key: .stroke_line_cap, value: .lineCap(.square)),
                                GraphicStyle(key: .stroke_line_join, value: .lineJoin(.miter)),
                                GraphicStyle(key: .stroke_miter_limit, value: .number(3.0)),
                                GraphicStyle(key: .stroke_dash_offset, value: StyleProperty.unitNumber(UnitDimension(dimension: 75.0, unit: .percent))),
                                GraphicStyle(key: .stroke_dash_array, value:StyleProperty.dimensionArray([UnitDimension(dimension: 10.0, unit: .percent), UnitDimension(dimension: 20.0, unit: .percent)]))
                ]),
            
            StyleBlock(selectors: [StyleSelector("circle"), StyleSelector("path")],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FF5"), GraphicStyle(key: .stroke, webColour: "blue")]),
            
            StyleBlock(combinators: [[.selector(StyleSelector(className: "named")), .descendant, .selector(StyleSelector("path"))]],
                       styles:
                        [GraphicStyle(key: .fill, hexColour: "#FF6"),
                         GraphicStyle(key: .stroke, webColour: "green")
                
                ]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "g"), pseudoClasses: [.first_child])],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FF7"),
                                GraphicStyle(key: .background_color, webColour: "orange"),
                                GraphicStyle(key: .view_border_style, value: StyleProperty.border([BorderRecord(types: BorderTypes.horizontal, style: .initial), BorderRecord(types: [BorderTypes.vertical], style: .empty)])),
                                GraphicStyle(key: .view_border_width, value: StyleProperty.border([BorderRecord(types: [BorderTypes.horizontal], width: .custom(UnitDimension(dimension: 3.0, unit: .pixel))), BorderRecord(types: [BorderTypes.vertical], width: .thick)]))
                                
                ]),
            
            
            StyleBlock(combinators: [[.selector(StyleSelector("switch")), .child, .selector(StyleSelector("g")), .child, .selector(StyleSelector("rect"))]],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FF8")]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "g"), pseudoClasses: [.nth_child(.odd)])],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FF9"), GraphicStyle(key: .stroke_width, value: .number(5.0)), GraphicStyle(key: .stroke, webColour: "red")]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "g"), pseudoClasses: [.nth_child(.linear(3, 2))])],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FFA"), GraphicStyle(key: .stroke_width, value: .number(2.0)), GraphicStyle(key: .stroke, webColour: "lightblue")]),
            
            StyleBlock(combinators: [[.selector(StyleSelector(className: "named")), .descendant, .selector(StyleSelector(element: .element(name: "rect")
                , pseudoClasses: [.first_of_type]))]],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FFB"), GraphicStyle(key: .stroke, webColour: "darkgray")]),
            
            StyleBlock(combinators: [[.selector(StyleSelector(className: "named")), .descendant, .selector(StyleSelector(element: .element(name: "rect")
                , pseudoClasses: [.last_of_type]))]],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FFC"), GraphicStyle(key: .stroke, webColour: "teal")]),
            
            StyleBlock(selectors: [StyleSelector(element: .element(name: "circle"), pseudoClasses: [.not(StyleSelector(className: "named"))])],
                       styles: [GraphicStyle(key: .fill, hexColour: "#FFD"), GraphicStyle(key: .stroke, webColour: "magenta")]),
            StyleBlock(selectors: [StyleSelector(element: .element(name: "button"), pseudoClasses: [.hover])],
                       styles: [GraphicStyle(key: .fill, hexColour: "#CCC")])
            
        ]
        
        return result
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectorFromString()
    {
        var css = "g"
        do
        {
            var parsed = try StyleSelector(css: css)
            var testValue = StyleSelector(element: .element(name: "g"))
        
            XCTAssertEqual(parsed, testValue, "\(css) not parsed correctly")
            
            css = "*.glenn:nth-child(4 n -5)"
            
            parsed = try StyleSelector(css: css)
            testValue = StyleSelector(element: .any, identifier: nil, className: "glenn", pseudoClasses: [.nth_child(.linear(4, -5))])
            
            XCTAssertEqual(parsed, testValue, "\(css) not parsed correctly")
            
            
            
            css = ":not(*.glenn:nth-child(4 n -5))"
            
            parsed = try StyleSelector(css: css)
            testValue = StyleSelector(element: .none, pseudoClasses: [.not(testValue)])
            
            XCTAssertEqual(parsed, testValue, "\(css) not parsed correctly")
            
            
            css = "rect#glenn:hover::before"
            
            parsed = try StyleSelector(css: css)
            testValue = StyleSelector(element: .element(name: "rect"), identifier: "glenn", pseudoClasses: [.hover], pseudoElement: .before)
            
            XCTAssertEqual(parsed, testValue, "\(css) not parsed correctly")
        
        }
        catch
        {
            XCTFail("\(css) failed \(error)")
        }
    }
    
    
    func testBadSelectorFromString()
    {
        XCTAssertThrowsError(try StyleSelector(css: "**"), "Didn't throw **")
        XCTAssertThrowsError(try StyleSelector(css: "-9"), "Didn't throw -9")
        XCTAssertThrowsError(try StyleSelector(css: ":nth-child(1 n 9"), "Didn't throw :nth-child(1 n 9")
        XCTAssertThrowsError(try StyleSelector(css: "::after::before"), "Didn't throw :after::before 2 pseudoelements")
        XCTAssertThrowsError(try StyleSelector(css: "::after::before"), "Didn't throw :after::before 2 pseudoelements")
    }
    
    func testCombinatorFromString()
    {
        var css = " g .glenn:nth-child(5) >> #bob"
        do
        {
            var parsed = try SelectorCombinator.parse(css: css)
            var testValue = [SelectorCombinator.selector(StyleSelector(element: .element(name: "g"))), .descendant, .selector(StyleSelector(element: .none, className: "glenn", pseudoClasses: [.nth_child(.nth(5))])), .descendant, .selector(StyleSelector(element: .none, identifier: "bob"))]
            
            XCTAssertEqual(parsed!, testValue, "\(css) not parsed correctly")
            
            css = "text + circle:first-child"
            parsed = try SelectorCombinator.parse(css: css)
            testValue = [SelectorCombinator.selector(StyleSelector(element: .element(name: "text"))), .adjacentSibling, .selector(StyleSelector(element: .element(name: "circle"),  pseudoClasses: [.first_child]))]
            XCTAssertEqual(parsed!, testValue, "\(css) not parsed correctly")

        }
        catch
        {
            XCTFail("\(css) failed \(error)")
        }
    }
    
    func testBadCombinatorFromString()
    {
        XCTAssertThrowsError(try SelectorCombinator.parse(css: "* ++ .glenn"), "Didn't throw * ++ .glenn")
        XCTAssertThrowsError(try SelectorCombinator.parse(css: "g > > g"), "g > > g")
    }
    
    func testGroupSelectorFromString()
    {
        let css = " g .glenn:nth-child(5) >> #bob,div.john   "
        do
        {
            if let parsed = try GroupSelector.parse(css: css)
            {
                let testValue = [[SelectorCombinator.selector(StyleSelector(element: .element(name: "g"))), .descendant, .selector(StyleSelector(element: .none, className: "glenn", pseudoClasses: [.nth_child(.nth(5))])), .descendant, .selector(StyleSelector(element: .none, identifier: "bob"))],
                             [SelectorCombinator.selector(StyleSelector(element: .element(name: "div"), className: "john"))]] as GroupSelector
            
                XCTAssertEqual(parsed.count, testValue.count, "Got \(parsed.count), expected \(testValue.count) GroupSelectors")
                for index in 0..<parsed.count
                {
                    let test = testValue[index]
                    let parsedValue = parsed[index]
                    XCTAssertEqual(parsedValue, test, "\(css) not parsed correctly")
                }
            }
            else
            {
                XCTAssertNotNil(nil, "Didn't parse \(css)")
            }
        }
        catch
        {
            XCTFail("\(css) failed \(error)")
        }
    }
    
    
    func testParsing()
    {
        do
        {
            let parser = CSSParser(propertyInterpreter: ViewStyleInterpreter())
            let blocks = try parser.parse(cssString: cssString)
            XCTAssert(blocks.count > 0, "Expected css parsed to blocks")
            XCTAssert(blocks.count == self.testBlocks.count, "Expected css parsed to blocks")
            
            for index in 0..<blocks.count
            {
                let parsedBlock = blocks[index]
                let testBlock = self.testBlocks[index]
                
                let parsedSelector = parsedBlock.combinators
                let testSelector = testBlock.combinators
                
                let parsedValues = parsedBlock.styles
                let testValues = testBlock.styles
            
                XCTAssertEqual(parsedSelector.count, testSelector.count, "Difference in selector count test:\(testSelector.count), parsed: \(parsedSelector.count) at index \(index)")
                XCTAssertEqual(testValues.count, parsedValues.count, "Difference in value count test:\(testValues.count), parsed: \(parsedValues.count) at index \(index)")
            
                for selectorIndex in 0..<parsedSelector.count
                {
                    let testCombinators = testSelector[selectorIndex]
                    let parsedCombinators = parsedSelector[selectorIndex]
                    
                    XCTAssertEqual(testCombinators.count, parsedCombinators.count, "Difference in combinator count test:\(testCombinators.count), parsed: \(parsedCombinators.count) at index \(index), selectorIndex: \(selectorIndex)")
                    if testCombinators.count == parsedCombinators.count
                    {
                        for combinatorIndex in 0..<testCombinators.count
                        {
                            let testCombinator = testCombinators[combinatorIndex]
                            let parsedCombinator = parsedCombinators[combinatorIndex]
                            
                            XCTAssertEqual(testCombinator, parsedCombinator, "Difference in combinator at index: \(index), selectorIndex: \(selectorIndex), combinatorIndex: \(combinatorIndex)")
                        }
                    }
                }
                
                
                XCTAssertEqual(parsedValues.count, testValues.count, "Difference in values count test:\(testValues.count), parsed: \(parsedValues.count) at index \(index)")
                if parsedValues.count == testValues.count
                {
                    for valueIndex in 0..<parsedValues.count
                    {
                        let parsedValue = parsedValues[valueIndex]
                        let testValue = testValues[valueIndex]
                        
                        XCTAssertEqual(parsedValue.key, testValue.key, "Value key mismatch at index: \(index), \(parsedValue.key) should be \(testValue.key)")
                        XCTAssertEqual(parsedValue.important, testValue.important, "Value importatant mismatch at index: \(index), \(parsedValue.important) should be \(testValue.important)")
                        XCTAssertEqual(parsedValue.value, testValue.value, "Value value mismatch at index: \(index). \(parsedValue.value) should be \(testValue.value)")
                    }
                }
            }
        }
        catch
        {
            if let bufferParseError = error as? ParseBufferError
            {
                XCTFail(bufferParseError.description(forBuffer: cssString.unicodeScalars))
            }
            else
            {
                let failureReason = error as CustomStringConvertible
                XCTAssertNotNil(failureReason, "Expected an FailureReason")
                XCTFail(failureReason.description)
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
