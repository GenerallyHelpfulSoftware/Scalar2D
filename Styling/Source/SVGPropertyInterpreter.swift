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

public protocol ParseableEnum
{
    var cssName : String {get}
}

public protocol SimpleParseableEnum : ParseableEnum
{
    static var all : [ParseableEnum] {get}
}

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

extension FontFamily : SimpleParseableEnum
{
    
    public static var all : [ParseableEnum]
    {
        return [FontFamily.inherit, FontFamily.initial, FontFamily.cursive, FontFamily.fantasy, FontFamily.monospace, FontFamily.sansSerif, FontFamily.serif]
    }
}


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
    var isAcceptableWhitespace : Bool
    {
        return self == " " || self == "\t" || self == " "
    }
}

extension SimpleParseableEnum
{
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

open class CommonStyleInterpretter : StylePropertyInterpreter
{
    public final func interpretImportant(buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> String.UnicodeScalarView.Index
    {
        guard let result = try findPrefix("!important", inBuffer: buffer, atValueRange: valueRange) else
        {
            throw StylePropertyFailureReason.incompleteImportant(valueRange.lowerBound)
        }
        return result
    }
    
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
                        break
                        default: // see if there is style, weight or variant in this list
                            let availableRange = cursor..<valueRange.upperBound
                            if let theStyle = try FontStyle.find(inBuffer: buffer, atValueRange: availableRange) as? (String.UnicodeScalarView.Index, FontStyle)
                            {
                                cursor = theStyle.0
                                style = theStyle.1
                            }
                            else if let theWeight = try FontWeight.find(inBuffer: buffer, atValueRange: availableRange) as?  (String.UnicodeScalarView.Index, FontWeight)
                            {
                                cursor = theWeight.0
                                weight = theWeight.1
                            }
                            else if let theVariant = try FontVariant.find(inBuffer: buffer, atValueRange: availableRange)  as?  (String.UnicodeScalarView.Index, FontVariant)
                            {
                                cursor = theVariant.0
                                variant = theVariant.1
                            }
                            else if let theStretch = try FontStretch.find(inBuffer: buffer, atValueRange: availableRange)  as?  (String.UnicodeScalarView.Index, FontStretch)
                            {
                                cursor = theStretch.0
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
                        break
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
                            seenPeriod = false
                        default:
                            if !character.isASCII
                            {
                                throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                            }
                    }
                case .awaitingEndLineHeight:
                    switch character
                    {
                        case "0"..."9":
                        break
                        case ".":
                            if seenPeriod
                            {
                                throw StylePropertyFailureReason.unexpectedCharacter(Character(character), cursor)
                            }
                            seenPeriod = true
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
            result.append(GraphicStyle(key: "font-size", value: StyleProperty.fontSize(theSize), important: isImportant))
        }
        
        if let theWeight = weight
        {
            result.append(GraphicStyle(key: "font-weight", value: StyleProperty.fontWeight(theWeight), important: isImportant))
        }
        if let theStyle = style
        {
            result.append(GraphicStyle(key: "font-style", value: StyleProperty.fontStyle(theStyle), important: isImportant))
        }
        if let theVariant = variant
        {
            result.append(GraphicStyle(key: "font-variant", value: StyleProperty.fontVariant(theVariant), important: isImportant))
        }
        
        if let theHeight = lineHeight
        {
            result.append(GraphicStyle(key: "line-height", value: StyleProperty.lineHeight(theHeight), important: isImportant))
        }
        
        if !families.isEmpty
        {
            result.append(GraphicStyle(key: "font-family", value: StyleProperty.fontFamilies(families)))
        }
        
        
        if let theStretch = stretch
        {
            result.append(GraphicStyle(key: "font-stretch", value: StyleProperty.fontStretch(theStretch), important: isImportant))
        }
        
        
        return (result, cursor)
        
    }
    
    fileprivate func extract(key: String,  fromBuffer buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> (Range<String.UnicodeScalarView.Index>, Bool, String.UnicodeScalarView.Index)
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
                break;
            }
            
            cursor = try buffer.uncommentedIndex(after: cursor)
        }
        if propertyRange == nil
        {
            propertyRange = valueRange.lowerBound..<valueRange.upperBound
        }
        if propertyRange?.isEmpty ?? true
        {
            throw StylePropertyFailureReason.incompleteProperty(key, valueRange.lowerBound)
        }
        return (propertyRange!, isImportant, cursor)
    }
    
    fileprivate func interpretColour(key: String, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
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
    
    fileprivate func interpretDimension(key: String, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
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
                let property = StyleProperty.unitNumber(actualValue, styleUnit)
                return ([GraphicStyle(key: key, value: property, important: isImportant)], cursor)
            }
            else
            {
                
                let property = StyleProperty.number(actualValue)
                return ([GraphicStyle(key: key, value: property, important: isImportant)], cursor)
                
            }
        }
        
        throw StylePropertyFailureReason.incompleteProperty(key, valueRange.lowerBound)
    }
    
    fileprivate func interpretFontSize(key: String, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
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
        throw StylePropertyFailureReason.incompleteProperty(key, valueRange.lowerBound)
    }
    
    fileprivate func interpretFontFamilies(key: String, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index)
    {
        let (families, cursor, isImportant) = try extractFontNames(buffer: buffer, valueRange: valueRange)
        
        return ([GraphicStyle(key: key, value: StyleProperty.fontFamilies(families), important: isImportant)], cursor)
        
    }
    
    public func interpret(key: String, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index) {

        switch key
        {
            case "font":
                return try self.interpretFontProperty(buffer: buffer, valueRange: valueRange)
            case "fill", "stroke":
                return try self.interpretColour(key: key, buffer: buffer, valueRange: valueRange)
            case "stroke-width":
                return try self.interpretDimension(key: key, buffer: buffer, valueRange: valueRange)
            case "font-family":
                return try self.interpretFontFamilies(key: key, buffer: buffer, valueRange: valueRange)
            case "font-size":
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
    override public func interpret(key: String, buffer: String.UnicodeScalarView, valueRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index) {
        
        switch key
        {
            default:
            return try super.interpret(key: key, buffer: buffer, valueRange: valueRange)
        }
        
        //return [GraphicStyle]()
    }
    
    
}
