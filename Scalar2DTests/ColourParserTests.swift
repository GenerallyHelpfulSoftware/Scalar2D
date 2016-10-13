//
//  ColourParserTests.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/11/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import XCTest
import Scalar2D

class ColourParserTests: XCTestCase {
    let allParsers = [
        AnyColourParser(RGBColourParser()),
        AnyColourParser(WebColourParser()),
        AnyColourParser(HexColourParser()),
        AnyColourParser(ICCColourParser()),
        AnyColourParser(DeviceRGBColourParser()),
        AnyColourParser(DeviceGrayColourParser()),
        AnyColourParser(DeviceCYMKColourParser())
    
    ]
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRGB() {
        
        let colorParser = RGBColourParser()
        
        let tests = ["rgb (12%, 244, 10 )", "rgb(1%, 0, 0)"]
        let badTests = ["rgb (.%, 1, 10 )", "rgb(256, -11, 0)", "rgb bad(1.0, 22, 33), rgb(bad, 1.0, 22), rgb(1.0, 1.0), rgb(1.0, ,1.0)"]
        
        do
        {
            for aString in tests
            {
                if let color = try colorParser.deserializeString(source: aString)
                {
                    switch color {
                    case .rgb(red: let red, green: let green, blue: let blue, _):
                        XCTAssertTrue(red > 0 && green <= 255 && blue <= 255)
                    break
                    default:
                        
                        XCTFail("Returned unexpected Colour type")
                    }
                }
                else
                {
                    
                    XCTFail("Returned unexpected nil")
                }
            }
        }
        catch
        {
            XCTFail("Unexpected Parsing Failure")
        }
        do
        {
            for aString in badTests
            {
                let _ = try colorParser.deserializeString(source: aString)
            }
            XCTFail("Expected Parsing Failure")
        }
        catch
        {
        }
        
    }
    
    func testParsingEquatability()
    {
        let equals = [["rgb(255, 255, 255)", "rgb(100%, 100%, 100%)","#FFFFFF", "#FFF", "white"],
                      ["rgb(0, 0, 0)", "rgb(0%, 0%, 0%)", "#000000", "#000", "black"],
                      ["rgb(0, 255, 0)", "rgb(0%, 100%, 0%)", "#00FF00", "#0f0", "lime",],
                      ["rgb(0, 0, 255)", "rgb(0%, 0, 100%)", "#0000FF", "#00f", "blue"],
                      ["rgb(255, 0, 255)", "rgb(100%, 0, 100%)", "#FF00FF", "#F0F", "magenta"],
                      ["rgb(128,0,0)", "#800000", "MAROON"],
                      ["rgb(128,128,0)", "#808000", "olive"],
                      ["rgb(178,34,34)", "#B22222", "firebrick"],
                      ["rgb(240,230,140)", "#F0E68C", "khaki"]
                      ]
        
        for anEquivalentList in equals
        {
            do
            {
                let baseColour = try self.allParsers.parseString(source: anEquivalentList.first!)
                for anEquivalent in anEquivalentList
                {
                    let testColour = try self.allParsers.parseString(source:anEquivalent)
                    XCTAssertEqual(testColour, baseColour, "color string \(anEquivalent) not equal to \(anEquivalentList.first!)")
                }
            }
            catch
            {
                XCTFail("Unexpected Colour Parsing Failure \(anEquivalentList)")
            }
        }
    }
    
    
    func tryBadParsing(badSources:[String])
    {
        for aSource in badSources
        {
            do
            {
                let _ = try self.allParsers.parseString(source: aSource)
                XCTFail("Unexpected Colour Parsing Non-Failure \(aSource)")
            }
            catch
            {
                // good
            }
        }
    }
    
    func tryGoodParsing(goodSources: [String]) -> [Colour]
    {
        var result = [Colour]()
        for aSource in goodSources
        {
            do
            {
                if let aColour = try self.allParsers.parseString(source: aSource)
                {
                   result.append(aColour)
                }
                else
                {
                    XCTFail("Unexpected Colour Parsing Nil for \(aSource)")
                }
            }
            catch
            {
                XCTFail("Unexpected Colour Parsing Failure \(aSource)")
            }
        }
        return result
    }
    
    func testICCParsing()
    {
        let badSources = ["icc-color bad (profile1, 53)", "icc-color(", "icc-color)", "icc-color()", "icc-color(bad)", "icc-color(profile1, 1, 1,)"]
        self.tryBadParsing(badSources: badSources)
        
        let goodSources = ["icc-color(profile1, 44)", "icc-color(profile1, 1, 2, 33.4,33.1       )"]
        let colours = self.tryGoodParsing(goodSources: goodSources)
        for aColour in colours
        {
            switch aColour
            {
                case .icc(let profile, let components, _):
                    XCTAssertTrue(profile == "profile1")
                    XCTAssertTrue(components.count >= 1)
                default:
                    XCTFail("Unexpected Colour \(aColour)")
                
            }
        }
    }
    
    func testGrayDeviceParsing()
    {
        let badSources = ["device-gray bad (.1)", "device-gray(2.0)" , "device-gray(.1, .2)", "device-gray()", "device-gray(bad)", "device-gray(1.0"]
        self.tryBadParsing(badSources: badSources)
        
        let goodSources = ["device-gray(0.0)", "device-gray (  .4  )"]
        
        let colours = self.tryGoodParsing(goodSources: goodSources)
        for aColour in colours
        {
            switch aColour
            {
            case .device_gray(let gray, _):
                XCTAssertTrue(gray >= 0.0 && gray <= 1.0)
            default:
                XCTFail("Unexpected Colour \(aColour)")
                
            }
        }
    }
    
    func testCMYKDeviceParsing()
    {
        let badSources = ["device-cmyk bad (.1, .2, .3, .4)", "device-cmyk(", "device-cmyk)", "device-cmyk()", "device-cmyk(.1, .2, .3, .4, .5)", "device-cmyk(1.1, 2.1, 3.1, 4.1)"]
        self.tryBadParsing(badSources: badSources)
        
        let goodSources = ["device-cmyk(.1, .2, .3, .4)", "device-cmyk(.1, .2, .3,    1.0000   )"]
        let colours = self.tryGoodParsing(goodSources: goodSources)
        for aColour in colours
        {
            switch aColour
            {
            case .device_cmyk(let cyan, let magenta, let yellow, let black, _):
                XCTAssertTrue(cyan == 0.1)
                XCTAssertTrue(magenta > 0.1)
                XCTAssertTrue(yellow > 0.1)
                XCTAssertTrue(black > 0.1)
            default:
                
                XCTFail("Unexpected Colour \(aColour)")
                
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
