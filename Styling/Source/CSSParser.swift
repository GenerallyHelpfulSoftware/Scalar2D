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

/**
 If the parsing of a string fails, and it turns out to not be a valid SVG path string. These errors will be thrown.
 **/
public enum CSSParserFailureReason : CustomStringConvertible, ParseBufferError
{
    case none
    case missingSelector(String.UnicodeScalarView.Index)
    case missingValues(String.UnicodeScalarView.Index)
    case unexpectedCharacter(Character, String.UnicodeScalarView.Index)
    case unexpectedTermination(String.UnicodeScalarView.Index)
    
    public var description: String
    {
        switch self
        {
            case .none:
                return "No Failure"
            case  .unexpectedCharacter(let badCharacter, _):
                return "Unexpected character: \(badCharacter)"
            case .missingSelector:
                return "Missing Selectors"
            case .missingValues:
                return "Missing Values"
            case .unexpectedTermination:
                return "Unexpected Termination"
        }
    }
    
    public var failurePoint: String.UnicodeScalarView.Index?
    {
        switch self {
        case .none:
            return nil
        case .missingSelector(let result):
            return result
        case .missingValues(let result):
            return result
        case .unexpectedCharacter(_, let result):
            return result
        case .unexpectedTermination(let result):
            return result
        }
    }
}

public struct CSSParser
{
    /**
         This property provides knowledge of the document object model for the flavor of css
         being parsed to this parser. It is responsible for assigning knowledge of type to properties. For example that a "fill" property will be a colour.
     
         default: SVGPropertyInterpreter
     */
    let propertyInterpreter : StylePropertyInterpreter
    
    /**
         init method
     
     - parameter propertyInterpreter:StylePropertyInterpreter  - an object that can interpret properties and assign them types, such as colours or font styles
     */
    public init(propertyInterpreter : StylePropertyInterpreter = SVGPropertyInterpreter())
    {
        self.propertyInterpreter = propertyInterpreter
    }
    
    /**
         the primary method of the parser, takes a string thought to be css and converts ito to a list of style blocks.
     
     - parameter cssString:String    CSS format
         - throws an error if string cannot be interpretted
         - returns a list of StyleBlock
     */
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
        var currentSelectors: [[SelectorCombinator]]? = nil // StyleBlocks are composed of collections of selectors and styles
        var currentStyles : [GraphicStyle]? = nil
        
        var cursor = try buffer.findUncommentedIndex() // find the first index not in a comment
        let range = cursor..<buffer.endIndex
        
        var blockBegin = cursor // beginning of block of properties
        
        parseLoop: while range.contains(cursor) // loop over the characters in the string
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
                            continue parseLoop // avoid updating the cursor for one loop
                    }
                case .lookingForProperties:
                    switch character
                    {
                        case "{":
                            state = .lookingForAProperty
                            blockBegin = cursor
                            currentStyles = [GraphicStyle]()
                        case " ", "\t", " ", "\n":
                        break
                        default:
                            throw CSSParserFailureReason.unexpectedCharacter(Character(character), cursor)
                    }
                case .lookingForAProperty:
                    switch character
                    {
                        case " ", "\t", " ", "\n":
                        break
                        case "{", "\"", ";", ":":
                            throw CSSParserFailureReason.unexpectedCharacter(Character(character), cursor)
                        case "}":
                            state = .lookingForSelectorStart
                            if !(currentStyles?.isEmpty ?? false)
                            {
                                let aBlock = StyleBlock(combinators: currentSelectors!, styles: currentStyles!)
                                result.append(aBlock)
                            }
                            currentSelectors = nil
                            currentStyles = nil
                        default:
                            let (properties, newCursor) = try self.propertyInterpreter.parseProperties(buffer: buffer, range: cursor..<buffer.endIndex)
                            cursor = newCursor
                            if currentStyles == nil
                            {
                                currentStyles = [GraphicStyle]()
                            }
                            currentStyles! += properties
                            continue parseLoop  // avoid updating the cursor for one loop
                    }
                
            }
            cursor = try buffer.uncommentedIndex(after: cursor)
        }
        switch state
        {
            case .lookingForSelectorStart:
                break
            default: // finished in the middle of parsing a block
                throw CSSParserFailureReason.unexpectedTermination(blockBegin)
        }
        return result
    }
}
