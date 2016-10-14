//
//  CGColor+ColorParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/8/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
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

import Foundation
import CoreGraphics


public extension Colour
{
    public var cgColor: CGColor?
    {
        switch self
        {
            case .rgb(let red, let green, let blue, _):
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let components = [red, green, blue]
                return CGColor(colorSpace: colorSpace, components: components)
            case .device_rgb(let red, let green, let blue, _):
                let components = [red, green, blue]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                return CGColor(colorSpace: colorSpace, components: components)
            case .device_gray(let gray, _):
                let components = [gray]
                let colorSpace = CGColorSpaceCreateDeviceGray()
                return CGColor(colorSpace: colorSpace, components: components)
            case .device_cmyk(let cyan, let magenta, let yellow, let black, _):
                let components = [cyan, magenta, yellow, black]
                let colorSpace = CGColorSpaceCreateDeviceCMYK()
                return CGColor(colorSpace: colorSpace, components: components)
            case .icc(_, _, _):
                return nil
            case .placeholder(_):
                return nil
            case .transparent(let aColour, let alpha):
                guard  let cgColor = aColour.cgColor else
                {
                    return nil
                }
                return cgColor.copy(alpha: alpha)
        }
    }
}


extension CGColor
{
    private static let standaloneParsers = [
            AnyColourParser(RGBColourParser()),
            AnyColourParser(WebColourParser()),
            AnyColourParser(HexColourParser()),
            AnyColourParser(DeviceRGBColourParser()),
            AnyColourParser(DeviceGrayColourParser()),
            AnyColourParser(DeviceCYMKColourParser())
        ]
    
    static func fromString(string: String) -> CGColor?
    {
        if let aColorDefinition = try? CGColor.standaloneParsers.parseString(source: string,  colorContext: nil)
        {
            return aColorDefinition?.cgColor
        }
        
        return nil
    }
}
