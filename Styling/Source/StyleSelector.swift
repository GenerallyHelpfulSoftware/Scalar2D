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
    var identifier: String? {get}
    var className: String? {get}
    var elementName: String? {get}
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

public protocol CSSRankable {
    var specificity: CSSSpecificity{get}
}

public enum Nth
{
    case odd
    case even
    case nth(Int)
    case linear(Int, Int)
    // case function
}

public enum PseudoClass  : CSSRankable
{
    case custom(String)
    case any
    case not(StyleSelector)
    case nth_child(Nth)
    case nth_of_type(Nth)
    case focus
    case last_child
    case active
    case link
    case checked
    case dir
    case nth_last_of_type
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
    
    public var specificity: CSSSpecificity
    {
        return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 1)
    }
}

public enum AttributePosition
{
    case equals
    case prefix
    case suffix
    case contains
}

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
                return element.elementName == name
        }
    }
}

public struct StyleSelector : CSSRankable
{
    let element: CSSElement
    let identifier: String?
    let className: String?
    let pseudoClasses: [PseudoClass]?
    let pseudoElement: PseudoElement?
    
    public init(element: CSSElement  = .none, identifier: String? = nil, className: String? = nil, pseudoClasses: [PseudoClass]? = nil, pseudoElement: PseudoElement? = nil)
    {
        self.element = element
        self.identifier = identifier
        self.className = className
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
        if let _ = self.identifier
        {
            result = result + CSSSpecificity(identifierCount: 1, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 0)
        }
        
        if let _ = self.className
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
        
        if self.identifier != testItem.identifier
        {
            return false
        }
        
        if self.className != testItem.className
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
        
        if lhs.identifier != rhs.identifier
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

