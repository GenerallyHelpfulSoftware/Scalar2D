//
//  CGColor+ColorParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/8/16.
//  Copyright © 2016-2019 Generally Helpful Software. All rights reserved.
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

#if os(iOS) || os(tvOS) || os(OSX) || os(watchOS)
import Foundation
import CoreGraphics

public extension Colour
{
    /// the CGColor described by this color or nil if can't be created
    var nativeColour: CGColor?
    {
        switch self
        {
            case .clear:
                let components = [CGFloat(0.0), 0.0]
                let colorSpace = CGColorSpaceCreateDeviceGray()
                return CGColor(colorSpace: colorSpace, components: components)
            case .rgb(let red, let green, let blue, _):
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let components = [red, green, blue, 1.0]
                return CGColor(colorSpace: colorSpace, components: components)
            case .device_rgb(let red, let green, let blue, _):
                let components = [red, green, blue, 1.0]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                return CGColor(colorSpace: colorSpace, components: components)
            case .device_gray(let gray, _):
                let components = [gray, 1.0]
                let colorSpace = CGColorSpaceCreateDeviceGray()
                return CGColor(colorSpace: colorSpace, components: components)
            case .device_cmyk(let cyan, let magenta, let yellow, let black, _):
                let components = [cyan, magenta, yellow, black, 1.0]
                let colorSpace = CGColorSpaceCreateDeviceCMYK()
                return CGColor(colorSpace: colorSpace, components: components)
            case .icc(let profileName, let components, _):
                switch profileName
                {
                    case "p3":
                        if let colorSpace = CGColorSpace(name: CGColorSpace.displayP3)
                        {
                            var withAlphaComponents = components
                            if withAlphaComponents.count == 3
                            {
                                withAlphaComponents.append(1.0)
                            }
                            
                            return CGColor(colorSpace: colorSpace, components: withAlphaComponents)
                        }
                    default:
                        return nil
                }
            
            case .placeholder(_):
                return nil
            case .transparent(let aColour, let alpha):
                guard  let cgColor = aColour.nativeColour else
                {
                    return nil
                }
                return cgColor.copy(alpha: alpha)
        }
        return nil 
    }
    
    func toCGColorWithColorContext(_ colorContext: ColorContext? = nil) ->CGColor?
    {
        guard let cgColor = self.nativeColour else
        {
            var result: CGColor? = nil
            
            if let context = colorContext , case .icc(let name, let components, _) = self
            {
                if let profileData = context.profileNamed(name: name)
                {
                    if #available(OSX 10.12, iOS 10, *) {
                        let colorSpace = CGColorSpace(iccData: profileData as CFData)
                        result = CGColor(colorSpace: colorSpace, components: components)
                    } else {
                        return nil
                        // Fallback on earlier versions
                    }
                    
                }
            }
            return result
        }
        return cgColor
    }
}


extension CGColor
{
     static public let standaloneParsers = [
            AnyColourParser(RGBColourParser()),
            AnyColourParser(WebColourParser()),
            AnyColourParser(HexColourParser()),
            AnyColourParser(DeviceRGBColourParser()),
            AnyColourParser(DeviceGrayColourParser()),
            AnyColourParser(DeviceCYMKColourParser()),
            AnyColourParser(ICCColourParser())
        ]
    
    static public func from(string: String, colorContext: ColorContext? = nil) -> CGColor?
    {
        if let aColorDefinition = ((try? CGColor.standaloneParsers.parseString(source: string,  colorContext: nil)) as Colour??)
        {
            return aColorDefinition?.nativeColour
        }
        
        return nil
    }
}
#endif
