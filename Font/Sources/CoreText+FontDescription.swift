//
//  CoreText+FontDescription.swift
//  Scalar2D
//
//  Created by Glenn Howes on 9/8/17.
//  Copyright © 2017-2019 Generally Helpful Software. All rights reserved.
//
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
import CoreText


fileprivate let gSystemFontProperties : [AnyHashable : Any] = {return createSystemFontProperties()}()
fileprivate let gFontMappings = {return ["Arial" : "ArialMT", "Times New Roman" : "TimesNewRomanPSMT", "Times" : "TimesNewRomanPSMT", "Courier New" : "CourierNewPSMT", "Palatino": "Palatino-Roman"]}()
fileprivate let fontAttributesCache : NSCache<AnyObject, AnyObject> = {
    let result =  NSCache<AnyObject, AnyObject>()
    result.name = "com.genhelp.scalard2d.fontcache"
    return result
    
}()

public protocol FontContext
{
    var initial : Dictionary<AnyHashable, Any> {get}
    var inherited : Dictionary<AnyHashable, Any> {get}
    
    var defaultFontSize : CGFloat {get}
    var baseFontSize : CGFloat {get}
}

public protocol CoreTextProperty : InheritableProperty
{
    func merge(properties: inout Dictionary<AnyHashable, Any>, withContext context: FontContext)
}

extension FontWeight : CoreTextProperty
{
    public func merge(properties: inout Dictionary<AnyHashable, Any>, withContext context: FontContext)
    {
        var existingTraits : [AnyHashable : Any] = (properties[kCTFontTraitsAttribute] as? [AnyHashable:Any]) ?? [AnyHashable:Any]()
        var explicitWeight = (existingTraits[kCTFontWeightTrait] as? NSNumber)?.intValue
        let fontTraitMaskRaw : UInt32 = UInt32((properties[kCTFontSymbolicTrait] as? Int) ?? 0)
        var symbolicTraits = CTFontSymbolicTraits(rawValue: fontTraitMaskRaw)
        switch self
        {
            case .bold:
                symbolicTraits.formUnion(.boldTrait)
                explicitWeight = nil
            case .lighter, .bolder, .custom(_):
                let startWeight = (explicitWeight ?? (symbolicTraits.contains(.boldTrait) ? 700 : 400))
                explicitWeight =  self.equivalentWeight(forStartWeight: startWeight)
                if explicitWeight == FontWeight.boldWeight
                {
                    explicitWeight = nil
                    symbolicTraits.formUnion(.boldTrait)
                }
                else if explicitWeight == FontWeight.normalWeight
                {
                    explicitWeight = nil
                    symbolicTraits.remove(.boldTrait)
                }
            case .normal:
                explicitWeight = nil
                symbolicTraits.remove(.boldTrait)
            case .inherit:
            return
            case .initial:
                explicitWeight = nil
        }
        if let weightToSet = explicitWeight
        {
            existingTraits[kCTFontWeightTrait] = weightToSet
            properties[kCTFontTraitsAttribute] = existingTraits
            symbolicTraits.remove(.boldTrait)
        }
        else
        {
            existingTraits.removeValue(forKey: kCTFontWeightTrait)
            if existingTraits.isEmpty
            {
                properties.removeValue(forKey: kCTFontTraitsAttribute)
            }
            else
            {
                properties[kCTFontTraitsAttribute] = existingTraits
            }
        }
        
        if symbolicTraits.rawValue == 0
        {
            properties.removeValue(forKey: kCTFontSymbolicTrait)
        }
        else
        {
            properties[kCTFontSymbolicTrait] = NSNumber(value: symbolicTraits.rawValue)
        }
    }
}


public extension FontFamily
{
    var stylisticTraits : CTFontStylisticClass
    {
        switch self
        {
            case .cursive:
                return .scriptsClass
            case .fantasy:
                return .ornamentalsClass
            case .serif:
                return .modernSerifsClass
            case .sansSerif:
                return .sansSerifClass
            default:
                return CTFontStylisticClass(rawValue: 0)
        }
    }
    
    var symbolicTraits : CTFontSymbolicTraits
    {
        switch self {
        case .monospace:
            return .traitMonoSpace
        default:
            return CTFontSymbolicTraits(rawValue: 0)
        }
    }
}

extension TextDecoration : CoreTextProperty
{
    public func merge(properties: inout Dictionary<AnyHashable, Any>, withContext context: FontContext)
    {
        switch self
        {
            case .noDecoration, .initial:
                properties.removeValue(forKey: NSAttributedString.Key.underlineStyle)
            case .inherit:
                return
            case .underline:
                properties[NSAttributedString.Key.underlineStyle] = NSNumber(value: 1)
            case .lineThrough:
                properties[NSAttributedString.Key.strikethroughStyle] = NSNumber(value: 1)
            case .overline: // don't know how to render this
                break
        }
    }
}

extension FontVariant
{
    public func add(toDescriptor descriptor: CTFontDescriptor, withContext context: FontContext ) ->  CTFontDescriptor
    {
        var result = descriptor
        switch self
        {
            case .smallCaps:
                result = CTFontDescriptorCreateCopyWithFeature(result, 3 as CFNumber, 3 as CFNumber)
            default:
            break
        }
        return result
    }
}

extension FontStretch : CoreTextProperty
{
    public func merge(properties: inout Dictionary<AnyHashable, Any>, withContext context: FontContext) {
        switch self
        {
            case .normal, .initial:
                properties.removeValue(forKey: kCTFontWidthTrait)
            case .inherit:
                return
            default:
            guard let width = self.normalizedWidth else
            {
                properties.removeValue(forKey: kCTFontWidthTrait)
                return
            }
            properties[kCTFontWidthTrait] = NSNumber(value: width)
        }
    }
    
    var normalizedWidth : Double?
    {
        switch self
        {
            case .condensed:
                return -0.5
            case .expanded:
                return 0.5
            case .extraCondensed:
                return -0.75
            case .extraExpanded:
                return 0.75
            case .semiCondensed:
                return -0.25
            case .semiExpanded:
                return 0.25
            case .ultraExpanded:
                return 1.0
            case .ultraCondensed:
                return -1.0
            default:
                return nil
        }
    }
}

public extension FontContext
{
    var initial : Dictionary<AnyHashable, Any>
    {
        return Dictionary<AnyHashable, Any>()
    }
    
    var inherited : Dictionary<AnyHashable, Any>
    {
        return self.initial
    }
    
    var defaultFont : CTFont
    {
        guard let result = CTFontCreateUIFontForLanguage(.user, 0.0, nil) else
        {
            return CTFontCreateWithName("Helvetica" as CFString, 14.0, nil)
        }
        return result
    }
    
    var defaultFontSize : CGFloat
    {
        let defaultFontRef = self.defaultFont
        return CTFontGetSize(defaultFontRef)
    }
    
    var defaultAttributes : [AnyHashable : Any]
    {
        let fontDescriptor = CTFontCopyFontDescriptor(self.defaultFont)
        return CTFontDescriptorCopyAttributes(fontDescriptor) as! [AnyHashable : Any]
    }
    
    var baseFontSize : CGFloat
    {
        return defaultFontSize
    }
    
    func fontSize(fromFontSize fontSize: FontSize) -> CGFloat
    {
        let standardScaling: CGFloat = 1.2
        switch fontSize
        {
            case .inherit, .initial, .medium:
            return baseFontSize
            case .small:
                return defaultFontSize / standardScaling
            case .large:
                return defaultFontSize * standardScaling
            case .xSmall:
                return defaultFontSize / (standardScaling*standardScaling)
            case .xLarge:
                return defaultFontSize * standardScaling * standardScaling
            case .xxSmall:
                return defaultFontSize / (standardScaling*standardScaling*standardScaling)
            case .xxLarge:
                return defaultFontSize * standardScaling * standardScaling * standardScaling
            case .larger:
                return baseFontSize * standardScaling
            case .smaller:
                return baseFontSize / standardScaling
            case .pixel(let value):
                return CGFloat(value) // have to re-examine this later with a mechanism to get the pixel height
            case .point(let value):
                return CGFloat(value)
            case .percentage(let percent):
                return baseFontSize * CGFloat(percent / 100.0)
            case .em(let scaling):
                return baseFontSize * CGFloat(scaling)
            case .rem(let scaling):
                return defaultFontSize * CGFloat(scaling)
            case .dynamic:
                return baseFontSize // TODO support dynamic sizing
            case .ch(_):
                return baseFontSize // TODO support ch sizing
            case .ex(_):
                return baseFontSize // TODO support ex sizing
            case .viewPortH(_), .viewPortW(_):
                return baseFontSize // TODO support viewport based sizing
        }
    }
    
    private static func map(fontName: String) -> String
    {
        guard let mappedName = gFontMappings[fontName] else
        {
            return fontName
        }
        return mappedName
    }
    
    private static func createFontAttributes(forName name: String) -> [AnyHashable : Any]?
    {
        let testFont = CTFontCreateWithName(name as CFString, 0.0, nil)
        let descriptor = CTFontCopyFontDescriptor(testFont)
        var fontAttributes = CTFontDescriptorCopyAttributes(descriptor) as! [AnyHashable : Any]
        if !fontAttributes.isEmpty
        {
            fontAttributes.removeValue(forKey: kCTFontSizeAttribute)
            return fontAttributes
        }
        
        return nil
    }
    
    
    private static func fontAttributes(forName name: String) -> [AnyHashable : Any]?
    {
        let realName = self.map(fontName: name)
        if realName.isEmpty
        {
            return nil
        }
        
        if let savedProperties = fontAttributesCache.object(forKey: realName as NSString)
        {
            if savedProperties is NSNull
            {
                return nil
            }
            else if let result = savedProperties as? [AnyHashable : Any]
            {
                return result
            }
        }
        else
        {
            if let createdProperties = createFontAttributes(forName: realName)
            {
                fontAttributesCache.setObject(createdProperties as AnyObject, forKey: realName as NSString, cost: 100)
                return createdProperties
            }
            else
            {
                fontAttributesCache.setObject(NSNull(), forKey: realName as NSString, cost: 100)
            }
        }
    
        return nil
    }
    
    func fontFamilyProperties(from fontDescriptor: FontDescription) -> [AnyHashable : Any]
    {
        let fontFamilies = fontDescriptor.families
        if fontFamilies.isEmpty
        {
            return self.defaultAttributes
        }
        else
        {
            var result = self.defaultAttributes
            var looped = false
            var fallbacks : [[AnyHashable : Any]]?
            fontFamilies.forEach
            {
                aFamily in
                var symbolicTraits: CTFontSymbolicTraits? = nil
                var stylisticTraits: CTFontStylisticClass? = nil
                if looped
                {
                    fallbacks = [[AnyHashable : Any]]()
                }
                looped = true
                switch aFamily
                {
                    case .system:
                        if fallbacks != nil
                        {
                            fallbacks!.append(gSystemFontProperties)
                        }
                        else
                        {
                            result = gSystemFontProperties
                        }
                        return
                    case .cursive:
                        stylisticTraits = .scriptsClass
                    case .fantasy:
                        stylisticTraits = .ornamentalsClass
                    case .monospace:
                        symbolicTraits = .monoSpaceTrait
                    case .sansSerif:
                        stylisticTraits = .sansSerifClass
                    case .serif:
                        stylisticTraits = .classModernSerifs
                    case .named(let name):
                        if let attributes = Self.fontAttributes(forName: name)
                        {
                            if fallbacks != nil
                            {
                                fallbacks!.append(attributes)
                            }
                            else
                            {
                                result = attributes
                            }
                            return
                        }
                    case .initial:
                        break
                    case .inherit:
                        break
                }
                
                let rawTraits = (symbolicTraits?.rawValue ?? 0) + (stylisticTraits?.rawValue ?? 0)
                if rawTraits != 0
                {
                    let symbolRecord = [kCTFontSymbolicTrait : rawTraits]
                    if fallbacks != nil
                    {
                        fallbacks!.append([kCTFontTraitsAttribute : symbolRecord])
                    }
                    else
                    {
                        result[kCTFontTraitsAttribute] = symbolRecord
                    }
                }
            }
            if (fallbacks?.count ?? 0) > 0
            {
                result[kCTFontCascadeListAttribute] = fallbacks
            }
            return result
        }
    }
    
    var baseFontAttributes : [AnyHashable : Any]
    {
        return [AnyHashable : Any]()
    }
}

public class DefaultFontContext : FontContext
{
    public static var shared : DefaultFontContext =
    {
       return DefaultFontContext()
    }()
}

public extension FontDescription
{
    var symbolicTraits : CTFontSymbolicTraits
    {
        var result = CTFontSymbolicTraits(rawValue: 0)
        switch self.weight
        {
            case .bold:
                result = .boldTrait
            default:
            break
        }
        
        switch self.stretch
        {
            case .condensed:
                result.insert(.condensedTrait)
            case .expanded:
                result.insert(.expandedTrait)
            default:
                break
        }
        
        return result
    }
    
    var ctDescriptor : CTFontDescriptor
    {
        return self.coreTextDescriptor()
    }
    
    private func mergeParagraphStyles(properties: inout Dictionary<AnyHashable, Any>, withContext context: FontContext)
    {
//        let existingParagraphStyles = properties[kCTParagraphStyleAttributeName] as? [CTParagraphStyleSetting] ?? [CTParagraphStyleSetting]()
        
    }
    
    func coreTextDescriptor(context: FontContext = DefaultFontContext.shared) -> CTFontDescriptor
    {
        var record = context.baseFontAttributes
        
        let familyProperties = context.fontFamilyProperties(from: self)
        record = record.merging(familyProperties, uniquingKeysWith:{(_, new) in new})
        self.weight.merge(properties: &record, withContext: context)
        self.stretch.merge(properties: &record, withContext: context)
        self.decorations.forEach{$0.merge(properties:&record, withContext: context)}
        
        record[kCTFontSizeAttribute as String] = context.fontSize(fromFontSize: self.size)
        
        let keySet = Set(record.keys)
        
        var coreTextDescriptor = CTFontDescriptorCreateWithAttributes(record as CFDictionary)
        if let missSizedResult = CTFontDescriptorCreateMatchingFontDescriptor(coreTextDescriptor, keySet as CFSet)
        {
            coreTextDescriptor = CTFontDescriptorCreateCopyWithAttributes(missSizedResult, record as CFDictionary)
            
        }
        let coreTextDescriptorWithVariant = self.variant.add(toDescriptor: coreTextDescriptor, withContext: context)
        
        return coreTextDescriptorWithVariant
    }
}

fileprivate func createSystemFontProperties() -> [AnyHashable : Any]
{
    let defaultFontRef = CTFontCreateUIFontForLanguage(CTFontUIFontType.system, 0.0, nil)!
    let postscriptNameCF = CTFontCopyPostScriptName(defaultFontRef)
    let fontTraits = CTFontCopyTraits(defaultFontRef)
    var mutableResult = fontTraits as! [String : Any]
    mutableResult[kCTFontNameAttribute as String] = postscriptNameCF
    return mutableResult
    
}
