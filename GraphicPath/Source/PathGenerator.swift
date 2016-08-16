//
//  PathGenerator.swift
//  Scalar2D
//
//  Created by Glenn Howes on 7/28/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//
//
// The MIT License (MIT)

//  Copyright (c) 2016 Glenn R. Howes

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

public extension String
{
    /**
     A function that converts a properly formatted string using the [SVG path specification](http://www.w3.org/TR/SVG/paths.html) to an array of PathTokens.
     - returns: An arry of PathToken
     - throws: a PathToken.FailureReason
     **/
    
    public func asPathTokens() throws -> [PathToken]
    {
        var cursorIndex = self.startIndex
        let endIndex = self.endIndex
        
        var parser = PathParser(pathString: self)
        
        while cursorIndex < endIndex
        {
            let aCharacter = self[cursorIndex]
            
            try parser.handleCharacter(character: aCharacter, atIndex: cursorIndex)
            
            cursorIndex = self.index(after: cursorIndex)
        }
        
        return try parser.complete()
        
    }
    
    
    private struct TokenBuilder
    {
        enum TokenBuildState
        {
            case lookingForParameter
            case insideParameter
            case complete
        }
        
        let pathString: String
        
        let operand: Character
        let numberOfParameters: Int
        var lookingForParameter: Bool
        var activeParameterStartIndex: String.CharacterView.Index
        var activeParameterStringLength: Int
        var seenPeriod: Bool
        var seenExponent: Bool
        var seenDigit: Bool
        var completedParameters: [Double]
        
         init(pathString: String, operand: Character)
        {
            self.pathString = pathString
            self.operand = operand
            self.numberOfParameters = PathToken.parametersPerOperand(operand: operand)
            self.activeParameterStringLength = 0
            self.activeParameterStartIndex = pathString.startIndex
            self.lookingForParameter = true
            self.seenPeriod = false
            self.seenExponent = false
            self.seenDigit = false
            self.completedParameters = [Double]()
            self.completedParameters.reserveCapacity(self.numberOfParameters)
        }
        
        private var activeParameterIndex: Int
        {
            return self.completedParameters.count
        }
        
        private var completed: Bool
        {
            return self.completedParameters.count == self.numberOfParameters
        }
        
        private var activeParameterString: String
        {
            let endIndex = self.pathString.index(self.activeParameterStartIndex, offsetBy: self.activeParameterStringLength)
            return self.pathString.substring(with: self.activeParameterStartIndex..<endIndex)
        }
        
        mutating private func completeActiveParameter() throws
        {
            let completedParameterString = self.activeParameterString
            
            if !self.seenDigit
            {
                throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: self.pathString.distance(from: self.pathString.startIndex, to: self.activeParameterStartIndex))
            }
            else if completedParameterString.hasSuffix("e") // exponent without value
            {
                throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: self.pathString.distance(from: self.pathString.startIndex, to: self.activeParameterStartIndex))
            }
            else if !self.seenExponent && !self.seenPeriod
            {
                if let intValue = Int(completedParameterString)
                {
                    self.completedParameters.append(Double(intValue))
                }
                else
                {
                    throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: self.pathString.distance(from: self.pathString.startIndex, to: self.activeParameterStartIndex))
                }
            }
            else
            {
                if let doubleValue = Double(completedParameterString)
                {
                    self.completedParameters.append(doubleValue)
                }
                else
                {
                    throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: self.pathString.distance(from: self.pathString.startIndex, to: self.activeParameterStartIndex))
                }
            }
            self.activeParameterStringLength = 0
            if !self.completed
            {
                self.seenPeriod = false
                self.seenExponent = false
                self.seenDigit = false
            }
        }
        
        private mutating func beginParameterAtIndex(index: String.CharacterView.Index)
        {
            self.activeParameterStartIndex = index
            self.activeParameterStringLength = 1
            self.lookingForParameter = false
        }
        
        mutating func testCompletionCharacter(character: Character, atIndex index: String.CharacterView.Index) throws -> TokenBuildState
        {
            if self.completed
            {
                print("Program Error should not be continuing to parse a completed token")
            }
            else if self.lookingForParameter
            {
                var foundNumber = false
                switch character
                {
                    case " ", "\t", "\n", "\r", ",":
                        break
                        
                    case ".":
                        foundNumber = true
                        self.seenPeriod = true
                    case "-", "+":
                        foundNumber = true
                        
                    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                        foundNumber = true
                        self.seenDigit = true
                        
                    default:
                        throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: self.pathString.distance(from: self.pathString.startIndex, to: index))
                }
                
                if foundNumber
                {
                    self.beginParameterAtIndex(index: index)
                }
            }
            else // inside a parameter
            {
                switch character
                {
                    case " ", "\t", "\n", "\r", ",":
                        try self.completeActiveParameter()
                        self.lookingForParameter = true
                    case ".":
                        if(self.seenExponent)
                        {
                            throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: self.pathString.distance(from: self.pathString.startIndex, to: index))
                        }
                        else if (self.seenPeriod)
                        {
                            if self.seenDigit
                            {
                                try self.completeActiveParameter()
                                
                                self.beginParameterAtIndex(index: index)
                                self.seenPeriod = true
                            }
                            else
                            {
                                throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: self.pathString.distance(from: self.pathString.startIndex, to: index))
                            }
                        }
                        else
                        {
                            self.seenPeriod = true
                            self.activeParameterStringLength += 1
                        }
                    case "e" where !self.seenExponent:
                        fallthrough
                    case "E" where !self.seenExponent:
                        self.seenExponent = true
                        self.activeParameterStringLength += 1
                        
                    case "-", "+":
                        let lastCharacter = self.lastCharacter
                        if lastCharacter == "e" || lastCharacter == "E"
                        {
                            self.activeParameterStringLength += 1
                        }
                        else if self.seenDigit
                        {
                            try self.completeActiveParameter()
                            
                            self.beginParameterAtIndex(index: index)
                        }
                        else
                        {
                            throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: self.pathString.distance(from: self.pathString.startIndex, to: index))
                        }
                    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                        self.seenDigit = true
                        self.activeParameterStringLength += 1
                    default:
                        throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: self.pathString.distance(from: self.pathString.startIndex, to: index))
                }
            }
            
            if self.completed
            {
                self.lookingForParameter = false
                return .complete
            }
            else if self.lookingForParameter
            {
                return .lookingForParameter
            }
            else
            {
                return .insideParameter
            }
        }
        
        private var lastCharacter : Character
        {
            let lastCharacterIndex = self.pathString.index(self.activeParameterStartIndex, offsetBy: self.activeParameterStringLength-1)
            return self.pathString[lastCharacterIndex]
        }
        
        private func isCompletionCharacter(testCharacter: Character) -> Bool
        {
            let onLastParameter = self.numberOfParameters == (self.activeParameterIndex+1)
                && self.activeParameterStringLength > 0
                && !self.lookingForParameter
            
            switch testCharacter
            {
                case "l", "L", "H", "h", "Q", "q", "V", "v", "C", "c", "T", "t", "S", "s", "A", "a", "m", "M",  "z", "Z":
                    return true
                case "+", "-":
                    
                    if onLastParameter
                        && self.lastCharacter != "e"
                        && self.lastCharacter != "E" // might be of the form 1e-3
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                case " ", "\t", "\n", "\r", ",":
                    if onLastParameter
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                case ".":
                    if onLastParameter && (self.seenPeriod || self.seenExponent)
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                    
                default:
                    return false
            }
            
        }
        
        mutating fileprivate func buildToken() throws -> PathToken
        {
            if self.activeParameterStringLength > 0
            {
                try self.completeActiveParameter()
            }
            
            if self.completed
            {
                return try PathToken(operand: self.operand, parameters: self.completedParameters, atOffset: self.pathString.distance(from: self.pathString.startIndex, to: self.activeParameterStartIndex))
            }
            else
            {
                throw PathToken.FailureReason.tooFewParameters(operand: self.operand, expectedParameterCount: self.numberOfParameters, actualParameterCount: self.activeParameterStringLength, offset: self.pathString.distance(from: self.pathString.startIndex, to: self.activeParameterStartIndex))
            }
        }
    }
    
    private struct PathParser
    {
        private enum ParseState
        {
            case lookingForFirstOperand
            case lookingForOperand
            case buildingToken
        }
        
        
        let pathString: String
        var resultTokens = [PathToken]()
        var parseState = ParseState.lookingForFirstOperand
        var tokenBuilder: TokenBuilder
        
        init(pathString: String)
        {
            self.pathString = pathString
            self.tokenBuilder = TokenBuilder(pathString: pathString, operand: "M")
        }
        
        mutating func handleCharacter(character: Character, atIndex index: String.CharacterView.Index) throws
        {
            switch parseState
            {
                case .lookingForFirstOperand:
                    switch character
                    {
                        case " ", "\t", "\n", "\r": // possible leading whitespace
                            break
                        case "m", "M":
                            self.parseState = .buildingToken
                        case "l", "L", "H", "h", "Q", "q", "V", "v", "C", "c", "T", "t", "S", "s", "A", "a":
                            throw PathToken.FailureReason.missingMoveAtStart
                        default:
                            throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: self.pathString.distance(from: self.pathString.startIndex, to: index))
                    }
                    
                case .lookingForOperand:
                    switch character
                    {
                        case " ", "\t", "\n", "\r", ",": // possible operand separators
                            break
                        case "z", "Z":
                            resultTokens.append(PathToken.close)
                        case "l", "L", "H", "h", "Q", "q", "V", "v", "C", "c", "T", "t", "S", "s", "A", "a", "m", "M":
                            self.tokenBuilder = TokenBuilder(pathString: pathString, operand: character)
                            parseState = .buildingToken
                        case "-", "+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".": // an implied
                            guard  let mostRecentToken = self.resultTokens.last else
                            {
                                throw PathToken.FailureReason.missingMoveAtStart
                            }
                            
                            guard mostRecentToken.impliesSubsequentOperand else
                            {
                                throw PathToken.FailureReason.missingMoveAtStart
                            }
                            
                            self.tokenBuilder = TokenBuilder(pathString: pathString, operand: mostRecentToken.impliedSubsequentOperand)
                            parseState = .buildingToken
                            let _ = try self.tokenBuilder.testCompletionCharacter(character: character, atIndex: index) // I know it's not completed
                            
                            
                        default:
                            let failureReason = PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: self.pathString.distance(from: self.pathString.startIndex, to: index))
                            resultTokens.append(PathToken.bad(character, failureReason))
                            throw failureReason
                    }
                    
                case .buildingToken:
                    
                    let isTokenEnder = self.tokenBuilder.isCompletionCharacter(testCharacter: character)
                    if(isTokenEnder) // a character appeared that forces a new operand token.
                    {
                        let newToken = try self.tokenBuilder.buildToken()
                        resultTokens.append(newToken)
                        
                        switch character
                        {
                            case "Z", "z":
                                resultTokens.append(PathToken.close)
                                parseState = .lookingForOperand
                            case "l", "L", "H", "h", "Q", "q", "V", "v", "C", "c", "T", "t", "S", "s", "A", "a", "m", "M":
                                self.tokenBuilder = TokenBuilder(pathString: pathString, operand: character)
                                parseState = .buildingToken
                            case " ", "\t", "\n", "\r", ",":
                                parseState = .lookingForOperand
                            default:
                                
                                guard newToken.impliesSubsequentOperand else
                                {
                                    throw PathToken.FailureReason.missingMoveAtStart
                                }
                                self.tokenBuilder = TokenBuilder(pathString: pathString, operand: newToken.impliedSubsequentOperand)
                                parseState = .buildingToken
                            }
                        
                    }
                    else
                    {
                        if case .complete =  try self.tokenBuilder.testCompletionCharacter(character: character, atIndex: index)
                        {
                            resultTokens.append(try self.tokenBuilder.buildToken())
                            self.parseState = .lookingForOperand
                        }
                    }
                
            }
        }
        
        mutating private func complete() throws -> [PathToken]
        {
            switch parseState
            {
                case .lookingForOperand:
                    break
                case .lookingForFirstOperand:
                    throw PathToken.FailureReason.noOperands
                case .buildingToken:
                    let lastToken = try self.tokenBuilder.buildToken()
                    self.resultTokens.append(lastToken)
            }
            return self.resultTokens
        }
    }
    

}


/**
    An enum encapsulating an individual path definition operation such as a line to, or a close path
**/
public enum PathToken : CustomStringConvertible
{
    /**
        In the SVG definition of an Arc, there are almost always 2 ways to get from the starting point to the specified ending point. One way is longer than the other, thus the choice.
     **/
    public enum ArcChoice : Int
    {
        case large = 1
        case short = 0
        
        var useLarge: Bool
        {
            switch self
            {
                case .large:
                    return true
                case .short:
                    return false
            }
        }
    }
    
    /**
     In the SVG definition of an Arc, there is always the choice to reach from the start point to the end point by going clockwise or counterclockwise. Thus the need for this flag.
     **/
    public enum ArcSweep : Int
    {
        case clockwise = 0
        case counterclockwise = 1
        
        var useClockwise : Bool
        {
            switch self
            {
                case .clockwise:
                    return true
                case .counterclockwise:
                    return false
            }
        }
    }
    /**
        If the parsing of a string fails, and it turns out to not be a valid SVG path string. These errors will be thrown.
     **/
    public enum FailureReason : CustomStringConvertible, Error
    {
        case none
        case missingMoveAtStart
        case unexpectedCharacter(badCharacter: Character, offset: Int)
        case tooFewParameters(operand: Character, expectedParameterCount: Int, actualParameterCount: Int, offset: Int)
        case badParameter(operand: Character, parameterIndex: Int, unexpectedValue: String, offset: Int)
        case noOperands
        
        public var description: String
        {
            switch self
            {
                case .none:
                    return "No Failure"
                case let .unexpectedCharacter(badCharacter, offset):
                    return "Unexpected character: \(badCharacter) at offset: \(offset)"
                case let .tooFewParameters(operand, expectedParameterCount, actualParameterCount, offset):
                    return "Operand '\(operand)' (\(PathToken.nameForOperand(operand: operand))) expects \(expectedParameterCount), but had \(actualParameterCount) at offset: \(offset)"
                case let .badParameter(operand, parameterIndex, unexpectedValue, offset):
                    
                    return "Operand '\(operand)' (\(PathToken.nameForOperand(operand: operand))) had a unexpected parameter '\(unexpectedValue)' for parameter \(parameterIndex) at offset: \(offset)"
                
                case .noOperands:
                    return "Just white space."
                case .missingMoveAtStart:
                    return "Missing move to at start."
            }
        }
    }
    
    case bad(Character, FailureReason)
    case close
    case moveTo(Double, Double)
    case moveToAbsolute(Double, Double)
    case lineTo(Double, Double)
    case lineToAbsolute(Double, Double)
    case horizontalLineTo(Double)
    case horizontalLineToAbsolute(Double)
    case verticalLineTo(Double)
    case verticalLineToAbsolute(Double)
    case cubicBezierTo(Double, Double, Double, Double, Double, Double)
    case cubicBezierToAbsolute(Double, Double, Double, Double, Double, Double)
    case smoothCubicBezierTo(Double, Double, Double, Double)
    case smoothCubicBezierToAbsolute(Double, Double, Double, Double)
    case quadraticBezierTo(Double, Double, Double, Double)
    case quadraticBezierToAbsolute(Double, Double, Double, Double)
    case smoothQuadraticBezierTo(Double, Double)
    case smoothQuadraticBezierToAbsolute(Double, Double)
    case arcTo(Double, Double, Double, ArcChoice, ArcSweep, Double, Double)
    case arcToAbsolute(Double, Double, Double, ArcChoice, ArcSweep, Double, Double)
    
    
    public  init(operand: Character, parameters: [Double], atOffset offset: Int) throws
    {
        switch operand
        {
            case "z", "Z":
                assert(parameters.count == 0, "close needs no parameters")
                self = .close
            case "m":
                assert(parameters.count == 2, "moveTo needs 2 parameters")
                self = .moveTo(parameters[0], parameters[1])
            case "M":
                assert(parameters.count == 2, "moveToAbsolute needs 2 parameters")
                self = .moveToAbsolute(parameters[0], parameters[1])
            case "l":
                assert(parameters.count == 2, "lineTo needs 2 parameters")
                self = .lineTo(parameters[0], parameters[1])
            case "L":
                assert(parameters.count == 2, "lineToAbsolute needs 2 parameters")
                self = .lineToAbsolute(parameters[0], parameters[1])
            case "h":
                assert(parameters.count == 1, "horizontalLineTo needs 1 parameter")
                self = .horizontalLineTo(parameters[0])
            case "H":
                assert(parameters.count == 1, "horizontalLineToAbsolute needs 1 parameter")
                self = .horizontalLineToAbsolute(parameters[0])
            case "v":
                assert(parameters.count == 1, "verticalLineTo needs 1 parameter")
                self = .verticalLineTo(parameters[0])
            case "V":
                assert(parameters.count == 1, "verticalLineToAbsolute needs 1 parameter")
                self = .verticalLineToAbsolute(parameters[0])
            case "q":
                assert(parameters.count == 4, "quadraticBezierTo needs 4 parameters")
                self = .quadraticBezierTo(parameters[0], parameters[1], parameters[2], parameters[3])
            case "Q":
                assert(parameters.count == 4, "quadraticBezierToAbsolute needs 4 parameters")
                self = .quadraticBezierToAbsolute(parameters[0], parameters[1], parameters[2], parameters[3])
            case "c":
                assert(parameters.count == 6, "cubicBezierTo needs 6 parameters")
                self = .cubicBezierTo(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5])
            case "C":
                assert(parameters.count == 6, "cubicBezierToAbsolute needs 6 parameters")
                self = .cubicBezierToAbsolute(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5])
            case "t":
                assert(parameters.count == 2, "smoothQuadraticBezierTo needs 2 parameters")
                self = .smoothQuadraticBezierTo(parameters[0], parameters[1])
            case "T":
                assert(parameters.count == 2, "smoothQuadraticBezierToAbsolute needs 2 parameters")
                self = .smoothQuadraticBezierToAbsolute(parameters[0], parameters[1])
            case "s":
                assert(parameters.count == 4, "smoothCubicBezierTo needs 4 parameters")
                self = .smoothCubicBezierTo(parameters[0], parameters[1], parameters[2], parameters[3])
            case "S":
                assert(parameters.count == 4, "smoothCubicBezierToAbsolute needs 4 parameters")
                self = .smoothCubicBezierToAbsolute(parameters[0], parameters[1], parameters[2], parameters[3])
            case "a", "A":
                assert(parameters.count == 7, "arcTo needs 7 parameters")
                let arcChoiceRaw = parameters[3]
                let arcSweepRaw = parameters[4]
                
                guard arcChoiceRaw == 1 || arcChoiceRaw == 0 else
                {
                    throw PathToken.FailureReason.badParameter(operand: operand, parameterIndex: 3, unexpectedValue: String(arcChoiceRaw), offset: offset)
                }
                
                guard arcSweepRaw == 1 || arcSweepRaw == 0 else
                {
                    throw PathToken.FailureReason.badParameter(operand: operand, parameterIndex: 4, unexpectedValue: String(arcSweepRaw), offset: offset)
                }
                
                let archChoice = ArcChoice(rawValue: Int(arcChoiceRaw))
                let arcSweep = ArcSweep(rawValue: Int(arcSweepRaw))
                if operand == "a"
                {
                    self = .arcTo(parameters[0], parameters[1], parameters[2], archChoice!, arcSweep!, parameters[5], parameters[6])
                }
                else
                {
                    self = .arcToAbsolute(parameters[0], parameters[1], parameters[2], archChoice!, arcSweep!, parameters[5], parameters[6])
                }
            default:
                throw PathToken.FailureReason.unexpectedCharacter(badCharacter: operand, offset: offset)
        }
    }
    
    public var operand: Character
    {
        get
        {
            switch self
            {
                case .bad(let badOperand, _ ):
                    return badOperand
                case .close:
                    return "z"
                case .moveTo(_, _):
                    return "m"
                case .moveToAbsolute(_, _):
                    return "M"
                case .lineTo(_, _):
                    return "l"
                case .lineToAbsolute(_, _):
                    return "L"
                case .horizontalLineTo(_):
                    return "h"
                case .horizontalLineToAbsolute(_):
                    return "H"
                case .verticalLineTo(_):
                    return "v"
                case .verticalLineToAbsolute(_):
                    return "V"
                case .cubicBezierTo(_, _, _, _, _, _):
                    return "c"
                case .cubicBezierToAbsolute(_, _, _, _, _, _):
                    return "C"
                case .quadraticBezierTo(_, _, _, _):
                    return "q"
                case .quadraticBezierToAbsolute(_, _, _, _):
                    return "Q"
                case .smoothCubicBezierTo(_, _, _, _):
                    return "s"
                case .smoothCubicBezierToAbsolute(_, _, _, _):
                    return "S"
                case .smoothQuadraticBezierTo(_, _):
                    return "t"
                case .smoothQuadraticBezierToAbsolute(_, _):
                    return "T"
                case .arcTo(_, _, _, _, _, _, _):
                    return "a"
                case .arcToAbsolute(_, _, _, _, _, _, _):
                    return "A"
            }
        }
    }
    
    fileprivate var impliesSubsequentOperand: Bool
    {
        switch self
        {
            case .close:
                return false //I don't believe that a z implies a subsequent M
            default:
                return true // M implies L, m implies l, otherwise operand implies the same operand
        }
    }
    
    fileprivate var impliedSubsequentOperand: Character
    {
        switch self
        {
            case .moveTo(_, _):
                return "l"
            case .moveToAbsolute(_, _):
                return "L"
            default:
                return self.operand
        }
    }
    
    public var description: String
    {
        let name = PathToken.nameForOperand(operand: self.operand)
        switch self
        {
            case let .bad(badOperand, failureReason):
                return "unknown operand \(badOperand), reason: \(failureReason.description)"
            case .close:
                return name
            case let .moveTo(x, y):
                return "\(name) ∆x: \(x), ∆y: \(y)"
            case let .moveToAbsolute(x, y):
                return "\(name) x: \(x), y: \(y)"
            case let .lineTo(x, y):
                return "\(name) ∆x: \(x), ∆y: \(y)"
            case let .lineToAbsolute(x, y):
                return "\(name) x: \(x), y: \(y)"
            case .horizontalLineTo(let x):
                return "\(name) ∆x: \(x)"
            case .horizontalLineToAbsolute(let x):
                return "\(name) x: \(x)"
            case .verticalLineTo(let y):
                return "\(name) ∆y: \(y)"
            case .verticalLineToAbsolute(let y):
                return "\(name) y: \(y)"
            case let .cubicBezierTo(x₁, y₁, x₂, y₂, x, y):
                return "\(name) ∆x₁: \(x₁), ∆y₁: \(y₁), ∆x₂: \(x₂), ∆y₂: \(y₂), ∆x: \(x), ∆y: \(y)"
            case let .cubicBezierToAbsolute(x₁, y₁, x₂, y₂, x, y):
                return "\(name) x₁: \(x₁), y₁: \(y₁), x₂: \(x₂), y₂: \(y₂), x: \(x), y: \(y)"
            case let .quadraticBezierTo(x₁, y₁, x, y):
                return "\(name) ∆x₁: \(x₁), ∆y₁: \(y₁), ∆x: \(x), ∆y: \(y)"
            case let .quadraticBezierToAbsolute(x₁, y₁, x, y):
                return "\(name) x₁: \(x₁), y₁: \(y₁), x: \(x), y: \(y)"
            case let .smoothCubicBezierTo(x₂, y₂, x, y):
                return "\(name) ∆x₂: \(x₂), ∆y₂: \(y₂), ∆x: \(x), ∆y: \(y)"
            case let .smoothCubicBezierToAbsolute(x₂, y₂, x, y):
                return "\(name) x₂: \(x₂), y₂: \(y₂), x: \(x), y: \(y)"
            case let .smoothQuadraticBezierTo(x, y):
                return "\(name) ∆x: \(x), ∆y: \(y)"
            case let .smoothQuadraticBezierToAbsolute(x, y):
                return "\(name) x: \(x), y: \(y)"
            case let .arcTo(xRadius, yRadius, tiltAngle, largeArcFlag, sweepFlag, x, y):
                let largeArcString = (largeArcFlag.useLarge) ? "true" : "false"
                let sweepString = (sweepFlag.useClockwise) ? "true" : "false"
                return "\(name) r_x: \(xRadius), r_y: \(yRadius), Θ: \(tiltAngle)°‚ large Arc: \(largeArcString), clockwise: \(sweepString), ∆x: \(x), ∆y: \(y)"
            case let .arcToAbsolute(xRadius, yRadius, tiltAngle, largeArcFlag, sweepFlag, x, y):
                let largeArcString = (largeArcFlag.useLarge) ? "true" : "false"
                let sweepString = (sweepFlag.useClockwise) ? "true" : "false"
                return "\(name) r_x: \(xRadius), r_y: \(yRadius), Θ: \(tiltAngle)°‚ large Arc: \(largeArcString), clockwise: \(sweepString), x: \(x), y: \(y)"
        }
    }
    
    fileprivate static func isValidOperand(operand : Character) -> Bool
    {
        switch String(operand).lowercased()
        {
            case "z", "m",  "l",  "h",  "v",  "q",  "c",  "s",  "t",  "a":
                return true
            default:
                return false
        }
    }
    
    fileprivate static func parametersPerOperand(operand : Character) -> Int
    {
        switch String(operand).lowercased()
        {
            case "z":
                return 0
            case "m":
                return 2
            case "l":
                return 2
            case "h":
                return 1
            case "v":
                return 1
            case "q":
                return 4
            case "c":
                return 6
            case "s":
                return 4
            case "t":
                return 2
            case "a":
                return 7
            default:
                return 0
        }
    }

    fileprivate static func nameForOperand(operand : Character) -> String
    {
        var baseName : String
        let operandAsString = String(operand)
        let lowercaseOperandString = operandAsString.lowercased()
        switch lowercaseOperandString
        {
            case "z":
                return "close path"
            case "m":
                baseName = "move"
            case "l":
                baseName =  "lineto"
            case "h":
                baseName = "horizontal lineto"
            case "v":
                baseName = "vertical lineto"
            case "q":
                baseName = "quadratic Bezier"
            case "c":
                baseName = "cubic Bezier"
            case "s":
                baseName = "smooth cubic Bezier"
            case "t":
                baseName = "smooth quadratic Bezier"
            case "a":
                baseName = "arc"
            default:
                return "unknown"
        }
        
        if lowercaseOperandString != operandAsString
        {
            return "absolute \(baseName)"
        }
        else
        {
            return "relative \(baseName)"
        }
    }
}
