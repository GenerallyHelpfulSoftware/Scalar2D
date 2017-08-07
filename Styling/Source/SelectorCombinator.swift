//
//  SelectorCombinator.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/6/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation

public enum SelectorCombinator : CSSRankable
{
    case selector(StyleSelector)
    case child // >
    case adjacentSibling // +
    case sibling // ~
    case descendant // >> or space
    
    public var specificity: CSSSpecificity
    {
        switch self {
        case .selector(let selector):
            return selector.specificity
        default:
            return CSSSpecificity(identifierCount: 0, classesAttributesPseudoClassesCount: 0, elementPseudoElementCount: 0)
        }
    }
}

extension SelectorCombinator : Equatable
{
    public static func == (lhs: SelectorCombinator, rhs: SelectorCombinator) -> Bool
    {
        return false 
    }
}

