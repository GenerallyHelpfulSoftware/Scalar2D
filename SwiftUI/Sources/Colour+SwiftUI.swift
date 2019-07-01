//
//  File.swift
//  
//
//  Created by Glenn Howes on 7/1/19.
//


#if os(iOS) || os(tvOS) || os(OSX) || os(watchOS)
import Foundation
import CoreGraphics
import SwiftUI
import Scalar2D_Colour
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Colour
{
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
    
    static  func from(string: String, colorContext: ColorContext? = nil) -> CGColor?
    {
        if let aColorDefinition = ((try? CGColor.standaloneParsers.parseString(source: string,  colorContext: nil)) as Colour??)
        {
            return aColorDefinition?.nativeColour
        }
        
        return nil
    }
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
