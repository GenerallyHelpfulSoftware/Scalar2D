//
//  CoreText+FontDescription.swift
//  Scalar2D
//
//  Created by Glenn Howes on 9/8/17.
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
import CoreText



public protocol FontContext
{
    var initial : Dictionary<AnyHashable, Any> {get}
    var inherited : Dictionary<AnyHashable, Any> {get}
    
    var defaultFontSize : CGFloat {get}
    var baseFontSize : CGFloat {get}
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
    
    var defaultFontSize : CGFloat
    {
        guard let defaultFontRef = CTFontCreateUIFontForLanguage(.user, 0.0, nil) else
        {
            return 14.0
        }
        return CTFontGetSize(defaultFontRef)
    }
    
    var baseFontSize : CGFloat
    {
        return defaultFontSize
    }
    
    public func fontSize(fromFontSize fontSize: FontSize) ->CGFloat
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
//    public var ctDescriptor : CTFontDescriptor
//    {
//        return self.coreTextDescriptor()
//    }
//    
//    public func coreTextDescriptor(context: FontContext = DefaultFontContext.shared) -> CTFontDescriptor
//    {
//        var record =
//    }
}
