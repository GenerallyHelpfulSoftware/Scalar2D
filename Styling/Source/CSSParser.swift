//
//  CSSParser.swift
//  Scalar2D
//
// The MIT License (MIT)

//  Copyright (c) 2016-2017 Generally Helpful Software

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



public enum CSSParserFailureReason : CustomStringConvertible, ParseBufferError
{
    case unmatchedCurlyBrace(String.UnicodeScalarView.Index)
    public var description: String
    {
        switch self
        {
        case .unmatchedCurlyBrace:
            return "Unmatched curly brace"
        }
    }
    
    public var failurePoint : String.UnicodeScalarView.Index?
    {
        switch self
        {
            case .unmatchedCurlyBrace(let result):
                return result
        }
    }
}

public  struct CSSParser
{
    let propertyInterpreter : StylePropertyInterpreter
    
    public init(propertyInterpreter : StylePropertyInterpreter = SVGPropertyInterpreter())
    {
        self.propertyInterpreter = propertyInterpreter
    }
    
    public func parse(cssString: String) throws -> [StyleBlock]
    {
        enum ParseState
        {
            case lookingForSelectorStart
            case lookingForProperties
            case lookingForAProperty
            
        }
        var result = [StyleBlock]()
        var state = ParseState.lookingForSelectorStart
        
        let buffer = cssString.unicodeScalars
        var currentSelectors: [[SelectorCombinator]]? = nil
        var styles : [GraphicStyle]? = nil
        
        var cursor = try buffer.findUncommentedIndex()
        let range = cursor..<buffer.endIndex
        
        var blockBegin = cursor
        parseLoop: while range.contains(cursor)
        {
            let character = buffer[cursor]
            
            switch state
            {
                case .lookingForSelectorStart:
                    switch character
                    {
                        case " ", "\t", " ", "\n":
                        break
                        default:
                            let (combinators, newCursor) = try GroupSelector.parse(buffer: buffer, range: cursor..<buffer.endIndex)
                            currentSelectors = combinators
                            cursor = newCursor
                            state = .lookingForProperties
                            continue parseLoop
                    }
                case .lookingForProperties:
                    switch character
                    {
                        case "{":
                            state = .lookingForAProperty
                            blockBegin = cursor
                            styles = [GraphicStyle]()
                        case " ", "\t", " ", "\n":
                        break
                        default:
                            throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                    }
                case .lookingForAProperty:
                    switch character
                    {
                        case " ", "\t", " ", "\n":
                        break
                        case "{", "\"", ";", ":":
                            throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                        case "}":
                            state = .lookingForSelectorStart
                            if !(styles?.isEmpty ?? false)
                            {
                                let aBlock = StyleBlock(combinators: currentSelectors!, styles: styles!)
                                result.append(aBlock)
                            }
                            currentSelectors = nil
                            styles = nil
                        default:
                            let (properties, newCursor) = try self.propertyInterpreter.parseProperties(buffer: buffer, range: cursor..<buffer.endIndex)
                            cursor = newCursor
                            if styles == nil
                            {
                                styles = [GraphicStyle]()
                            }
                            styles! += properties
                            continue parseLoop 
                    }
                
            }
            cursor = try buffer.uncommentedIndex(after: cursor)
        }
        switch state
        {
            case .lookingForSelectorStart:
                break
            default:
                throw CSSParserFailureReason.unmatchedCurlyBrace(blockBegin)
        }
        return result
    }
    
    /**
     If the parsing of a string fails, and it turns out to not be a valid SVG path string. These errors will be thrown.
     **/
    public enum FailureReason : CustomStringConvertible, Error
    {
        case none
        case missingSelector(offset: Int)
        case missingValues(offset: Int)
        case unexpectedCharacter(badCharacter: Character, offset: Int)
        
        public var description: String
        {
            switch self
            {
                case .none:
                    return "No Failure"
                case let .unexpectedCharacter(badCharacter, offset):
                    return "Unexpected character: \(badCharacter) at offset: \(offset)"
                case let .missingSelector(offset):
                    return "Missing Selectors at offset: \(offset)"
                case let .missingValues(offset):
                    return "Missing Values at offset:\(offset)"
            }
        }
    }
}

