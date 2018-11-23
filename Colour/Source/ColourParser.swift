//
//  ColourParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 9/23/16.
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

#if os(iOS) || os(tvOS) || os(OSX)
    public typealias ColourFloat = CGFloat
    public typealias NativeColour = CGColor
#else
    public typealias ColourFloat = Double
    public typealias NativeColor = Any
#endif

public enum ColourParsingError : Error
{
    case unexpectedCharacter(String)
    case incomplete(String)
    case unknown(String)
    case badRange(String)
}

public enum Colour : Equatable, CustomStringConvertible
{
    case clear
    case rgb(red: ColourFloat, green: ColourFloat, blue: ColourFloat, source: String?)
    case device_rgb(red: ColourFloat, green: ColourFloat, blue: ColourFloat, source: String?)
    case device_gray(gray: ColourFloat, source: String?)
    case device_cmyk(cyan: ColourFloat, magenta: ColourFloat, yellow: ColourFloat, black: ColourFloat, source: String?)
    case icc(profileName: String, components: [ColourFloat], source: String?)
    case placeholder(name: String)
    indirect case transparent(Colour: Colour, alpha: ColourFloat)
    
    public static func ==(lhs: Colour, rhs: Colour) -> Bool
    {
        switch(lhs, rhs)
        {
            case (.clear, .clear):
                return true
            case (.rgb(let lhsRed, let lhsGreen, let lhsBlue, _), .rgb(let rhsRed, let rhsGreen, let rhsBlue, _)):
                return lhsRed == rhsRed && lhsGreen == rhsGreen && lhsBlue == rhsBlue
            case (.device_rgb(let lhsRed, let lhsGreen, let lhsBlue, _), .device_rgb(let rhsRed, let rhsGreen, let rhsBlue, _)):
                return lhsRed == rhsRed && lhsGreen == rhsGreen && lhsBlue == rhsBlue
            case (.device_gray(let lhsGray, _), .device_gray(let rhsGray, _)):
                return lhsGray == rhsGray
            case (.device_cmyk(let lhsCyan, let lhsMagenta, let lhsYellow, let lhsBlack, _), .device_cmyk(let rhsCyan, let rhsMagenta, let rhsYellow, let rhsBlack, _)):
                return lhsCyan == rhsCyan && lhsMagenta == rhsMagenta && lhsYellow == rhsYellow && lhsBlack == rhsBlack
            case (.icc(let lhsProfile, let lhsComponents, _), .icc(let rhsProfile, let rhsComponents, _)):
                return lhsProfile == rhsProfile && lhsComponents == rhsComponents
            case (.placeholder(let lhsName), .placeholder(let rhsName)):
                return lhsName == rhsName
            case (.transparent(let lhsColour, let lhsAlpha), .transparent(let rhsColour, let rhsAlpha)):
                return lhsAlpha == rhsAlpha && lhsColour == rhsColour
            default:
                return false
        }
    }
    
    public var source : String?
    {
        get
        {
            switch self
            {
                case .clear:
                    return "none"
                case .rgb(_, _, _, let source):
                    return source
                case .device_rgb(_, _, _, let source):
                    return source
                case .device_gray(_, let source):
                    return source
                case .device_cmyk(_, _, _, _, let source):
                    return source
                case .icc( _, _, let source):
                    return source
                case .placeholder(let name):
                    return name
                case .transparent(let baseColour, _):
                    return baseColour.source
            }
        }
    }
    
    public var asString: String
    {
        if let originalSource = self.source
        {
            return originalSource
        }
        else
        {
            switch self {
                case .clear:
                    return "none"
                case .rgb(let red, let green, let blue, _):
                    return "rgb(\(red*255.0),\(green*255.0),\(blue*255.0))"
                case .device_rgb(let red, let green, let blue, _):
                    return "device-rgb(\(red),\(green),\(blue))"
                case .device_gray(let gray, _):
                    return "device-gray(\(gray))"
                case .device_cmyk(let cyan, let magenta, let yellow, let black, _):
                    return "device-cmyk(\(cyan),\(magenta),\(yellow),\(black))"
                case .icc(let profileName, let components, _):
                    return "icc-color(\(profileName), \(components.map{String(describing: $0)}.joined(separator: ",")))"
                case .placeholder(let name):
                    return name
                case .transparent(let aColour, _):
                    return aColour.asString
            }
        }
    }
    
    public var description: String
    {
        var enumString: String!
        switch self
        {
            case .placeholder(let name):
                enumString = "placeholder: \(name)"
            case .transparent(let aColour, let alpha):
                enumString = "transparent: \(aColour.asString), alpha: \(alpha)"
            default:
                enumString = self.asString
        }
        return "<Colour \(enumString!)>"
    }
    
}

public typealias ColourTable = [String: Colour]


public protocol ColorContext {
    func profileNamed(name: String) -> Data?
}

public protocol ColourParser
{
    // It's assumed that source is in lowercase
    func deserializeString(source: String, colorContext: ColorContext?) throws -> Colour?
}


public struct AnyColourParser : ColourParser
{
    private let _deserialize: (_ source: String, _ colorContext: ColorContext?) throws -> Colour?
    
    public init<Base: ColourParser>(_ base: Base)
    {
        _deserialize = base.deserializeString
    }
    
    public func deserializeString(source: String, colorContext: ColorContext? = nil) throws -> Colour? {
        return try self._deserialize(source, colorContext)
    }

}

public extension Array where Element : ColourParser
{
    public func parseString(source: String, colorContext: ColorContext?) throws -> Colour?
    {
        var result : Colour?
        let normalizedsource = source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        for aParser in self
        {
            if let testResult = try aParser.deserializeString(source: normalizedsource, colorContext: nil)
            {
                result = testResult
                break
            }
        }
        return result
    }
}

