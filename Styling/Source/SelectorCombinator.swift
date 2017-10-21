//
//  SelectorCombinator.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/6/17.
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

public enum SelectorCombinator : CSSRankable
{
    case selector(StyleSelector)
    
    // various relationship operations
    case child // >
    case adjacentSibling // +
    case sibling // ~
    case descendant // >> or space
    
    fileprivate static func from(character: UnicodeScalar) -> SelectorCombinator
    {
        var result : SelectorCombinator!
        switch character
        {
            case "+":
                result = .adjacentSibling
            case ">":
                result = .child
            case "~":
                result = .sibling
            default:
                result = .descendant
        }
        return result
    }
    
    var asString : String?
    {
        switch self
        {
            case .selector(_):
                return nil
            case .child:
                return ">"
            case .descendant:
                return ">>"
            case .sibling:
                return "~"
            case .adjacentSibling:
                return "+"
        }
    }
    
    public var specificity: CSSSpecificity
    {
        switch self {
        case .selector(let selector):
            return selector.specificity
        default:
            return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 0)
        }
    }
    
    /**
     If the parsing of a string fails, and it turns out to not be a valid SVG path string. These errors will be thrown.
     **/
    public enum FailureReason : CustomStringConvertible, ParseBufferError
    {
        case none
        case emptyString(String.UnicodeScalarView.Index)
        case unmatchedParenthesis(String.UnicodeScalarView.Index)
        case startsWithCombinator(SelectorCombinator, String.UnicodeScalarView.Index)
        case endsWithCombinator(SelectorCombinator, String.UnicodeScalarView.Index)
        case consequativeCombinators(SelectorCombinator, SelectorCombinator, String.UnicodeScalarView.Index)
        case unexpectedCharacter(Character, String.UnicodeScalarView.Index)
        
        public var description: String
        {
            switch self
            {
            case .none:
                return "No Failure"
            case .emptyString:
                return "Empty String"
            case .unmatchedParenthesis:
                return "Nonmatching Parenthesis"
            case .startsWithCombinator(let combinator, _):
                let combinatorString = combinator.asString!
                return "Starts With Combinator \(combinatorString)"
            case .endsWithCombinator(let combinator, _):
                let combinatorString = combinator.asString!
                return "Ends With Combinator \(combinatorString)"
            case .consequativeCombinators(let combinator0, let combinator1, _):
                let combinator0String = combinator0.asString!
                let combinator1String = combinator1.asString!
                return "consequuative Combinators \(combinator0String) \(combinator1String)"
            case .unexpectedCharacter(let aCharacter):
                return "Unexpected character: \(aCharacter)"
                
            }
        }
        public var failurePoint : String.UnicodeScalarView.Index?
        {
            switch self {
                case .none:
                    return nil
                case .emptyString(let result):
                    return result
                case .unmatchedParenthesis(let result):
                    return result
                case .startsWithCombinator(_, let result):
                    return result
                case .endsWithCombinator(_, let result):
                    return result
                case .consequativeCombinators(_, _, let result):
                    return result
                case .unexpectedCharacter(_, let result):
                    return result
            }
        }
    }
    
    public static func parse(buffer: String.UnicodeScalarView, range: Range<String.UnicodeScalarView.Index>) throws ->  ([SelectorCombinator]?, String.UnicodeScalarView.Index)
    {
        var result = [SelectorCombinator]()
        
        enum ParseState
        {
            case inLeadingWhitespace
            case inTrailingWhitespace
            case inSelector
        }
        
        var state = ParseState.inLeadingWhitespace
        var cursor = range.lowerBound
        var parenthesisCount = 0
        var stringBegin = cursor
        
        var previousCharacter : UnicodeScalar = " "
        
        parseLoop: while range.contains(cursor)
        {
            let character = buffer[cursor]
            switch state
            {
                case .inLeadingWhitespace:
                    switch character
                    {
                        case " ", "\t", " ", "\n":
                        break
                        case "(", ")", "{", "}":
                            throw FailureReason.unexpectedCharacter(Character(character), cursor)
                        case "~", "+", ">":
                            let unexpectedCombinator = SelectorCombinator.from(character: character)
                            throw FailureReason.startsWithCombinator(unexpectedCombinator, cursor)
                        default:
                            state = .inSelector
                            stringBegin = cursor
                    }
                case .inSelector:
                    if character == "("
                    {
                        parenthesisCount = parenthesisCount + 1
                    }
                    else if character == ")"
                    {
                        parenthesisCount = parenthesisCount - 1
                    }
                    if parenthesisCount == 0
                    {
                        switch character
                        {
                            case "{":
                                let selector = try StyleSelector(buffer: buffer, range: stringBegin..<cursor)
                                result.append(.selector(selector))
                                state = .inTrailingWhitespace
                                break parseLoop
                            case " ", "\t", " ", "\n":
                                let selector = try StyleSelector(buffer: buffer, range: stringBegin..<cursor)
                                result.append(.selector(selector))
                                state = .inTrailingWhitespace
                            case "~", "+", ">":
                                let selector = try StyleSelector(buffer: buffer, range: stringBegin..<cursor)
                                result.append(.selector(selector))
                            
                                result.append(SelectorCombinator.from(character: character))
                                state = .inTrailingWhitespace
                            case "}":
                                throw FailureReason.unexpectedCharacter(Character(character), cursor)
                            default:
                            break
                        }
                    }
                case .inTrailingWhitespace:
                    switch character
                    {
                        case ">":
                            if previousCharacter == ">"
                            {
                                result.removeLast()
                                result.append(.descendant)
                            }
                            else
                            {
                                fallthrough
                            }
                        case "~", "+":
                            switch result.last!
                            {
                                case .selector(_):
                                    result.append(SelectorCombinator.from(character: character))
                                default:
                                    let combinator0 = result.last!
                                    let combinator1 = SelectorCombinator.from(character: character)
                                    
                                    throw FailureReason.consequativeCombinators(combinator0, combinator1, cursor)
                            }
                        case " ", "\t", " ", "\n":
                        break
                        case "(", ")", "}":
                            throw FailureReason.unexpectedCharacter(Character(character), cursor)
                        
                        case "{":
                            break parseLoop
                        default:
                            switch result.last!
                            {
                                case .selector(_):
                                    result.append(SelectorCombinator.descendant)
                                default:
                                    break
                            }
                            state = .inSelector
                            stringBegin = cursor
                        break
                    }
            }
            previousCharacter = character
            cursor = try buffer.uncommentedIndex(after: cursor)
        }
        
        if parenthesisCount != 0
        {
            throw FailureReason.unmatchedParenthesis(range.lowerBound)
        }
        
        if state == .inSelector
        {
            let selector = try StyleSelector(buffer: buffer, range: stringBegin..<range.upperBound)
            result.append(.selector(selector))
        }
        
        if let lastCombinator = result.last
        {
            switch lastCombinator
            {
                case .selector(_):
                break
                default:
                    throw FailureReason.endsWithCombinator(lastCombinator, range.lowerBound)
            }
        }
        
        return (result, cursor)
    }
    
    public static func parse(css: String) throws -> [SelectorCombinator]?
    {
        return try self.parse(buffer: css.unicodeScalars, range: css.unicodeScalars.startIndex..<css.unicodeScalars.endIndex).0
    }
}

extension SelectorCombinator : Equatable
{
    public static func == (lhs: SelectorCombinator, rhs: SelectorCombinator) -> Bool
    {
        switch (lhs, rhs)
        {
            case (.child, .child), (.sibling, .sibling), (.descendant, .descendant), (.adjacentSibling, .adjacentSibling):
                return true
            case (.selector(let lhsSelector), .selector(let rhsSelector)):
                return lhsSelector == rhsSelector
            default:
                return false
        }
    }
}

extension Array where Element == SelectorCombinator
{
    // a combinator path will be valid if it begins and ends on a selector, and alternates between selectors and conbinator operations internally
    var isValid : Bool
    {
        if self.isEmpty
        {
            return false
        }
        
        var odd = true
        for anElement in self
        {
            switch (anElement, odd)
            {
                case (.selector(_), false):
                    return false
                case (.selector(_), true):
                    break
                case (_, true):
                    return false
                default:
                break
            }
            
            odd = !odd
        }
        
        return !odd
    }
}

