////
////  StyleSelector.swift
////  Scalar2D
////
////  Created by Glenn Howes on 8/27/16.

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


public protocol CSSIdentifiable
{
    var styleIdentifier: String? {get}
    var styleClassName: String? {get}
    var styleableElementName: String? {get}
}

/**
    A struct that encapsulates the priority a given selector or group of selectors will have in CSS in terms of determining which properties will be applied.
   
    [W3C Docs](https://www.w3.org/TR/CSS/#css)
*/
public struct CSSSpecificity : Comparable
{
    let identifierCount: Int
    let classesAttributesPseudoClassesCount: Int
    let elementPseudoElementCount: Int
    
    static func +(left:CSSSpecificity, right: CSSSpecificity) -> CSSSpecificity
    {
        return CSSSpecificity(identifierCount: left.identifierCount+right.identifierCount, classesAttributesPseudoClassesCount: left.classesAttributesPseudoClassesCount+right.classesAttributesPseudoClassesCount, elementPseudoElementCount: left.elementPseudoElementCount+right.elementPseudoElementCount)
    }
    
    public static func <(lhs: CSSSpecificity, rhs: CSSSpecificity) -> Bool
    {
        if lhs.identifierCount < rhs.identifierCount
        {
            return true
        }
        else if lhs.classesAttributesPseudoClassesCount < rhs.classesAttributesPseudoClassesCount
        {
            return true
        }
        else if lhs.elementPseudoElementCount < rhs.elementPseudoElementCount
        {
            return true
        }
        
        return false
    }
    
    public static func ==(lhs: CSSSpecificity, rhs: CSSSpecificity) -> Bool
    {
        return lhs.identifierCount == rhs.identifierCount
            && lhs.classesAttributesPseudoClassesCount == rhs.classesAttributesPseudoClassesCount
            && lhs.elementPseudoElementCount == rhs.elementPseudoElementCount
    }
}

/**
    Protocol to return a calculation of how specific a selector is. More specific selectors are chosen over less specific selectors when applying styling.
*/
public protocol CSSRankable {
    var specificity: CSSSpecificity{get}
}

extension String
{
    /**
        - returns the contents of a parenthesis.
    */
    fileprivate  func parenthesisStripped() throws -> String? // just return any content of an interior ()
    {
        
        let unicodeView = self.unicodeScalars
        var cursor = try unicodeView.findUncommentedIndex()
        let endCursor = unicodeView.endIndex
        var leftParen : String.Index? = nil
        var rightParen : String.Index? = nil
        
        while endCursor != cursor
        {
            let character = unicodeView[cursor]
            if character == "(" && leftParen == nil
            {
                leftParen = unicodeView.index(after: cursor)
            }
            else if character == ")"
            {
                if leftParen == nil
                {
                    return nil
                }
                rightParen = unicodeView.index(before: cursor)
                
            }
            cursor = unicodeView.index(after: cursor)
        }
        
        if let foundLeftParen = leftParen, let foundRightParen = rightParen
        {
            let result =  String(unicodeView[foundLeftParen...foundRightParen]).trimmingCharacters(in: .whitespaces)
            
            if result.isEmpty
            {
                return nil
            }
            return result
        }
        else
        {
            return nil
        }
    }
}

/**
   Enumeration encoding where in a list, a selector is targeting.
*/
public enum Nth
{
    case odd
    case even
    case nth(Int)
    case linear(Int, Int)
    
    fileprivate init?(string: String) throws // this init will strip off any prefix like "nth-of-type(" and the ")" suffix
    {
        guard  let parameterString = try string.parenthesisStripped() else
        {
            return nil
        }
        switch parameterString
        {
            case "odd":
                self = .odd
            case "even":
                self = .even
            default:
                let start = parameterString.startIndex
                let end = parameterString.endIndex
                if let nLocation = parameterString.firstIndex(of: "n")
                {
                    if start == nLocation || end == nLocation
                    {
                        return nil
                    }
                    let startB = parameterString.index(after: nLocation)
                    guard let a = Int(parameterString[start..<nLocation].trimmingCharacters(in: .whitespaces)), let b = Int(parameterString[startB..<end].trimmingCharacters(in: .whitespaces)) else
                    {
                        return nil
                    }
                    self = .linear(a, b)
                }
                else
                {
                    guard let b = Int(parameterString) else
                    {
                        return nil
                    }
                    self = .nth(b)
                }
        }
    }
    
    // case function
}
/**
    Enumeration of possible standard (and custom) pseudo classes as defined in the css specification.
    Used to target objects with certain identifying characteristics.
*/
public enum PseudoClass  : CSSRankable
{
    case custom(String)
    case any
    case focus
    case last_child
    case active
    case link
    case checked
    case dir
    case disabled
    case empty
    case only_child
    case enabled
    case only_of_type
    case first
    case optional
    case first_child
    case out_of_range
    case first_of_type
    case read_only
    case fullscreen
    case read_write
    case required
    case hover
    case right
    case indeterminate
    case root
    case in_range
    case scope
    case invalid
    case target
    case lang
    case valid
    case visited
    case last_of_type
    case left
    case not(StyleSelector)
    case nth_last_of_type(Nth)
    case nth_child(Nth)
    case nth_of_type(Nth)
    
    
    public init?(string: String) throws
    {
        switch string
        {
            case "any":
                self = .any
            case "focus":
                self = .focus
            case "last-child":
                self = .last_child
            case "active":
                self = .active
            case "link":
                self = .link
            case "checked":
                self = .checked
            case "dir":
                self = .dir
            case "disabled":
                self = .disabled
            case "empty":
                self = .empty
            case "only-child":
                self = .only_child
            case "enabled":
                self = .enabled
            case "only-of-type":
                self = .only_of_type
            case "first":
                self = .first
            case "optional":
                self = .optional
            case "first-child":
                self = .first_child
            case "out-of-range":
                self = .out_of_range
            case "first-of-type":
                self = .first_of_type
            case "read-only":
                self = .read_only
            case "fullscreen":
                self = .fullscreen
            case "read-write":
                self = .read_write
            case "required":
                self = .required
            case "hover":
                self = .hover
            case "right":
                self = .right
            case "indeterminate":
                self = .indeterminate
            case "root":
                self = .root
            case "in-range":
                self = .in_range
            case "scope":
                self = .scope
            case "invalid":
                self = .invalid
            case "visited":
                self = .visited
            case "last-of-type":
                self = .last_of_type
            case "left":
                self = .left
            default:
                if string.hasPrefix("nth-of-type")
                {
                    guard let nth = try Nth(string: string) else {return nil}
                    self = .nth_of_type(nth)
                }
                else if string.hasPrefix("nth-last-of-type")
                {
                    guard let nth = try Nth(string: string) else {return nil}
                    self = .nth_last_of_type(nth)
                }
                else if string.hasPrefix("nth-child")
                {
                    guard let nth = try Nth(string: string) else {return nil}
                    self = .nth_child(nth)
                }
                else if string.hasPrefix("not")
                {
                    guard let selectorString  = try string.parenthesisStripped() else
                    {
                        return nil
                    }
                    let selector = try  StyleSelector(css: selectorString)
                    self = .not(selector)
                }
                else
                {
                    return nil
                }
        }
    }
    // implement CSSRankable
    public var specificity: CSSSpecificity
    {
        switch self
        {
            case .not(let selector):
                return selector.specificity
            default:
                return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 1, elementPseudoElementCount: 0)
        }
    }
}
/**
For pretty subtle reasons, a pseudo element is different from a pseudo class.
 
*/
public enum PseudoElement  : CSSRankable
{
    case custom(String)
    case after
    case before
    case first_letter
    case first_line
    case selection
    case backdrop
    case placeholder
    case marker
    case spelling_error
    case grammar_error
    
    // implement CSSRankable
    public var specificity: CSSSpecificity
    {
        return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 1)
    }
    
    public init?(string: String) throws
    {
        switch string
        {
            case "after":
                self = .after
            case "before":
                    self = .before
            case "first-letter":
                    self = .first_letter
            case "first-line":
                    self = .first_line
            case "selection":
                    self = .selection
            case "backdrop":
                    self = .backdrop
            case "placeholder":
                    self = .placeholder
            case "marker":
                    self = .marker
            case "spelling-error":
                    self = .spelling_error
            case "grammar-error":
                    self = .grammar_error
            default:
            return nil
        }
    }
}

public enum AttributePosition
{
    case equals
    case prefix
    case suffix
    case contains
}


/**
     enum that indicates what kind of object this is, such as path, group, button, etc. Or any. 
*/
public enum CSSElement : CSSRankable
{
    case any
    case none
    case element(name:String)
    
    public var specificity: CSSSpecificity
    {
        switch self {
        case .none:
            return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 0)
        case .any:
            return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 0)
        default:
            return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 1)
        }
    }
    
    fileprivate func compatible(with element: CSSIdentifiable) -> Bool
    {
        switch self
        {
            case .any, .none:
                return true
            case .element(let name):
                return element.styleableElementName == name
        }
    }
}

public struct StyleSelector : CSSRankable
{
    let element: CSSElement
    let styleIdentifier: String?
    let styleClassName: String?
    let pseudoClasses: [PseudoClass]?
    let pseudoElement: PseudoElement?
    
    /**
     If the parsing of a string fails, and it turns out to not be a valid SVG path string. These errors will be thrown.
     **/
    public enum FailureReason : CustomStringConvertible, ParseBufferError
    {
        case none
        case emptyString(String.UnicodeScalarView.Index)
        case disallowedName(String.UnicodeScalarView.Index)
        case missingSelector(String.UnicodeScalarView.Index)
        case missingValues(String.UnicodeScalarView.Index)
        case unexpectedCharacter(badCharacter: Character, location: String.UnicodeScalarView.Index)
        case unknownPseudoElement(string: String, location: String.UnicodeScalarView.Index)
        case unexpectedEnding(string: String, location: String.UnicodeScalarView.Index)
        case multipleIdentifiers(String.UnicodeScalarView.Index)
        case identifierAfterPseudoClasses(String.UnicodeScalarView.Index)
        
        public var description: String
        {
            switch self
            {
            case .none:
                return "No Failure"
            case .emptyString:
                return "Empty String"
            case let .unexpectedCharacter(badCharacter):
                return "Unexpected character: \(badCharacter)"
            case .missingSelector:
                return "Missing Selectors"
            case .missingValues:
                return "Missing Values"
            case let .unknownPseudoElement(string):
                return "Unkown PseudoElement \(string)"
            case let .unexpectedEnding(string):
                return "String after finished selector \(string)"
            case .multipleIdentifiers:
                return "Multiple Identifiers"
            case .identifierAfterPseudoClasses:
                return "Misplaced Identifier"
            case .disallowedName:
                return "Bad Name"
            
            }
        }
        
        public var failurePoint : String.UnicodeScalarView.Index?
        {
            switch self  {
                case .none:
                    return nil
                case .emptyString(let result):
                    return result
                case .unexpectedCharacter(badCharacter: _, let result):
                    return result
                case .disallowedName(let result):
                    return result
                case .identifierAfterPseudoClasses(let result):
                    return result
                case .missingValues(let result):
                    return result
                case .missingSelector(let result):
                    return result
                case .unknownPseudoElement(string: _, let result):
                    return result
                case .multipleIdentifiers(let result):
                    return result
                case .unexpectedEnding(string: _, let result):
                    return result
            }
        }
    }
    
    public init(buffer: String.UnicodeScalarView, range: Range<String.UnicodeScalarView.Index>) throws
    {
        enum ParseState
        {
            case inElement
            case inIdentifier
            case inClassName
            case inPseudoClasses
            case inPseudoElement
            case inBetweenTokens
        }
        
        var localElement: CSSElement = .none
        var localStyleIdentifier: String? = nil
        var localStyleClassName: String? = nil
        var localPseudoClasses: [PseudoClass]? = nil
        var localPseudoElement: PseudoElement? = nil
        
        if range.isEmpty
        {
            throw FailureReason.emptyString(range.lowerBound)
        }

        var state = ParseState.inElement
        var previousCharacter : UnicodeScalar = " "
        var stringBegin = range.lowerBound
        let firstCharacter = buffer[range.lowerBound]
        switch firstCharacter {
            case "#":
                localElement = .none
                previousCharacter  = "#"
                state = ParseState.inIdentifier
                stringBegin = try buffer.uncommentedIndex(after: stringBegin)
            case ".":
                localElement = .none
                previousCharacter  = "."
                state = ParseState.inClassName
                stringBegin = try buffer.uncommentedIndex(after: stringBegin)
            case ":":
                localElement = .none
                previousCharacter  = ":"
                state = ParseState.inPseudoClasses
                stringBegin = try buffer.uncommentedIndex(after: stringBegin)
            case "*":
                localElement = .any
                state = ParseState.inBetweenTokens
                stringBegin = try buffer.uncommentedIndex(after: stringBegin)
            case "0"..."9":
                let badCharacter = Character(buffer.first!)
                throw FailureReason.unexpectedCharacter(badCharacter: badCharacter, location: range.lowerBound)
            default:
                break
        }
        
        var parenthesisCount = 0
        var inSecondCharacter = range.contains(stringBegin) && stringBegin != range.lowerBound
        var cursor = stringBegin
        var stringHasEscape = false
        var stringHasNonDashNumberOrUnderscore = false
        
        loop:        while range.contains(cursor)
        {
            var foundTerminal = false
            let character = buffer[cursor]
            
            if character == "\\"
            {
                stringHasEscape = true
            }
            
            switch state
            {
                case .inBetweenTokens:
                    inSecondCharacter = true
                    switch character
                    {
                        case "#":
                            state = ParseState.inIdentifier
                            stringBegin = try buffer.uncommentedIndex(after: cursor)
                            if localStyleIdentifier != nil // already have a styleIdentifier
                            {
                                throw FailureReason.multipleIdentifiers(cursor)
                            }
                            if localPseudoClasses != nil
                            {
                                throw FailureReason.identifierAfterPseudoClasses(cursor)
                            }
                        case ".":
                            state = ParseState.inClassName
                            stringBegin = try buffer.uncommentedIndex(after: cursor)
                        case ":":
                            state = ParseState.inPseudoClasses
                            stringBegin = try buffer.uncommentedIndex(after: cursor)
                        default:
                            let badCharacter = Character(character)
                            throw FailureReason.unexpectedCharacter(badCharacter: badCharacter, location: cursor)
                    }
                    cursor = stringBegin
                    continue loop
                case .inElement:
                    switch character
                    {
                        case "#", ".", ":":
                            foundTerminal = true
                        case "0"..."9":
                            if previousCharacter == "-" && buffer.index(before: cursor) == stringBegin // can't start a element string with a hyphen followed by a number
                            {
                                throw FailureReason.unexpectedCharacter(badCharacter: Character(character), location: cursor)
                            }
                        case  "-", "_":
                            break
                        default:
                            stringHasNonDashNumberOrUnderscore = true
                    }
                
                case .inIdentifier:
                    switch character
                    {
                        case "#":
                            throw FailureReason.unexpectedCharacter(badCharacter: Character(character), location: cursor)
                        case ".", ":":
                            foundTerminal = true
                        case  "-", "_", "0"..."9":
                        break
                        default:
                            stringHasNonDashNumberOrUnderscore = true
                    }
                case .inClassName:
                    switch character
                    {
                        case "#", ".":
                            throw FailureReason.unexpectedCharacter(badCharacter: Character(character), location: cursor)
                        case  ":":
                            foundTerminal = true
                        case  "-", "_", "0"..."9":
                            break
                        default:
                            stringHasNonDashNumberOrUnderscore = true
                    }
                case .inPseudoClasses:
                    
                    switch character // a pseudoclass might be not, which might have internal parenthesis (including not)
                    {
                        case "(":
                            parenthesisCount = parenthesisCount + 1
                        case ")":
                            parenthesisCount = parenthesisCount - 1
                            if parenthesisCount < 0
                            {
                                throw FailureReason.unexpectedCharacter(badCharacter: ")", location: cursor)
                            }
                        default:
                        break
                    }
                    
                    if parenthesisCount == 0
                    {
                        if inSecondCharacter && character == ":" // a leading double colon indicates a pseudo element instead of a pseudo class
                        {
                            state = ParseState.inPseudoElement
                            stringBegin = try buffer.uncommentedIndex(after: cursor)
                        }
                        else
                        {
                            switch character
                            {
                                case "#", ".":
                                    throw FailureReason.unexpectedCharacter(badCharacter: Character(character), location: cursor)
                                case  ":":
                                    foundTerminal = true
                                case  "-", "_", "0"..."9":
                                break
                                default:
                                    stringHasNonDashNumberOrUnderscore = true
                            }
                        }
                    }

                case .inPseudoElement:
                    switch character
                    {
                        case "#", ".":
                            throw FailureReason.unexpectedCharacter(badCharacter: Character(character), location: cursor)
                        case  ":":
                            foundTerminal = true
                        case  "-", "_", "0"..."9":
                        break
                        default:
                            stringHasNonDashNumberOrUnderscore = true
                    }
            }
            
            previousCharacter = character
            inSecondCharacter = false
            
            var complete = foundTerminal
            if !foundTerminal
            {
                cursor = buffer.index(after: cursor)
                if !range.contains(cursor)
                {
                    complete = true
                }
            }
            
            if complete //
            {
                var subrange = stringBegin..<cursor
                if !range.contains(cursor)
                {
                    subrange = stringBegin..<range.upperBound
                }
                let theString = String(buffer[subrange])
                if stringHasEscape
                {
                    //theString = theString
                }
                
                if theString.isEmpty
                {
                    throw FailureReason.missingSelector(range.lowerBound)
                }
                else if !stringHasNonDashNumberOrUnderscore // have to have something more interesting than "__9"
                {
                    throw FailureReason.disallowedName(stringBegin)
                }
                
                switch state
                {
                    case .inBetweenTokens:
                        throw FailureReason.missingSelector(cursor)
                    case .inElement:
                        localElement = .element(name: theString)
                    case .inClassName:
                        localStyleClassName = theString
                    case .inIdentifier:
                        localStyleIdentifier = theString
                    case .inPseudoClasses:
                        if let pseudoClass = try PseudoClass(string: theString)
                        {
                            if localPseudoClasses == nil
                            {
                                localPseudoClasses = [pseudoClass]
                            }
                            else
                            {
                                localPseudoClasses!.append(pseudoClass)
                            }
                        }
                        else
                        {
                            fallthrough // by convention, pseudo-elements do not have to be prefixed with ::
                        }
                    case .inPseudoElement:
                        if let pseudoElement = try PseudoElement(string: theString)
                        {
                            localPseudoElement = pseudoElement
                            
                            if range.contains(cursor) // the pseudo element has to be at the end
                            {
                                let excessString = String(buffer[cursor..<range.upperBound])
                                throw FailureReason.unexpectedEnding(string: excessString, location: cursor)
                            }
                        }
                        else
                        {
                            throw FailureReason.unknownPseudoElement(string: theString, location: stringBegin)
                        }
                }
                state = .inBetweenTokens
                stringHasEscape = false
                stringHasNonDashNumberOrUnderscore = false
            }
        }

        self.element = localElement
        self.styleIdentifier = localStyleIdentifier
        self.styleClassName = localStyleClassName
        self.pseudoClasses = localPseudoClasses
        self.pseudoElement = localPseudoElement
    }
    
    public init(css: String) throws
    {
        let trimmedCSS = css.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let unicodeView = trimmedCSS.unicodeScalars
        if trimmedCSS.isEmpty
        {
            throw FailureReason.emptyString(unicodeView.startIndex)
        }
        
        try self.init(buffer: unicodeView, range: unicodeView.startIndex..<unicodeView.endIndex)
    }
    
    public init(element: CSSElement  = .none, identifier: String? = nil, className: String? = nil, pseudoClasses: [PseudoClass]? = nil, pseudoElement: PseudoElement? = nil)
    {
        self.element = element
        self.styleIdentifier = identifier
        self.styleClassName = className
        self.pseudoClasses = pseudoClasses
        self.pseudoElement = pseudoElement
    }
    
    public init(_ elementName: String)
    {
        self.init(element: .element(name: elementName))
    }
    
    public var specificity: CSSSpecificity
    {
        var result = self.element.specificity
        if let _ = self.styleIdentifier
        {
            result = result + CSSSpecificity(identifierCount: 1, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 0)
        }
        
        if let _ = self.styleClassName
        {
            result = result + CSSSpecificity(identifierCount:  0, classesAttributesPseudoClassesCount: 1, elementPseudoElementCount: 0)
        }
        
        if let pseudoClasses = self.pseudoClasses
        {
            for aPseudoClass in pseudoClasses
            {
                result = result + aPseudoClass.specificity
            }
        }
        
        if let pseudoElement = self.pseudoElement
        {
            result = result + pseudoElement.specificity
        }
        
        return result
    }
    
    public func applies(to testItem:CSSIdentifiable, given context: CSSContext ) -> Bool
    {
        if !self.element.compatible(with: testItem)
        {
            return false
        }
        
        if self.styleIdentifier != testItem.styleIdentifier
        {
            return false
        }
        
        if self.styleClassName != testItem.styleClassName
        {
            return false
        }

        if let pseudoClasses = self.pseudoClasses
        {
            for aPseudoClass in pseudoClasses
            {
                if (!context.test(testItem, for: aPseudoClass))
                {
                    return false
                }
            }
        }

        if let pseudoElement = self.pseudoElement
        {
            return context.test(testItem, for: pseudoElement)
        }
        
        return true
    }
}

extension PseudoClass : Equatable
{
    public static func == (lhs: PseudoClass, rhs: PseudoClass) -> Bool
    {
        switch (lhs, rhs)
        {
            case (.custom(let lhName), .custom(let rhName)):
                return lhName == rhName
            case (.not(let lhsStyleSelector), .not(let rhsStyleSelector)):
                return lhsStyleSelector == rhsStyleSelector
            case (.nth_child(let lhsNth), .nth_child(let rhsNth)):
                return lhsNth == rhsNth
            case (.nth_of_type(let lhsNth), .nth_of_type(let rhsNth)):
                return lhsNth == rhsNth
            case (.any, .any), (.focus, .focus), (.last_child, .last_child),
                 (.active, .active), (.link, .link), (.checked, .checked), (.dir, .dir),
                 (.nth_last_of_type, .nth_last_of_type), (.disabled, .disabled),
                 (.empty, .empty), (.only_child, .only_child), (.enabled, .enabled),
                 (.only_of_type, .only_of_type), (.first, .first), (.optional, .optional), (.first_child, .first_child),
                 (.out_of_range, .out_of_range), (.first_of_type, .first_of_type), (.read_only, .read_only),
                 (.fullscreen, .fullscreen), (.read_write, .read_write), (.required, .required),
                 (.hover, .hover), (.right, .right), (.indeterminate, .indeterminate), (.root, .root),
                 (.in_range, .in_range), (.scope, .scope), (.invalid, .invalid), (.target, .target), (.lang, .lang),
                 (.valid, .valid), (.visited, .visited), (.last_of_type, .last_of_type), (.left, .left):
                    return true
            default:
                return false
        }
    }
}

extension Nth : Equatable
{
    public static func == (lhs: Nth, rhs: Nth) -> Bool
    {
        switch(lhs, rhs)
        {
            case (.odd, .odd),  (.even, .even):
                return true
            case (.nth(let lhsNth), .nth(let rhsNth)):
                return lhsNth == rhsNth
            case(.linear(let lhsA, let lhsB), .linear(let rhsA, let rhsB)):
                return lhsA == rhsA && lhsB == rhsB
            default:
                return false
        }
    }
}

extension PseudoElement : Equatable
{
    public static func == (lhs: PseudoElement, rhs: PseudoElement) -> Bool
    {
        switch(lhs, rhs)
        {
            case (.after, .after), (.before, .before), (.first_letter, .first_letter),
                 (.first_line, .first_line), (.selection, .selection), (.backdrop, .backdrop),
                 (.placeholder, .placeholder), (.marker, .marker), (.spelling_error, .spelling_error),
                 (.grammar_error, .grammar_error):
                return true
            case (.custom(let lhsName), .custom(let rhsName)):
                return lhsName == rhsName
            default:
                return false
        }
    }
}

extension CSSElement : Equatable
{
    public static func == (lhs: CSSElement, rhs: CSSElement) -> Bool
    {
        switch(lhs, rhs)
        {
            case (.any, .any), (.none, .none):
                return true
            case (.element(let lhsName), .element(let rhsName)):
                    return lhsName == rhsName
            default:
                return false
        }
    }
}

extension StyleSelector : Equatable
{
    public static func == (lhs: StyleSelector, rhs: StyleSelector) -> Bool
    {
        if lhs.element != rhs.element
        {
            return false
        }
        
        if lhs.styleIdentifier != rhs.styleIdentifier
        {
            return false
        }
        
        if lhs.pseudoElement != rhs.pseudoElement
        {
            return false
        }
        
        switch(lhs.pseudoClasses, rhs.pseudoClasses)
        {
            case (.some(let lhsPseudoClasses), .some(let rhsPseudoClasses)):
                if lhsPseudoClasses != rhsPseudoClasses
                {
                    return false
                }
            case (.none, .none):
                break
            default:
                return false
        }
        return true
    }
}

public extension Array where Element : CSSRankable
{
    var specificity: CSSSpecificity
    {
        var result = CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 0)
        
        for aSelector in self
        {
            let specificity = aSelector.specificity
            result = result + specificity
        }
        return result
    }
}

