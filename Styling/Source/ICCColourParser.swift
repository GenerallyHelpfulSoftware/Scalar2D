//
//  ICCColourParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/12/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import Foundation

public struct ICCColourParser : ColourParser
{
    public func deserializeString(source: String, colorContext: ColorContext?) throws -> Colour?
    {
        guard source.hasPrefix("icc-color") else
        {
            return nil
        }
        
        let leftParenComponents = source.components(separatedBy: "(")
        guard leftParenComponents.count == 2 else
        {
            throw ColourParsingError.unexpectedCharacter(source)
        }
        
        guard leftParenComponents.first!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "icc-color" else
        { // something between the icc-color prefix and the leading (
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
        
        var stringComponents = payload.components(separatedBy: ",")
        guard  stringComponents.count >= 2 else
        {// need at least a name and and at least 1 colour component
            throw ColourParsingError.incomplete(source)
        }
        
        let profileName = stringComponents.removeFirst().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let doubleComponents = stringComponents.map{Double($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))}
        let noNullDoubleComponents = doubleComponents.flatMap{$0}
        
        guard noNullDoubleComponents.count == doubleComponents.count else
        {
            // one of the components was not convertable to a Double, so bad format
            throw ColourParsingError.unexpectedCharacter(source)
        }
        
        let colourFloatComponents = noNullDoubleComponents.map{ColourFloat($0)}
        return Colour.icc(profileName: profileName, components: colourFloatComponents, source: source)
        
    }
    
    public init()
    {
        
    }
}
