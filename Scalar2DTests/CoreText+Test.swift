//
//  CoreText+Test.swift
//  Scalar2DTests
//
//  Created by Glenn Howes on 1/2/18.
//  Copyright © 2018 Generally Helpful Software. All rights reserved.
//

import XCTest
import Scalar2D

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
