//
//  FontDescription.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/26/17.
//  Copyright © 2017-2019 Generally Helpful Software. All rights reserved.
//
//
//
// The MIT License (MIT)

//  Copyright (c) 2016-2019 Generally Helpful Software

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

public enum FontWeight : InheritableProperty, Equatable
{
    public static let boldWeight = 700
    public static let normalWeight = 400
    case initial
    case inherit
    
    case normal
    case bold
    case bolder
    case lighter
    case custom(Int)
    
    public static func ==(lhs: FontWeight, rhs: FontWeight) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial), (.inherit, .inherit), (.normal, .normal), (.bold, .bold), (.lighter, .lighter):
            return true
        case (.custom(let lhsWeight), .custom(let rhsWeight)):
            return lhsWeight == rhsWeight
        
        default:
            return false
        }
    }
    
    //InheritableProperty
    public var useInitial: Bool
    {
        return  .initial == self
    }
    //InheritableProperty
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    //InheritableProperty
    public var useNormal: Bool
    {
        return  .normal == self
    }
    
    public func equivalentWeight(forStartWeight startWeight: Int) -> Int?
    {
        switch self
        {
            case .inherit:
                return startWeight
            case .initial:
                return nil
            case .normal:
                return FontWeight.normalWeight
            case .bold:
                return FontWeight.boldWeight
            case .bolder:
                switch startWeight
                {
                    case 0..<400:
                        return FontWeight.normalWeight
                    case 400..<600:
                        return FontWeight.boldWeight
                    case 600...900:
                        return 900
                    default:
                        return nil
                }
            case .lighter:
                switch startWeight
                {
                    case 100..<600:
                        return 100
                    case 600..<800:
                        return FontWeight.normalWeight
                    case 800...900:
                        return FontWeight.boldWeight
                    default:
                        return nil
                }
            case .custom(let result):
                return result
        }
    }
}

public enum FontVariant : InheritableProperty, Equatable, CaseIterable
{
    case inherit
    case initial
    
    case normal
    case smallCaps
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .normal == self
    }
}

public enum FontStyle : InheritableProperty, Equatable, CaseIterable
{
    case initial
    case inherit
    
    case normal
    case italic
    case oblique
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .normal == self
    }
}

public enum TextDecoration : InheritableProperty, Equatable
{
    case initial
    case inherit
    case noDecoration
    
    case underline
    case overline
    case lineThrough
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .noDecoration == self
    }
}

public enum FontStretch : InheritableProperty, Equatable, CaseIterable
{
    case normal
    case initial
    case inherit
    
    case ultraCondensed
    case extraCondensed
    case condensed
    case semiCondensed
    case semiExpanded
    case expanded
    case extraExpanded
    case ultraExpanded
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .normal == self
    }
}

public enum DynamicSize : Equatable
{
    case custom(String)
    case title1
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption1
    case caption2
    
    public static func ==(lhs: DynamicSize, rhs: DynamicSize) -> Bool {
        switch (lhs, rhs)
        {
            case (.title1, .title1), (.title2, .title2), (.title3, .title3), (.headline,  .headline), (.subheadline, .subheadline), (.body, .body),
                 (.callout, .callout), (.footnote, .footnote), (.caption1, .caption1), (.caption2, .caption2):
                return true
            case (.custom(let lhsValue), .custom(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
        }
    }
}

extension String.UnicodeScalarView
{
    func extractValueAndUnit(fromRange range: Range<String.UnicodeScalarView.Index>) -> (Double?, String?, String.UnicodeScalarView.Index)
    {
        let stringBegin = range.lowerBound
        var unitsBegin = range.upperBound
        var cursor = stringBegin
        var hadPeriod = false
        var findingUnits = false
        var valueString = String(self[range])
        
        characterLoop: while range.contains(cursor)
        {
            let character = self[cursor]
            if findingUnits
            {
                switch character
                {
                    case " ", "\t", " ", "\n":
                    break characterLoop
                    default:
                    break
                }
            }
            else
            {
                switch(character)
                {
                    case "0"..."9":
                        break
                    case ".":
                        if hadPeriod // two periods
                        {
                            return (nil, nil, cursor)
                        }
                        else
                        {
                            hadPeriod = true
                        }
                    
                    case " ", "\t", " ", "\n":
                        valueString = String(self[stringBegin..<cursor])
                        break characterLoop
                    default:
                        valueString = String(self[stringBegin..<cursor])
                        findingUnits = true
                        unitsBegin = cursor
                }
            }
            cursor = self.index(after: cursor)
        }
        if findingUnits && cursor != unitsBegin
        {
            let unitRange = unitsBegin..<cursor
            let unitString = String(self[unitRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !unitString.isEmpty
            {
                return (Double(valueString), unitString, cursor)
            }
        }
        
        return (Double(valueString), nil, cursor)
    }
}

extension String
{
    func extractValueAndUnit() throws -> (Double?, String?, String.UnicodeScalarView.Index)
    {
        let scalars = self.unicodeScalars
        let stringBegin = try scalars.findUncommentedIndex()
        let stringEnd = scalars.endIndex
        return scalars.extractValueAndUnit(fromRange: stringBegin..<stringEnd)
    }
}

public enum FontSize : InheritableProperty, Equatable
{
    case initial
    case inherit
    
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case xxLarge
    
    case larger
    case smaller
    
    case percentage(Double)
    case point(Double)
    case pixel(Double)
    case em(Double)
    case rem(Double)
    case ex(Double)
    case viewPortH(Double)
    case viewPortW(Double)
    case ch(Double)
    
    case dynamic(DynamicSize) // make use of the dynamic type system for accessibiity (not in w3c)
    
    public static func ==(lhs: FontSize, rhs: FontSize) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial), (.inherit, .inherit), (.xxSmall, .xxSmall), (.xSmall, .xSmall), (.small, .small), (.medium, .medium),
             (.large, .large), (.xLarge, .xLarge), (.xxLarge, .xxLarge), (.larger, .larger), (.smaller, .smaller):
            return true
        case (.percentage(let lhsValue), .percentage(let rhsValue)), (.em(let lhsValue), .em(let rhsValue)), (.rem(let lhsValue), .rem(let rhsValue)),  (.ex(let lhsValue), .ex(let rhsValue)), (.viewPortH(let lhsValue), .viewPortH(let rhsValue)), (.ch(let lhsValue), .ch(let rhsValue)), (.point(let lhsValue), .point(let rhsValue)), (.viewPortW(let lhsValue), .viewPortW(let rhsValue)), (.pixel(let lhsValue), .pixel(let rhsValue)):
            return lhsValue == rhsValue
        
        case (.dynamic(let lhsValue), .dynamic(let rhsValue)):
            return lhsValue == rhsValue

        default:
            return false
        }
    }
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .medium == self
    }
    
    init?(value: Double?, unit: String?)
    {
        if let value = value
        {
            if let unit = unit
            {
                switch unit
                {
                    case "%":
                        self = FontSize.percentage(value)
                    case "px":
                        self = FontSize.pixel(value)
                    case "pt":
                        self = FontSize.point(value)
                    case "em":
                        self = FontSize.em(value)
                    case "rem":
                        self = FontSize.rem(value)
                    case "ex":
                        self = FontSize.ex(value)
                    case "vh":
                        self = FontSize.viewPortH(value)
                    case "vw":
                        self = FontSize.viewPortW(value)
                    case "ch":
                        self = FontSize.ch(value)
                    default:
                    return nil
                }
            }
            else
            {
                self = FontSize.point(value)
            }
        }
        else if let enumeration = unit
        {
            switch enumeration
            {
                case "initial":
                    self = FontSize.initial
                case "inherit":
                    self = FontSize.inherit
                case "medium":
                    self = FontSize.medium
                case "xx-small":
                    self = .xxSmall
                case "x-small":
                    self = .xSmall
                case "small":
                    self = .small
                case "large":
                    self = .large
                case "x-large":
                    self = .xLarge
                case "xx-large":
                    self = .xxLarge
                case "smaller":
                    self = .smaller
                case "larger":
                    self = .larger
                default:
                    return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    init?(string: String) throws
    {
        let valueAndUnit = try string.extractValueAndUnit()
        self.init(value: valueAndUnit.0, unit: valueAndUnit.1)
    }
}

public enum Distance  : InheritableProperty, Equatable
{
    case initial
    case inherit
    case normal
    
    case multiplier(Double)
    case inUnits(Double, StyleUnit)
    
    public static func ==(lhs: Distance, rhs: Distance) -> Bool {
        switch (lhs, rhs)
        {
            case (.initial, .initial), (.inherit, .inherit), (.normal, .normal):
                return true
            
            case (.multiplier(let lhsValue), .multiplier(let rhsValue)):
                return lhsValue == rhsValue
            
            case (.inUnits(let lhsValue, let lhsUnits), .inUnits(let rhsValue, let rhsUnits)):
                return lhsValue == rhsValue && lhsUnits == rhsUnits
            default:
                return false
        }
    }
    //InheritableProperty
    public var useInitial: Bool
    {
        return  .initial == self
    }
    //InheritableProperty
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    //InheritableProperty
    public var useNormal: Bool
    {
        return  .normal == self
    }
    
    init?(value: Double?, unit: String?)
    {
        if let value = value
        {
            if let unit = unit
            {
                switch unit
                {
                case "%":
                    self = Distance.inUnits(value, .percent)
                case "px":
                    self = Distance.inUnits(value, .pixel)
                case "pt":
                    self = Distance.inUnits(value, .point)
                case "cm":
                    self = Distance.inUnits(value, .centimeter)
                default:
                    return nil
                }
            }
            else
            {
                self = Distance.multiplier(value)
            }
        }
        else if let enumeration = unit
        {
            switch enumeration
            {
                case "initial":
                    self = Distance.initial
                case "inherit":
                    self = Distance.inherit
                case "normal":
                    self = Distance.normal
                default:
                    return nil
            }
        }
        else
        {
            return nil
        }
    }

    init? (string: String) throws
    {
        let valueAndUnit = try string.extractValueAndUnit()
        self.init(value: valueAndUnit.0, unit: valueAndUnit.1)
    }
}

public enum FontFamily : InheritableProperty, Equatable
{
    case initial
    case inherit
    
    case named(String) // extreme preference for valid Postscript name
    case serif
    case sansSerif
    case cursive
    case fantasy
    case monospace
    
    case system // not in W3C standard
    
    public static func ==(lhs: FontFamily, rhs: FontFamily) -> Bool {
        switch (lhs, rhs)
        {
            case (.initial, .initial), (.inherit, .inherit), (.serif, .serif), (.sansSerif, .sansSerif), (.cursive, .cursive),
                 (.fantasy, .fantasy), (.monospace, .monospace), (.system, .system):
                return true
            case (.named(let lhsValue), .named(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
        }
    }
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .system == self
    }
    
    public var cssName : String
    {
        switch self
        {
            case .inherit:
                return "inherit"
            case .initial:
                return "initial"
            case .cursive:
                return "cursive"
            case .fantasy:
                return "fantasy"
            case .monospace:
                return "monospace"
            case .sansSerif:
                return "sans-serif"
            case .serif:
                return "serif"
            case .named(_):
                return ""
            case .system:
                return "system"
        }
    }
    
    init?(string: String)
    {
        switch string {
            case "inherit":
                self = .inherit
            case "initial":
                self = .initial
            case "cursive":
                self = .cursive
            case "system":
                self = .system
            case "serif":
                self = .serif
            case "sans-serif":
                self = .sansSerif
            case "monospace":
                self = .monospace
            default:
                if string.isEmpty
                {
                    return nil
                }
                else
                {
                    self = .named(string)
                }
        }
    }
}
/**
    FontDescription is a collection of all the standard properties that describe a font.
*/
public struct FontDescription
{
    let families : [FontFamily]
    let size : FontSize
    let weight : FontWeight
    let stretch : FontStretch
    let decorations : Set<TextDecoration>
    let style : FontStyle
    let variant : FontVariant
    let lineHeight : Distance
    let characterSetLimit : CharacterSet?
    
    public init(
            families: [FontFamily] = [.inherit],
            size : FontSize = .inherit,
            weight : FontWeight = .inherit,
            stretch : FontStretch = .inherit,
            decorations : Set<TextDecoration> = [.inherit],
            style : FontStyle = .inherit,
            variant : FontVariant = .inherit,
            lineHeight : Distance = .inherit,
            characterSetLimit : CharacterSet? = nil
    )
    {
        self.families = families
        self.size = size
        self.weight = weight
        self.stretch = stretch
        self.decorations = decorations
        self.style = style
        self.variant = variant
        self.lineHeight = lineHeight
        self.characterSetLimit = characterSetLimit
    }
    
}
