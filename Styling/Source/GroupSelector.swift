//
//  GroupSelector.swift
//  Scalar2DTests
//
//  Created by Glenn Howes on 8/18/17.
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

public typealias GroupSelector = [[SelectorCombinator]]


extension Array where Element == Array<SelectorCombinator> 
{
    fileprivate enum FailureReason : CustomStringConvertible, ParseBufferError
    {
        case none
        case emptyString(String.UnicodeScalarView.Index)
        case noSelectors(String.UnicodeScalarView.Index)
        case extraCommas(String.UnicodeScalarView.Index)
        
        public var description: String
        {
            switch self
            {
                case .none:
                    return "No Failure"
                case .emptyString:
                    return "Empty String"
                case .noSelectors:
                    return "No Selectors in Group"
                case .extraCommas:
                    return "Expected Selector, got comma."
                
            }
        }
        public var failurePoint : String.UnicodeScalarView.Index?
        {
            switch self  {
                case .none:
                    return nil
                case .emptyString(let result):
                    return result
                case .extraCommas(let result):
                    return result
                case .noSelectors(let result):
                    return result
            }
        }
    }

    
    public static func parse(buffer: String.UnicodeScalarView, range: Range<String.UnicodeScalarView.Index>) throws -> (GroupSelector?, String.UnicodeScalarView.Index)
    {
        var awaitingComma = false
        var result = [[SelectorCombinator]]()
        
        if range.isEmpty
        {
            throw FailureReason.emptyString(range.lowerBound)
        }
        var cursor = range.lowerBound
        var stringBegin = cursor
        var stringEnd = cursor
        
        parseLoop: while range.contains(cursor)
        {
            let character = buffer[cursor]
            
            if awaitingComma
            {
                switch character
                {
                    case " ", "\t", " ", "\n": // stripping trailing whitespace
                    break
                    case ",", "{":
                        let closedStringEnd = try buffer.uncommentedIndex(after: stringEnd)
                        if let aCombination = try SelectorCombinator.parse(buffer: buffer, range: stringBegin..<closedStringEnd).0
                        {
                            result.append(aCombination)
                        }
                        awaitingComma = false
                        if character == "{"
                        {
                            break parseLoop
                        }
                    default:
                        stringEnd = cursor
                }
            }
            else
            {
                switch character
                {
                    case " ", "\t", " ", "\n":
                    break
                    case ",":
                        throw FailureReason.extraCommas(cursor)
                    case "{":
                        break parseLoop
                    default:
                        awaitingComma = true
                        stringBegin = cursor
                }
            }
            
            cursor = try buffer.uncommentedIndex(after: cursor)
        } // end parse loop
        
        if awaitingComma // was waiting for a selector to end when loop completed
        {
            if let aCombination = try SelectorCombinator.parse(buffer: buffer, range: stringBegin..<range.upperBound).0
            {
                result.append(aCombination)
            }
        }
        
        if result.isEmpty
        {
            throw FailureReason.noSelectors(range.upperBound)
        }

        return (result, cursor)
    }
    
    public static func parse(css: String) throws -> GroupSelector?
    {
        let trimmedCSS = css.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let unicodeView = trimmedCSS.unicodeScalars
        if trimmedCSS.isEmpty
        {
            throw FailureReason.emptyString(unicodeView.startIndex)
        }
        
        let result = try self.parse(buffer: unicodeView, range: unicodeView.startIndex..<unicodeView.endIndex)
        return result.0
        
    }
}

