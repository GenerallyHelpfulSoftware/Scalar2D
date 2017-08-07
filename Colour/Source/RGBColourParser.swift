//
//  RGBColourParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/10/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
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

public struct RGBColourParser : ColourParser
{
    static let decimalSymbols = CharacterSet(charactersIn: "0123456789.")
    static let notRGBParameterSymbols = CharacterSet(charactersIn: "0123456789.%").inverted
    
    private func retrieve(colourComponent component: String, isAlpha: Bool) throws -> ColourFloat
    {
        // obviously this method is going to be pretty forgiving of garbled input.
        var componentString = component.trimmingCharacters(in: RGBColourParser.notRGBParameterSymbols)
        guard !componentString.isEmpty else
        {
            throw ColourParsingError.incomplete(component)
        }
        var isPercent = false
        if componentString.hasSuffix("%")
        {
            isPercent = true
            componentString = componentString.substring(to: componentString.index(before: componentString.endIndex))
        }
        
        guard let result = Double(componentString) else
        {
            throw ColourParsingError.unexpectedCharacter(component)
        }
        
        if isAlpha
        {
            if isPercent
            {
                throw ColourParsingError.unexpectedCharacter(component)
            }
            else
            {
                guard result >= 0.0, result <= 1.0 else
                {
                    throw ColourParsingError.badRange(component)
                }
                return ColourFloat(result)
            }
        }
        else
        {
            if(isPercent)
            {
                guard result >= 0.0, result <= 100.0 else
                {
                    throw ColourParsingError.badRange(component)
                }
                return ColourFloat(result / 100.0)
            }
            else
            {
                guard result >= 0.0, result <= 255.0 else
                {
                    throw ColourParsingError.badRange(component)
                }
                return ColourFloat(result / 255.0)
            }
        }
    }
    
    
    public func deserializeString(source: String, colorContext: ColorContext? = nil) throws -> Colour?
    {
        guard source.hasPrefix("rgb") else
        {
            return nil
        }
        
        let isRGBA = source.hasPrefix("rgba")
        let prefix = isRGBA ? "rgba" : "rgb"
        let parameterCount = isRGBA ? 4 : 3
        

        let leftParenComponents = source.components(separatedBy: "(")
        guard leftParenComponents.count == 2 else
        {
            throw ColourParsingError.unexpectedCharacter(source)
        }
        
        guard leftParenComponents.first!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == prefix else
        { // something between the rgb prefix and the leading (
            throw ColourParsingError.unexpectedCharacter(source)
        }
        let rightSide = leftParenComponents.last!
        
        guard rightSide.hasSuffix(")") else
        {
            throw ColourParsingError.incomplete(source)
        }
        
        let rightParenComponents = rightSide.components(separatedBy: ")") // source is assumed to be trimmed so it should terminate on the )
        guard rightParenComponents.count == 2 && rightParenComponents.last!.isEmpty else
        {
            throw ColourParsingError.unexpectedCharacter(source)
        }
        let payload = rightParenComponents.first!
        
        let stringComponents = payload.components(separatedBy: ",")
        guard  stringComponents.count == parameterCount else
        {// need exactly parameterCount components r,g, b, a?
            throw ColourParsingError.incomplete(source)
        }
        
        let red = try self.retrieve(colourComponent: stringComponents[0], isAlpha: false)
        let green = try self.retrieve(colourComponent: stringComponents[1], isAlpha: false)
        let blue = try self.retrieve(colourComponent: stringComponents[2], isAlpha: false)
        
        var result = Colour.rgb(red: red, green: green, blue: blue, source: source)
        
        if(isRGBA)
        {
            let alpha = try self.retrieve(colourComponent: stringComponents[3], isAlpha: true)
            result = Colour.transparent(Colour: result, alpha: alpha)
        }
        return result
    }
    
    public init()
    {
        
    }
}

