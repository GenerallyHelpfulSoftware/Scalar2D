//
//  StylePropertyInterpreter.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/19/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//
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

public enum StylePropertyFailureReason : CustomStringConvertible, ParseBufferError
{
    case unexpectedSemiColon(String.UnicodeScalarView.Index)
    case unexpectedColon(String.UnicodeScalarView.Index)
    case unexpectedCharacter(Character, String.UnicodeScalarView.Index)
    case incompleteProperty(String, String.UnicodeScalarView.Index)
    case badProperty(String, String.UnicodeScalarView.Index)
    case incompleteImportant(String.UnicodeScalarView.Index)
    case logicErrorInParser(String.UnicodeScalarView.Index)
    case nonMatchingQuote(String.UnicodeScalarView.Index)
    
    public var description: String
    {
        switch self
        {
            case .badProperty(_, _):
                return "Malformed Property"
            case .unexpectedSemiColon:
                return "Unexpected Semicolon"
            case .unexpectedColon:
                return "Unexpected Colon"
            case .unexpectedCharacter(let character, _):
                return "Unexpected \(character)"
            case .incompleteProperty(let key, _):
                return "Incomplete Property named \(key)"
            case .incompleteImportant:
                return "Expected '!important'"
            case .logicErrorInParser:
                return "Parser has a bug"
            case .nonMatchingQuote:
                return "Quote did not end"
        }
    }
    public var failurePoint : String.UnicodeScalarView.Index?
    {
        switch self
        {
            case .badProperty(_, let result):
                return result
            case .unexpectedSemiColon(let result):
                return result
            case .unexpectedColon(let result):
                return result
            case .unexpectedCharacter(_, let result):
                return result
            case .incompleteProperty(_, let result):
                return result
            case .incompleteImportant(let result):
                return result
            case .logicErrorInParser(let result):
                return result
            case .nonMatchingQuote(let result):
                return result
        }
    }
}

public protocol StylePropertyInterpreter
{
    func interpret(key: PropertyKey, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
}

fileprivate enum ParseState
{
    case awaitingKey
    case inKey
    case awaitingColon
    case awaitingProperties
    case inProperty
    
}

extension StylePropertyInterpreter
{
    public func parseProperties(buffer: String.UnicodeScalarView, range: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
    {
        var result = [GraphicStyle]()
        var state = ParseState.awaitingKey
        var cursor = range.lowerBound
        var stringBegin = cursor
        var key : String?
        
        parseLoop: while range.contains(cursor)
        {
            let character = buffer[cursor]
            switch state
            {
                case .awaitingKey:
                    switch character
                    {
                        case "}":
                            break parseLoop
                        case ";":
                            throw StylePropertyFailureReason.unexpectedSemiColon(cursor)
                        case ":":
                            throw StylePropertyFailureReason.unexpectedColon(cursor)
                        case " ", "\t", " ", "\n":
                        break
                        case "0"..."9", "a"..."z", "A"..."Z":
                            state = .inKey
                            stringBegin = cursor
                    default:
                        throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                    }
                case .inKey:
                    switch character
                    {
                        case ":":
                            key = String(buffer[stringBegin..<cursor]).lowercased()
                            state = .awaitingProperties
                        case " ", "\t", " ", "\n":
                            state = .awaitingColon
                            key = String(buffer[stringBegin..<cursor]).lowercased()
                        
                        case "0"..."9", "a"..."z", "A"..."Z", "-", "_":
                        break
                        case ";":
                            throw StylePropertyFailureReason.unexpectedSemiColon(cursor)
                        default:
                            throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                    }
                case .awaitingColon:
                    switch character
                    {
                        case ":":
                            key = String(buffer[stringBegin..<cursor]).lowercased()
                            state = .awaitingProperties
                        case " ", "\t", " ", "\n":
                            break
                        case ";":
                            throw StylePropertyFailureReason.unexpectedSemiColon(cursor)
                        default:
                            throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                    }
                case .awaitingProperties:
                    switch character
                    {
                        case ";":
                            throw StylePropertyFailureReason.unexpectedSemiColon(cursor)
                        case ":":
                            throw StylePropertyFailureReason.unexpectedColon(cursor)
                        case " ", "\t", " ", "\n":   // allow space between colon and the beginning of the property
                        break
                        default:
                            state = .inProperty
                            stringBegin = cursor
                    }
                case .inProperty:
                    switch character
                    {
                        case ";":
                            guard let fullKey = key, !fullKey.isEmpty, let property = PropertyKey(rawValue: fullKey) else
                            {
                                throw StylePropertyFailureReason.unexpectedSemiColon(cursor)
                            }
                            let properties = try self.interpret(key: property, buffer: buffer, valueRange: stringBegin..<cursor).0
                            result = result + properties
                            state = .awaitingKey
                        default:
                        break
                    }
            }
            cursor = try buffer.uncommentedIndex(after: cursor)
        }
        
        switch state {
            case .awaitingKey:
            break
            default:
                let terminalString = String(buffer[stringBegin..<range.upperBound])
                throw StylePropertyFailureReason.incompleteProperty(terminalString, stringBegin)
        }
        
        
        return (result, cursor)
    }
    public func parseProperties(string: String) throws -> [GraphicStyle]
    {
        let scalars = string.unicodeScalars
        return try self.parseProperties(buffer: scalars, range: scalars.startIndex..<scalars.endIndex).0
    }
}
