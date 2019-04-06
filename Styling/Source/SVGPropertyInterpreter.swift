//
//  SVGPropertyInterpreter.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/20/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
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

/**
  Protocol promises to return a name of a property (presumably found in some css being parsed)
*/
public protocol ParseableEnum
{
    var cssName : String {get}
}

public protocol SimpleParseableEnum : ParseableEnum
{
    /**
        implementers of this protocol provide a list of all the known css property names
    */
    static var all : [ParseableEnum] {get}
}

public extension PropertyKey // compositing
{
    static let display = PropertyKey(rawValue: "display")!
    static let colour = PropertyKey(rawValue: "color")!
    static let opacity = PropertyKey(rawValue: "opacity")!
    static let blending_mode = PropertyKey(rawValue: "mix-blend-mode")!
}

public extension PropertyKey // font
{
    static let font_size = PropertyKey(rawValue: "font-size")!
    static let font_weight = PropertyKey(rawValue: "font-weight")!
    static let font_style = PropertyKey(rawValue: "font-style")!
    static let font_variant = PropertyKey(rawValue: "font-variant")!
    static let font_line_height = PropertyKey(rawValue: "line-height")!
    static let font_family = PropertyKey(rawValue: "font-family")!
    static let font_stretch = PropertyKey(rawValue: "font-stretch")!
    static let font = PropertyKey(rawValue: "font")!
}

public extension PropertyKey // path
{
    static let stroke_width = PropertyKey(rawValue: "stroke-width")!
    static let fill = PropertyKey(rawValue: "fill")!
    static let stroke = PropertyKey(rawValue: "stroke")!
    
    static let line_cap = PropertyKey(rawValue: "stroke-linecap")!
    static let miter_limit = PropertyKey(rawValue: "stroke-miterlimit")!
    static let line_join = PropertyKey(rawValue: "stroke-linejoin")!
    static let stroke_dash_array = PropertyKey(rawValue: "stroke-dasharray")!
    static let stroke_dash_offset = PropertyKey(rawValue: "stroke-dashoffset")!
}

/**
    enumeration of possible font style keys (as opposed to variants, weights, etc.)
*/
extension FontStyle : SimpleParseableEnum
{
    public var cssName : String
    {
        switch self
        {
            case .inherit:
                return "inherit"
            case .initial:
                return "initial"
            case .italic:
                return "italic"
            case .normal:
                return "normal"
            case .oblique:
                return "oblique"
        }
    }
    public static var all : [ParseableEnum]
    {
        return [FontStyle.inherit, FontStyle.initial, FontStyle.italic, FontStyle.normal, FontStyle.oblique]
    }
}


/**
 enumeration of possible font variant keys (as opposed to styles, weights, etc.)
 */
extension FontVariant : SimpleParseableEnum
{
    public var cssName : String
    {
        switch self
        {
            case .inherit:
                return "inherit"
            case .initial:
                return "initial"
            case .smallCaps:
                return "small-caps"
            case .normal:
                return "normal"
        }
    }
    public static var all : [ParseableEnum]
    {
        return [FontVariant.inherit, FontVariant.initial, FontVariant.normal, FontVariant.smallCaps]
    }
}

/**
 enumeration of possible font weights keys (as opposed to styles, variants, etc.)
 */
extension FontWeight : SimpleParseableEnum
{
    public var cssName : String
    {
        switch self
        {
            case .inherit:
                return "inherit"
            case .initial:
                return "initial"
            case .bold:
                return "bold"
            case .bolder:
                return "bolder"
            case .lighter:
                return "lighter"
            case .normal:
                return "normal"
            case .custom(_):
                return ""
        }
    }
    public static var all : [ParseableEnum]
    {
        return [FontWeight.inherit, FontWeight.initial, FontWeight.bold, FontWeight.bolder, FontWeight.lighter]
    }
}
/**
    enumeration of possible font stretchs keys (as opposed to styles, variants, etc.), allows the letters to be squished together or stretched apart.
 */
extension FontStretch : SimpleParseableEnum
{
    public var cssName : String
    {
        switch self
        {
            case .inherit:
                return "inherit"
            case .initial:
                return "initial"
            case .condensed:
                return "condensed"
            case .expanded:
                return "expanded"
            case .extraCondensed:
                return "extra-condensed"
            case .extraExpanded:
                return "extra-expanded"
            case .normal:
                return "normal"
            case .semiExpanded:
                return "semi-expanded"
            case .semiCondensed:
                return "semi-condensed"
            case .ultraExpanded:
                return "ultra-expanded"
            case .ultraCondensed:
                return "ultra-condensed"
        }
    }
    public static var all : [ParseableEnum]
    {
        return [FontStretch.inherit, FontStretch.initial, FontStretch.condensed, FontStretch.expanded, FontStretch.extraCondensed,
        FontStretch.extraExpanded, FontStretch.normal, FontStretch.semiExpanded, FontStretch.semiCondensed, FontStretch.ultraExpanded,
        FontStretch.ultraCondensed]
    }
}
/**
 enumeration of possible font names, wether explicit or by function .
 */
extension FontFamily : SimpleParseableEnum
{
    public static var all : [ParseableEnum]
    {
        return [FontFamily.inherit, FontFamily.initial, FontFamily.cursive, FontFamily.fantasy, FontFamily.monospace, FontFamily.sansSerif, FontFamily.serif]
    }
}

extension LineCap : SimpleParseableEnum
{
    public var cssName: String {
        switch self
        {
            case .inherit:
                return "inherit"
            case .initial:
                return "initial"
            case .normal:
                return "normal"
            case .butt:
                return "butt"
            case .round:
                return "round"
            case .square:
                return "square"
        }
    }
    
    public static var all : [ParseableEnum]
    {
        return [LineCap.inherit, LineCap.initial, LineCap.butt, LineCap.normal, LineCap.round, LineCap.square]
    }
}

/**
    Look through a string buffer for a given prefix and return its index, if found.
 
 - parameter prefix:String    usually a key like "inherited"
 - parameter inBuffer: String.UnicodeScalarView the buffer to look though
 - parameter atValueRange: the portion of the inBuffer to search though
 
 
 - throws an error if an error such as an unexpected ending happens
 
 - returns optional location after the end of the prefix, nil if not found.
*/
public func findPrefix(_ prefix: String, inBuffer buffer: String.UnicodeScalarView, atValueRange valueRange: Range<String.UnicodeScalarView.Index>) throws -> String.UnicodeScalarView.Index?
{
    let prefixBuffer = prefix.unicodeScalars
    var prefixCursor = try prefixBuffer.findUncommentedIndex()
    let prefixRange = prefixCursor..<prefixBuffer.endIndex
    var sourceCursor = valueRange.lowerBound
    while valueRange.contains(sourceCursor)
    {
        if prefixRange.contains(prefixCursor)
        {
            var testCharacter = buffer[sourceCursor]
            
            if testCharacter.isASCII
            {
                let testValue = testCharacter.value
                if testValue >= 65 && testValue <= 90
                { // uppercase ascii
                    testCharacter = UnicodeScalar(testValue+32)! // convert to lowercased ASCII as CSS is not (in general) case sensitive
                }
            }
            let prefixCharacter = prefixBuffer[prefixCursor]
            if testCharacter != prefixCharacter
            {
                return nil
            }
            prefixCursor = try prefixBuffer.uncommentedIndex(after: prefixCursor)
        }
        if !prefixRange.contains(prefixCursor)
        {
            return sourceCursor
        }
        sourceCursor = try buffer.uncommentedIndex(after: sourceCursor)
    }
    return nil
}

extension Unicode.Scalar
{
    /**
        can we treat this scalar character as white space. Might be missing some.
    */
    var isAcceptableWhitespace : Bool
    {
        return self == " " || self == "\t" || self == " "
    }
}

extension SimpleParseableEnum
{
    /**
        given a buffer and a range, search for this enum's cssName
     - parameter inBuffer: String.UnicodeScalarView the buffer to look though
     - parameter atValueRange: the portion of the inBuffer to search though
     
     
     - throws an error if an error such as an unexpected ending is found
     
     - returns optional location after the prefix, nil if not found. and a Parseable enum as a tuple
     
    */
    static func find(inBuffer buffer: String.UnicodeScalarView, atValueRange valueRange: Range<String.UnicodeScalarView.Index>) throws -> (String.UnicodeScalarView.Index, ParseableEnum)?
    {
        
        let tries = self.all
        for aTry in tries
        {
            if let foundEnd = try findPrefix(aTry.cssName, inBuffer: buffer, atValueRange: valueRange)
            {
                let nextEnd = try buffer.uncommentedIndex(after: foundEnd)
                if(!valueRange.contains(nextEnd) || buffer[nextEnd].isAcceptableWhitespace)
                {
                    return (foundEnd, aTry)
                }
            }
        }
        return nil
    }
}

/**
    Class devoted to parsing css like content
*/
open class CommonStyleInterpretter : StylePropertyInterpreter
{
    
    /**
        The ! operator in css indicates overriding the normal styling cascade (exists to make my life difficult). This method is called when
        a ! is found in the text.
     
     - parameter buffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     
     - throws an error if an error such as an unexpected ending is found
     
     - returns optional location after the prefix, nil if not found.
     
    */
    public final func interpretImportant(buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> String.UnicodeScalarView.Index
    {
        guard let result = try findPrefix("!important", inBuffer: buffer, atValueRange: valueRange) else
        {
            throw StylePropertyFailureReason.incompleteImportant(valueRange.lowerBound)
        }
        return result
    }
    /**
        Called at a point where some name of a font is expected, either an explicit name or a functional type like sanserif
     
     - parameter buffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     - throws an error if an error such as an unexpected ending is found
     
    - returns a tuple containing a list of FontFamily enumerations, the location after the find, and a Bool flag indicating this styling is important
    */
    final fileprivate func extractFontNames(buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([FontFamily], String.UnicodeScalarView.Index, Bool)
    {
        enum State
        {
            case readingFamilyNames
            case inFamilyName
        }
        var families = [FontFamily]()
        var state = State.readingFamilyNames
        var inQuote = false
        var cursor = valueRange.lowerBound
        var sectionBegin = cursor
        var isImportant = false
        parseLoop: while valueRange.contains(cursor)
        {
            let character = buffer[cursor]
            switch state
            {
            case .readingFamilyNames:
                switch character
                {
                case "\"":
                    inQuote = true
                    state = .inFamilyName
                    sectionBegin = buffer.index(after: cursor)
                case " ", "\t", " ", "\n":
                    break
                case "!":
                    cursor = try self.interpretImportant(buffer: buffer, valueRange: cursor..<valueRange.upperBound)
                    isImportant = true
                    break parseLoop
                case ";":
                    break parseLoop
                case ",":
                    throw StylePropertyFailureReason.incompleteProperty("font", cursor)
                default:
                    state = .inFamilyName
                    sectionBegin = cursor
                    
                }
            case .inFamilyName:
                if inQuote
                {
                    if character == "\""
                    {
                        let fontName = String(buffer[sectionBegin..<cursor])
                        
                        if fontName.isEmpty
                        {
                            throw StylePropertyFailureReason.incompleteProperty("font", cursor)
                        }
                        families.append(FontFamily.named(fontName))
                        
                        inQuote = false
                        state = .readingFamilyNames
                    }
                }
                else
                {
                    switch character
                    {
                    case "\"":
                        inQuote = true
                        sectionBegin = buffer.index(after: cursor)
                        if !valueRange.contains(sectionBegin)
                        {
                            throw StylePropertyFailureReason.incompleteProperty("font", cursor)
                        }
                    case "!":
                        cursor = try self.interpretImportant(buffer: buffer, valueRange: cursor..<valueRange.upperBound)
                        isImportant = true
                        break parseLoop

                    case ",", ";", " ", "\t", " ", "\n":
                        let aString = String(buffer[sectionBegin..<cursor]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        if aString.isEmpty
                        {
                            throw StylePropertyFailureReason.incompleteProperty("font", sectionBegin)
                        }
                        if let font = FontFamily(string: aString)
                        {
                            families.append(font)
                        }
                        state = .readingFamilyNames
                        if character == ";"
                        {
                            break parseLoop
                        }
                    default:
                        
                        break
                    }
                }
                
            }
            if inQuote
            {
                cursor = buffer.index(after: cursor)
            }
            else
            {
                cursor = try buffer.uncommentedIndex(after: cursor)
            }
        }
        
        if state == .inFamilyName
        {
            let aString = String(buffer[sectionBegin..<cursor]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if !aString.isEmpty
            {
                if let font = FontFamily(string: aString)
                {
                    families.append(font)
                }
            }
        }
        
        if inQuote
        {
            throw StylePropertyFailureReason.nonMatchingQuote(sectionBegin)
        }
        return (families, cursor, isImportant)
    }
    /**
        Look through a buffer for a variety of font related properties
     
     - parameter buffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     
     - throws an error if an error such as an unexpected ending is found
     
     - returns a tuple containing a list of GraphicStyles and the location after the find
     
    */
    final fileprivate func interpretFontProperty(buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
    {
        enum State
        {
            case awaitingNumber
            case awaitingSlash
            case awaitingEndLineHeight
        }
        
        var state = State.awaitingNumber
        var cursor = valueRange.lowerBound
        var result = [GraphicStyle]()
        var sectionBegin = cursor
        var seenPeriod = false
        
        var style: FontStyle?
        var weight: FontWeight?
        var variant: FontVariant?
        var fontSize : FontSize?
        var stretch : FontStretch?
        var lineHeight : LineHeight?
        var families = [FontFamily]()
        
        var isImportant = false
        
        parseLoop: while valueRange.contains(cursor)
        {
            let character = buffer[cursor]
            switch state
            {
                case .awaitingNumber:
                    switch character
                    {
                        case "!":
                            throw StylePropertyFailureReason.incompleteProperty("font", cursor)
                        case "0"..."9":
                            state = .awaitingSlash
                            sectionBegin = cursor
                        case ";":
                            throw StylePropertyFailureReason.unexpectedSemiColon(cursor)
                        case " ", "\t", " ", "\n":
                            cursor = try buffer.uncommentedIndex(after: cursor)
                        default: // see if there is style, weight or variant in this list
                            let availableRange = cursor..<valueRange.upperBound
                            if let theStyle = try FontStyle.find(inBuffer: buffer, atValueRange: availableRange) as? (String.UnicodeScalarView.Index, FontStyle)
                            {
                                cursor = try buffer.uncommentedIndex(after: theStyle.0)
                                style = theStyle.1
                            }
                            else if let theWeight = try FontWeight.find(inBuffer: buffer, atValueRange: availableRange) as?  (String.UnicodeScalarView.Index, FontWeight)
                            {
                                cursor = try buffer.uncommentedIndex(after: theWeight.0)
                                weight = theWeight.1
                            }
                            else if let theVariant = try FontVariant.find(inBuffer: buffer, atValueRange: availableRange)  as?  (String.UnicodeScalarView.Index, FontVariant)
                            {
                                cursor = try buffer.uncommentedIndex(after: theVariant.0)
                                variant = theVariant.1
                            }
                            else if let theStretch = try FontStretch.find(inBuffer: buffer, atValueRange: availableRange)  as?  (String.UnicodeScalarView.Index, FontStretch)
                            {
                                cursor = try buffer.uncommentedIndex(after: theStretch.0)
                                stretch = theStretch.1
                            }

                            else
                            {
                                throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                            }
                    }
                case .awaitingSlash:
                    switch character
                    {
                        case "0"..."9":
                            cursor = try buffer.uncommentedIndex(after: cursor)
                        case ".":
                            if seenPeriod
                            {
                                throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                            }
                            seenPeriod = true
                        case " ", "\t", " ", "\n":
                            let sizeString = String(buffer[sectionBegin..<cursor])
                            fontSize = try FontSize(string: sizeString)
                            let (newFontFamilies, newCursor, newIsImportant) = try self.extractFontNames(buffer: buffer, valueRange: cursor..<valueRange.upperBound)
                            families = newFontFamilies
                            cursor = newCursor
                            isImportant = newIsImportant
                            break parseLoop
                        case "/":
                            state = .awaitingEndLineHeight
                            let sizeString = String(buffer[sectionBegin..<cursor])
                            fontSize = try FontSize(string: sizeString)
                            sectionBegin = try buffer.uncommentedIndex(after: cursor)
                            cursor = sectionBegin
                            seenPeriod = false
                        default:
                            if !character.isASCII
                            {
                                throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                            }
                            cursor = try buffer.uncommentedIndex(after: cursor)
                    }
                case .awaitingEndLineHeight:
                    switch character
                    {
                        case "0"..."9":
                            cursor = try buffer.uncommentedIndex(after: cursor)
                        case ".":
                            if seenPeriod
                            {
                                throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                            }
                            seenPeriod = true
                            cursor = try buffer.uncommentedIndex(after: cursor)
                        case " ", "\t", " ", "\n":
                            let lineHeightString = String(buffer[sectionBegin..<cursor])
                            lineHeight = try LineHeight(string: lineHeightString)
                            let (newFontFamilies, newCursor, newImportant) = try self.extractFontNames(buffer: buffer, valueRange: cursor..<valueRange.upperBound)
                            families = newFontFamilies
                            cursor = newCursor
                            isImportant = newImportant
                            break parseLoop
                        default:
                            throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                    }
            }
        }
        
        
        if let theSize = fontSize
        {
            result.append(GraphicStyle(key: .font_size, value: StyleProperty.fontSize(theSize), important: isImportant))
        }
        
        if let theWeight = weight
        {
            result.append(GraphicStyle(key: .font_weight, value: StyleProperty.fontWeight(theWeight), important: isImportant))
        }
        if let theStyle = style
        {
            result.append(GraphicStyle(key: .font_style, value: StyleProperty.fontStyle(theStyle), important: isImportant))
        }
        if let theVariant = variant
        {
            result.append(GraphicStyle(key: .font_variant, value: StyleProperty.fontVariant(theVariant), important: isImportant))
        }
        
        if let theHeight = lineHeight
        {
            result.append(GraphicStyle(key: .font_line_height, value: StyleProperty.lineHeight(theHeight), important: isImportant))
        }
        
        if !families.isEmpty
        {
            result.append(GraphicStyle(key: .font_family, value: StyleProperty.fontFamilies(families)))
        }
        

        if let theStretch = stretch
        {
            result.append(GraphicStyle(key: .font_stretch, value: StyleProperty.fontStretch(theStretch), important: isImportant))
        }
        
        return (result, cursor)
        
    }
    /**
        Look through a buffer for a well formed property
     
     - parameter key of the property (used for informational purposes if an error is thrown)
     - parameter fromBuffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     
     - throws an error if an error such as a badly formed property
     
        - returns a tuple with the range of the found property, a flag indicating it's important and the index after the property
    */
    fileprivate func extract(key: PropertyKey,  fromBuffer buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> (Range<String.UnicodeScalarView.Index>, Bool, String.UnicodeScalarView.Index)
    {
        var cursor = valueRange.lowerBound
        var isImportant = false
        var propertyRange : Range<String.UnicodeScalarView.Index>? = nil
        parseLoop: while valueRange.contains(cursor)
        {
            let character = buffer[cursor]
            switch character
            {
            case "!":
                propertyRange = valueRange.lowerBound..<cursor
                cursor = try self.interpretImportant(buffer: buffer, valueRange: cursor..<valueRange.upperBound)
                isImportant = true
            case ";":
                break parseLoop
            default:
                break
            }
            
            cursor = try buffer.uncommentedIndex(after: cursor)
        }
        if propertyRange == nil
        {
            propertyRange = valueRange.lowerBound..<valueRange.upperBound
        }
        if propertyRange?.isEmpty ?? true
        {
            throw StylePropertyFailureReason.incompleteProperty(key.rawValue, valueRange.lowerBound)
        }
        return (propertyRange!, isImportant, cursor)
    }
    
    /**
        The beginning of a color property has been detected, extract out the color styles.
     - parameter key of the property (used for informational purposes if an error is thrown)
     - parameter fromBuffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     
     - throws an error if an error such as a badly formed property
     
     - returns a tuple with an array of detected GraphicStyles and the index after the property
     
     */
    fileprivate func interpretColour(key: PropertyKey, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
    {
        let (propertyRange, isImportant, cursor) = try self.extract(key: key, fromBuffer: buffer, valueRange: valueRange)
        let propertyString = String(buffer[propertyRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        do
        {
            let aColorDefinition = try CGColor.standaloneParsers.parseString(source: propertyString,  colorContext: nil)
            let property = StyleProperty.colour(aColorDefinition!, aColorDefinition?.nativeColour)
            return ([GraphicStyle(key: key, value: property, important: isImportant)], cursor)
        }
        catch
        {
            throw StylePropertyFailureReason.badProperty(propertyString, propertyRange.lowerBound)
        }
    }
    
    /**
        The beginning of a dimensional property (pixels, points, etc.) has been detected. This function extracts out the associated styles.
    
     - parameter key of the property (used for informational purposes if an error is thrown)
     - parameter fromBuffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     
     - throws an error if an error such as a badly formed property
     
     - returns a tuple with an array of detected GraphicStyles and the index after the property
     
    */
    fileprivate func interpretDimension(key: PropertyKey, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
    {
        let (propertyRange, isImportant, cursor) = try self.extract(key: key, fromBuffer: buffer, valueRange: valueRange)
        let propertyString = String(buffer[propertyRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        var rawProperty : (Double?, String?)!
        
        do
        {
            rawProperty = try propertyString.trimmingCharacters(in: .whitespacesAndNewlines).extractValueAndUnit()
        }
        catch
        {
            throw StylePropertyFailureReason.badProperty(propertyString, propertyRange.lowerBound)
        }
        
        if let actualValue = rawProperty.0
        {
            if let actualUnit = rawProperty.1, !actualUnit.isEmpty
            {
                guard let styleUnit = actualUnit.asStyleUnit else
                {
                    throw StylePropertyFailureReason.unexpectedCharacter(actualUnit.first!, propertyRange.lowerBound)
                }
                let property = StyleProperty.unitNumber(NativeDimension(actualValue), styleUnit)
                return ([GraphicStyle(key: key, value: property, important: isImportant)], cursor)
            }
            else
            {
                
                let property = StyleProperty.number(Double(actualValue))
                return ([GraphicStyle(key: key, value: property, important: isImportant)], cursor)
            }
        }
        
        throw StylePropertyFailureReason.incompleteProperty(key.rawValue, valueRange.lowerBound)
    }
    
    /**
     The beginning of a font size property has been detected. This function extracts out the associated styles.
     
     - parameter key of the property (used for informational purposes if an error is thrown)
     - parameter fromBuffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     - throws an error if an error such as a badly formed property
     
     - returns a tuple with an array of detected GraphicStyles and the index after the property
     
     */
    fileprivate func interpretFontSize(key: PropertyKey, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
    {
        let (propertyRange, isImportant, cursor) = try self.extract(key: key, fromBuffer: buffer, valueRange: valueRange)
        let propertyString = String(buffer[propertyRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        do
        {
            if let fontSize = try FontSize(string: propertyString)
            {
                let property = StyleProperty.fontSize(fontSize)
                return ([GraphicStyle(key: key, value: property, important: isImportant)], cursor)
                
            }
        }
        catch
        {
            throw StylePropertyFailureReason.badProperty(propertyString, propertyRange.lowerBound)
        }
        throw StylePropertyFailureReason.incompleteProperty(key.rawValue, valueRange.lowerBound)
    }
    
    /**
     The beginning of a font-name property (or the like) has been detected. This function extracts out the associated styles.
     
     - parameter key of the property (used for informational purposes if an error is thrown)
     - parameter fromBuffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     - throws an error if an error such as a badly formed property
     
     - returns a tuple with an array of detected GraphicStyles and the index after the property
     
     */
    fileprivate func interpretFontFamilies(key: PropertyKey, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
    {
        let (families, cursor, isImportant) = try extractFontNames(buffer: buffer, valueRange: valueRange)
        
        return ([GraphicStyle(key: key, value: StyleProperty.fontFamilies(families), important: isImportant)], cursor)
        
    }
    
    /**
     The beginning of some property has been detected. This function extracts out the associated styles.
     
     - parameter key of the property (used for informational purposes if an error is thrown)
     - parameter fromBuffer: String.UnicodeScalarView the buffer to look though
     - parameter valueRange: the portion of the buffer to search though
     
     - throws an error if an error such as a badly formed property
     
     - returns a tuple with an array of detected GraphicStyles and the index after the property
     
     */
    public func interpret(key: PropertyKey, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index) {

        switch key
        {
            case .font:
                return try self.interpretFontProperty(buffer: buffer, valueRange: valueRange)
            case .fill, .stroke, .colour:
                return try self.interpretColour(key: key, buffer: buffer, valueRange: valueRange)
            case .stroke_width:
                return try self.interpretDimension(key: key, buffer: buffer, valueRange: valueRange)
            case .font_family:
                return try self.interpretFontFamilies(key: key, buffer: buffer, valueRange: valueRange)
            case .font_size:
                return try self.interpretFontSize(key: key, buffer: buffer, valueRange: valueRange)
            
            default:
            break
        }
        
        return ([GraphicStyle](), valueRange.lowerBound)
    }
    
    public init()
    {
    }
}


public class SVGPropertyInterpreter : CommonStyleInterpretter
{
    override public func interpret(key: PropertyKey, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index) {
        
        switch key
        {
            default:
            return try super.interpret(key: key, buffer: buffer, valueRange: valueRange)
        }
        
        //return [GraphicStyle]()
    }
    
    
}
