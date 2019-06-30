//
//  DeviceColourParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/12/16.
//  Copyright © 2016-2019 Generally Helpful Software. All rights reserved.
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

struct DeviceColourParser
{
    let prefix: String
    let componentCount: Int
    static let notRGBParameterSymbols = CharacterSet(charactersIn: "0123456789.").inverted

    private static func retrieve(colourComponent component: String) throws -> ColourFloat
    {
        // obviously this method is going to be pretty forgiving of garbled input.
        let componentString = component.trimmingCharacters(in: DeviceColourParser.notRGBParameterSymbols)
        guard !componentString.isEmpty else
        {
            throw ColourParsingError.incomplete(component)
        }
        
        guard let result = Double(componentString) else
        {
            throw ColourParsingError.unexpectedCharacter(component)
        }
        
        return ColourFloat(result)
        
    }


    public func deserializeString(source: String, colorContext: ColorContext? = nil) throws -> [ColourFloat]?
    {
        guard source.hasPrefix(self.prefix) else
        {
            return nil
        }
        
        
        let leftParenComponents = source.components(separatedBy: "(")
        guard leftParenComponents.count == 2 else
        {
            throw ColourParsingError.unexpectedCharacter(source)
        }
        
        guard leftParenComponents.first!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == self.prefix else
        { // something between the device-rgb prefix and the leading (
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
        guard  stringComponents.count == componentCount else
        {// need exactly componentCount components
            throw ColourParsingError.incomplete(source)
        }
        
        let result = try stringComponents.map{return try DeviceColourParser.retrieve(colourComponent: $0)}
        
        return result
        
    }
}
