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
#else
    public typealias ColourFloat = Double
#endif

public enum ColourParsingError : Error
{
    case unexpectedCharacter(String)
    case incomplete(String)
    case unknown(String)
    case badRange(String)
}

public enum Colour : Equatable
{
    case monochrome(ColourFloat)
    case rgb(red: ColourFloat, green: ColourFloat, blue: ColourFloat)
    case cymk(cyan: ColourFloat, yellow: ColourFloat, magenta: ColourFloat, black: ColourFloat)
    case placeholder(name: String)
    indirect case transparent(Colour: Colour, alpha: ColourFloat)
    
    public static func ==(lhs: Colour, rhs: Colour) -> Bool
    {
        switch(lhs, rhs)
        {
            case (.monochrome(let lhsGrey), .monochrome(let rhsGrey)):
                return lhsGrey == rhsGrey
            case (.rgb(let lhsRed, let lhsGreen, let lhsBlue), .rgb(let rhsRed, let rhsGreen, let rhsBlue)):
                return lhsRed == rhsRed && lhsGreen == rhsGreen && lhsBlue == rhsBlue
            case (.cymk(let lhsCyan, let lhsYellow, let lhsMagenta, let lhsBlack), .cymk(let rhsCyan, let rhsYellow, let rhsMagenta, let rhsBlack)):
                return lhsCyan == rhsCyan && lhsYellow == rhsYellow && lhsMagenta == rhsMagenta && lhsBlack == rhsBlack
            case (.placeholder(let lhsName), .placeholder(let rhsName)):
                return lhsName == rhsName
            case (.transparent(let lhsColour, let lhsAlpha), .transparent(let rhsColour, let rhsAlpha)):
                return lhsAlpha == rhsAlpha && lhsColour == rhsColour
            default:
                return false
        }
    }
}

public typealias ColourTable = [String: Colour]


public protocol ColourParser
{
    // It's assumed that textColour is in lowercase
    func deserializeString(textColour: String) throws -> Colour?
}


public struct AnyColourParser : ColourParser
{
    private let _deserialize: (_ textColour: String) throws -> Colour?
    
    public init<Base: ColourParser>(_ base: Base)
    {
        _deserialize = base.deserializeString
    }
    
    public func deserializeString(textColour: String) throws -> Colour? {
        return try self._deserialize(textColour)
    }

}

public extension Array where Element : ColourParser
{
    public func parseString(textColour: String) throws -> Colour?
    {
        var result : Colour?
        let normalizedTextColour = textColour.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        for aParser in self
        {
            if let testResult = try aParser.deserializeString(textColour: normalizedTextColour)
            {
                result = testResult
                break
            }
        }
        return result
    }
}
