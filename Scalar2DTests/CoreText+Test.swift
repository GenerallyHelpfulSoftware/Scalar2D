//
//  CoreText+Test.swift
//  Scalar2DTests
//
//  Created by Glenn Howes on 1/2/18.
//  Copyright © 2018 Generally Helpful Software. All rights reserved.
//
//
//
// The MIT License (MIT)

//  Copyright (c) 2016-2019 Generally Helpful Software

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
@testable import Scalar2D_FontDescription
@testable import Scalar2D_Styling

class CoreText_Test: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCoreText() {
        
        let properties = [StyleProperty.fontFamilies([.named("Times New Roman"), .system, .sansSerif]), .fontSize(FontSize.pixel(12.0)), StyleProperty.fontWeight(.bold)]
        let fontDescription = FontDescription(properties: properties)
        let coreTextDescriptor = fontDescription.coreTextDescriptor()
        
        let attributes = CTFontDescriptorCopyAttributes(coreTextDescriptor) as! Dictionary<AnyHashable, Any>
        XCTAssertTrue(!attributes.isEmpty, "Didn't retrieve core text attributes")
        
        let font = CTFontCreateWithFontDescriptor(coreTextDescriptor, 0.0, nil)
        let fontSize = CTFontGetSize(font)
        XCTAssertEqual(fontSize, 12.0, "Expected size 12 font")
        let fontTraits = CTFontGetSymbolicTraits(font)
        XCTAssertFalse(fontTraits.contains(.boldTrait))
        let postscriptName = CTFontCopyPostScriptName(font) as String
        XCTAssertEqual(postscriptName, "TimesNewRomanPSMT", "Expected TimesNewRomanPSMT as name")
        let familyName = CTFontCopyFamilyName(font) as String
        XCTAssertEqual(familyName, "Times New Roman", "Expected Times New Roman as family name")

    }
    
    func testSmallCaps()
    {
        let properties = [StyleProperty.fontFamilies([.named("HoeflerText-Regular")]), .fontSize(FontSize.pixel(14.0)), .fontVariant(.smallCaps)]
        
        
        let fontDescription = FontDescription(properties: properties)
        let coreTextDescriptor = fontDescription.coreTextDescriptor()
        
        let attributes = CTFontDescriptorCopyAttributes(coreTextDescriptor) as! Dictionary<AnyHashable, Any>
        XCTAssertTrue(!attributes.isEmpty, "Didn't retrieve core text attributes")
        
        
        let font = CTFontCreateWithFontDescriptor(coreTextDescriptor, 0.0, nil)
        let fontSize = CTFontGetSize(font)
        XCTAssertEqual(fontSize, 14.0, "Expected size 14 font")
        
    }
}
