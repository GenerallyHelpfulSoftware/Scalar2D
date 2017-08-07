//
//  StyleBlock.swift
//  Scalar2D
//
//  Created by Glenn Howes on 11/14/16.
//  Copyright © 2016-2017 Generally Helpful Software. All rights reserved.
//

import Foundation

public protocol CSSContext
{
    func test(_ testItem:CSSIdentifiable, for pseudoClass: PseudoClass) -> Bool
    func test(_ testItem:CSSIdentifiable, for pseudoElement: PseudoElement) -> Bool
}

public struct StyleBlock
{
    public let combinators:[[SelectorCombinator]]
    public let styles:[GraphicStyle]
    
    
    public init(combinators: [[SelectorCombinator]], styles: [GraphicStyle])
    {
        self.combinators = combinators
        self.styles = styles
    }
    /**
         Since many test cases involve simple, standalone StyleSelectors and not child, ancestor, sibling combinations, this constructor is provided.
     */
    public init(selectors: [StyleSelector], styles: [GraphicStyle]) {
        self.init(combinators: selectors.map{[SelectorCombinator.selector($0)]},styles: styles)
    }
}

extension StyleBlock: Equatable {
    public static func == (lhs: StyleBlock, rhs: StyleBlock) -> Bool
    {
        if lhs.styles != rhs.styles
        {
            return false
        }
        
        if lhs.combinators.count != rhs.combinators.count
        {
            return false
        }
        
        for index in 0..<lhs.combinators.count
        {
            let lhsCombination = lhs.combinators[index]
            let rhsCombination = rhs.combinators[index]
            if lhsCombination != rhsCombination
            {
                return false
            }
        }
        
        return true
    }
}

fileprivate struct RankedGraphicStyle
{
    let graphicStyle: GraphicStyle
    let specificity: CSSSpecificity
}

//extension Array where Element: StyleBlock
//{
//    
//    public func properties(for element: CSSIdentifiable, given context: CSSContext) -> [GraphicStyle]
//    {
//        var propertyMap = [String: RankedGraphicStyle]()
//        
//        for aStyleBlock in self
//        {
//            var bestSpecifity : CSSSpecificity?
//            for aSelector in aStyleBlock.selectors
//            {
//                if aSelector.applies(to: element, given: context)
//                {
//                    let specificity = aSelector.specificity
//                    if let oldSpecificty = bestSpecifity
//                    {
//                        bestSpecifity = (oldSpecificty < specificity) ? specificity : oldSpecificty
//                    }
//                    else
//                    {
//                        bestSpecifity = specificity
//                    }
//                }
//            }
//            
//            if let thisSpecificty = bestSpecifity
//            {
//                for aStyle in aStyleBlock.styles
//                {
//                    let key = aStyle.key
//                    if let oldValue = propertyMap[key]
//                    {
//                        if aStyle.value.important || oldValue.specificty <= thisSpecificty
//                        {
//                            propertyMap[key] = RankedGraphicStyle(graphicStyle: aStyle.value, specificity: thisSpecificty)
//                        }
//                    }
//                    else
//                    {
//                        propertyMap[key] = RankedGraphicStyle(graphicStyle: aStyle.value, specificity: thisSpecificty)
//                    }
//                }
//            }
//        }
//        
//        
//        return propertyMap.map{return $0.graphicStyle}
//    }
//}

