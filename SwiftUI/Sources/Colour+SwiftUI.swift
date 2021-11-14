//
//  File.swift
//  
//
//  Created by Glenn Howes on 7/1/19.
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

#if os(iOS) || os(tvOS) || os(OSX) || os(watchOS)
import Foundation
import CoreGraphics
import SwiftUI
import Scalar2D_Colour

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Colour
{
    /// a SwiftUI Color element as Described by this Colour. Does not support CMYK
    var swiftUIColor: Color?
    {
        switch self
        {
        case .clear:
            return Color(.sRGB, white: 0.0, opacity: 0.0)
        case .rgb(let red, let green, let blue, _):
            return Color(.sRGB, red: Double(red), green: Double(green), blue: Double(blue), opacity: 1.0)
            
        case .device_rgb(let red, let green, let blue, _):
            return Color(.sRGB, red: Double(red), green: Double(green), blue: Double(blue), opacity: 1.0)
            
        case .device_gray(let gray, _):
            return Color(.sRGB, white: Double(gray), opacity: 1.0)
        case .device_cmyk(_, _, _, _, _):
            return nil // unsupported as I don't know how to losslessly create a SwiftUI Color from CMYK
        case .icc(let profileName, let components, _):
            switch profileName
            {
            case "p3":
                var withAlphaComponents = components
                if withAlphaComponents.count == 3
                {
                    withAlphaComponents.append(1.0)
                }
                
                return Color(.displayP3, red: Double(withAlphaComponents[0]), green: Double(withAlphaComponents[1]), blue: Double(withAlphaComponents[2]), opacity: Double(withAlphaComponents[3]))
                
            default:
                return nil
            }
            
        case .placeholder(_):
            return nil
        case .transparent(let aColour, let alpha):
            guard  let swiftColor = aColour.swiftUIColor else
            {
                return nil
            }
            return swiftColor.opacity(Double(alpha))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Color
{
    static private let standaloneParsers = [
        AnyColourParser(RGBColourParser()),
        AnyColourParser(WebColourParser()),
        AnyColourParser(HexColourParser()),
        AnyColourParser(DeviceRGBColourParser()),
        AnyColourParser(DeviceGrayColourParser()),
       // AnyColourParser(DeviceCYMKColourParser()), // don't know how to losslessly make a CYMK into a SwiftUI Color
        AnyColourParser(ICCColourParser()) // only support p3
    ]

    /// init a SwiftUI Color from a string can be any of a wide range of possible formats
    /// example:
    /// let aColor = Color(textual: "icc-color(p3, 0.50, 0.94, 0.94)")!
    /// will return nil if the Scalar2D parsers can't create a Color out of the input
    init?(textual string: String)
    {
        guard let aColorDefinition = ((try? Color.standaloneParsers.parseString(source: string,  colorContext: nil)) as Colour??), let result = aColorDefinition?.swiftUIColor else
        {
            return nil
        }
        
        self = result
    }
}

#endif
