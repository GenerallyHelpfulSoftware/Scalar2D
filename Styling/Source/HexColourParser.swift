//
//  HexColourParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/10/16.
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

public struct HexColourParser : ColourParser
{
    public func deserializeString(textColour: String) throws -> Colour?
    {
        guard textColour.hasPrefix("#") else
        {
            return nil
        }
        let index1 = textColour.index(after:textColour.startIndex)
        
        switch textColour.characters.count
        {
            case 4:
                let hexString = textColour.substring(from: index1)
                let scanner = Scanner(string: hexString)
                var rgbInt = UInt32()
                guard scanner.scanHexInt32(&rgbInt) else
                {
                    return nil
                }
                var blue = Int(rgbInt & 0xF)
                blue = blue + blue << 4
                var green = Int(rgbInt & 0xF0)
                green = green + green >> 4
                var red = Int(0xF & (rgbInt >> 8))
                red = red + red << 4
                return Colour.rgb(red: ColourFloat(red)/255.0, green: ColourFloat(green)/255.0, blue: ColourFloat(blue)/255.0)
            case 7:
                let hexString = textColour.substring(from: index1)
                let scanner = Scanner(string: hexString)
                var rgbInt = UInt32()
                guard scanner.scanHexInt32(&rgbInt) else
                {
                    return nil
                }
                let blue = Int(rgbInt & 0xFF)
                let green = Int((rgbInt >> 8) & 0xFF)
                let red = Int((rgbInt >> 16) & 0xFF)
                
                return Colour.rgb(red: ColourFloat(red)/255.0, green: ColourFloat(green)/255.0, blue: ColourFloat(blue)/255.0)
            default:
                if textColour.characters.count < 4 || textColour.characters.count == 5 || textColour.characters.count == 6
                {
                    throw ColourParsingError.incomplete(textColour)
                }
            else
                {
                    throw ColourParsingError.unknown(textColour)
            }
        }
    }
    
    public init()
    {
    }
}
