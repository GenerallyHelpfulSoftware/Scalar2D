//
//  PathGenerator.swift
//  Scalar2D
//
//  Created by Glenn Howes on 7/28/16.
//  Copyright © 2016-2019 Generally Helpful Software. All rights reserved.
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

public extension String
{
    /**
     A function that converts a properly formatted string using the [SVG path specification](http://www.w3.org/TR/SVG/paths.html) to an array of PathTokens.
     - returns: An array of PathToken
     - throws: a PathToken.FailureReason
     **/
    
    func asPathTokens() throws -> [PathToken]
    {
        var parser = PathParser()
        return try parser.parse(pathString: self)
        
    }
    /**
        SVG path strings (the "d" parameter of a <path> element) are faily complicated because they use various tricks for compactness. Thus parameters and operands can be separated by nothing(operand immediately followed by the start of its first parameter), commas, +, -, white space, and even a period if the preceding parameter already has a period. Also, operands can be implied to be the same as the previous operand, unless it was a move, in which case the implied operand is a line, or a close path in which case the use of an implied operand is an error. 
     
        The token builder builds up an individual token (an operand + its parameters)
    **/
    
    private struct TokenBuilder
    {
        enum TokenBuildState
        {
            case lookingForParameter
            case insideParameter
            case complete
        }
    
        let operand: UnicodeScalar
        let numberOfParameters: Int
        var lookingForParameter: Bool
        var activeParameterStartIndex: String.UnicodeScalarView.Index
        let buffer: String.UnicodeScalarView
        var activeParameterEndIndex: String.UnicodeScalarView.Index?
        var seenPeriod: Bool
        var seenExponent: Bool
        var seenDigit: Bool
        var completedParameters: [PathToken.PathParameter]
        
        init(buffer: String.UnicodeScalarView, startIndex: String.UnicodeScalarView.Index, operand: UnicodeScalar, firstCharacter : UnicodeScalar? = nil)
        {
            self.buffer = buffer
            self.operand = operand
            self.numberOfParameters = PathToken.parametersPerOperand(operand: operand)
            self.activeParameterStartIndex = startIndex
            self.activeParameterEndIndex = nil
            self.seenPeriod = false
            self.seenDigit = false
            self.lookingForParameter = true
            
            
            self.seenExponent = false
            self.completedParameters = Array<PathToken.PathParameter>()
            self.completedParameters.reserveCapacity(self.numberOfParameters)
            
            if let startCharacter = firstCharacter
            {
                switch startCharacter
                {
                    case ".":
                        self.seenPeriod = true
                    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                        self.seenDigit = true
                    default:
                        break
                }
                self.beginParameterAtIndex(index: startIndex)
            }
            
        }
        
        private var activeParameterIndex: Int
        {
            return self.completedParameters.count
        }
        
        private var completed: Bool
        {
            return self.completedParameters.count == self.numberOfParameters
        }
        
        private var activeParameterString: String?
        {
            guard let endIndex = self.activeParameterEndIndex else
            {
                return nil
            }
            let range = self.activeParameterStartIndex...endIndex
            return String(self.buffer[range])
        }
        
        mutating private func completeActiveParameter() throws
        {
            guard let completedParameterString = self.activeParameterString, let endIndex = self.activeParameterEndIndex else
            {
                throw PathToken.FailureReason.tooFewParameters(operand: self.operand, expectedParameterCount: self.numberOfParameters, actualParameterCount: self.completedParameters.count, offset: self.activeParameterStartIndex)
            }
            
            if !self.seenDigit
            {
                throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: endIndex)
            }
            else if completedParameterString.hasSuffix("e") // exponent without value
            {
                throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: endIndex)
            }
            else if !self.seenExponent && !self.seenPeriod
            {
                if let intValue = Int(completedParameterString)
                {
                    self.completedParameters.append(PathToken.PathParameter(intValue))
                }
                else
                {
                    throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: endIndex)
                }
            }
            else
            {
                if let doubleValue = Double(completedParameterString)
                {
                    self.completedParameters.append(PathToken.PathParameter(doubleValue))
                }
                else
                {
                    throw PathToken.FailureReason.badParameter(operand: self.operand, parameterIndex: self.activeParameterIndex, unexpectedValue: completedParameterString, offset: endIndex)
                }
            }
            self.activeParameterEndIndex = nil
            if !self.completed
            {
                self.seenPeriod = false
                self.seenExponent = false
                self.seenDigit = false
            }
        }
        
        private mutating func beginParameterAtIndex(index: String.UnicodeScalarView.Index)
        {
            self.activeParameterStartIndex = index
            self.activeParameterEndIndex = index
            self.lookingForParameter = false
        }
        
        mutating func testCompletionCharacter(character: UnicodeScalar, atIndex index: String.UnicodeScalarView.Index) throws -> TokenBuildState
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
                        throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: index)
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
                            throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: index)
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
                                self.activeParameterEndIndex = index
                            }
                        }
                        else
                        {
                            self.seenPeriod = true
                            self.activeParameterEndIndex = index
                        }
                    
                    case "e" where !self.seenExponent:
                        fallthrough
                    case "E" where !self.seenExponent:
                        self.seenExponent = true
                        self.activeParameterEndIndex = index
                        
                    case "-", "+":
                        let lastCharacter = self.previousCharacter
                        if lastCharacter == "e" || lastCharacter == "E"
                        {
                            self.activeParameterEndIndex = index
                        }
                        else if self.seenDigit
                        {
                            try self.completeActiveParameter()
                            
                            self.beginParameterAtIndex(index: index)
                        }
                        else
                        {
                            throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: index)
                        }
                    
                    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                        self.seenDigit = true
                        self.activeParameterEndIndex = index
                    default:
                        throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: index)
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
        
        private var previousCharacter : UnicodeScalar
        {
            guard let endIndex = self.activeParameterEndIndex else
            {
                return buffer[self.activeParameterStartIndex]
            }
            
            let result = buffer[endIndex]
            return result 
        }
        
        fileprivate func isCompletionCharacter(testCharacter: UnicodeScalar) -> Bool
        {
            let onLastParameter = self.numberOfParameters == (self.activeParameterIndex+1)
                && self.activeParameterEndIndex != nil
                && !self.lookingForParameter
            
            switch testCharacter
            {
                case "l", "L", "H", "h", "Q", "q", "V", "v", "C", "c", "T", "t", "S", "s", "A", "a", "m", "M",  "z", "Z":
                    return true
                case "+", "-":
                    
                    if onLastParameter
                        && self.previousCharacter != "e"
                        && self.previousCharacter != "E" // might be of the form 1e-3
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
            if self.self.activeParameterEndIndex != nil 
            {
                try self.completeActiveParameter()
            }
            
            if self.completed
            {
                return try PathToken(operand: self.operand, parameters: self.completedParameters, atOffset: self.activeParameterStartIndex)
            }
            else
            {
                throw PathToken.FailureReason.tooFewParameters(operand: self.operand, expectedParameterCount: self.numberOfParameters, actualParameterCount: self.completedParameters.count, offset: self.activeParameterStartIndex)
            }
        }
    }
    
    fileprivate struct PathParser
    {
        private enum ParseState
        {
            case lookingForFirstOperand
            case lookingForOperand
            case buildingToken
        }
        
        var resultTokens = [PathToken]()
        private var parseState = ParseState.lookingForFirstOperand
        private var tokenBuilder: TokenBuilder!
        private var buffer : String.UnicodeScalarView!
        
        fileprivate init()
        {
            
        }
        
        fileprivate mutating func parse(pathString: String) throws -> [PathToken]
        {
            self.parseState = ParseState.lookingForFirstOperand
            self.resultTokens = [PathToken]()
            
            self.buffer = pathString.unicodeScalars
            var cursor = buffer.startIndex
            let range = cursor..<buffer.endIndex
            self.tokenBuilder = TokenBuilder(buffer: self.buffer, startIndex: cursor, operand: "M")
            
            while range.contains(cursor)
            {
                let aCharacter = buffer[cursor]
                
                try self.handleCharacter(character: aCharacter, atCursor: cursor)
                
                cursor = buffer.index(after: cursor)
            }
            
            return try self.complete()
        }
        
        fileprivate mutating func handleCharacter(character: UnicodeScalar, atCursor cursor: String.UnicodeScalarView.Index) throws
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
                            throw PathToken.FailureReason.missingMoveAtStart(offset: cursor)
                        default:
                            throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: cursor)
                    }
                    
                case .lookingForOperand:
                    switch character
                    {
                        case " ", "\t", "\n", "\r", ",": // possible operand separators
                            break
                        case "z", "Z":
                            resultTokens.append(PathToken.close)
                        case "l", "L", "H", "h", "Q", "q", "V", "v", "C", "c", "T", "t", "S", "s", "A", "a", "m", "M":
                            self.tokenBuilder = TokenBuilder(buffer: self.buffer, startIndex: cursor, operand: character)
                            parseState = .buildingToken
                        case "-", "+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".": // an implied
                            guard  let mostRecentToken = self.resultTokens.last else
                            {
                                throw PathToken.FailureReason.missingMoveAtStart(offset: cursor)
                            }
                            
                            guard mostRecentToken.impliesSubsequentOperand else
                            {
                                throw PathToken.FailureReason.missingMoveAtStart(offset: cursor)
                            }
                            
                            self.tokenBuilder = TokenBuilder(buffer: self.buffer, startIndex: cursor, operand: mostRecentToken.impliedSubsequentOperand, firstCharacter: character)
                            parseState = .buildingToken
                            let _ = try self.tokenBuilder.testCompletionCharacter(character: character, atIndex: cursor) // I know it's not completed
    
                        default:
                            throw PathToken.FailureReason.unexpectedCharacter(badCharacter: character, offset: cursor)
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
                                self.tokenBuilder = TokenBuilder(buffer: self.buffer, startIndex: cursor, operand: character)
                                parseState = .buildingToken
                            case " ", "\t", "\n", "\r", ",":
                                parseState = .lookingForOperand
                            default:
                                
                                guard newToken.impliesSubsequentOperand else
                                {
                                    throw PathToken.FailureReason.missingMoveAtStart(offset: cursor)
                                }
                                self.tokenBuilder = TokenBuilder(buffer: self.buffer, startIndex: cursor, operand: newToken.impliedSubsequentOperand, firstCharacter : character) // already found the parameter
                                parseState = .buildingToken
                        }
                    }
                    else
                    {
                        if case .complete =  try self.tokenBuilder.testCompletionCharacter(character: character, atIndex: cursor)
                        {
                            resultTokens.append(try self.tokenBuilder.buildToken())
                            self.parseState = .lookingForOperand
                        }
                    }
            }
        }
        
        mutating fileprivate func complete() throws -> [PathToken]
        {
            switch parseState
            {
                case .lookingForOperand:
                    break
                case .lookingForFirstOperand:
                    throw PathToken.FailureReason.noOperands(offset: self.buffer.startIndex)
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
    #if os(iOS) || os(tvOS) || os(OSX)
    public typealias PathParameter = CGFloat
    #else
    public typealias PathParameter = Double
    #endif

    /**
        In the SVG definition of an Arc, there are almost always 2 ways to get from the starting point to the specified ending point. One way is likely longer than the other, thus the choice.
     **/
    public enum ArcChoice : Int
    {
        case large = 1
        case short = 0
    }
    
    /**
     In the SVG definition of an Arc, there is always the choice to reach from the start point to the end point by going clockwise or counterclockwise. Thus the need for this flag.
     **/
    public enum ArcSweep : Int
    {
        case clockwise = 0
        case counterclockwise = 1
    }
    /**
        If the parsing of a string fails, and it turns out to not be a valid SVG path string. These errors will be thrown.
     **/
    public enum FailureReason : CustomStringConvertible, ParseBufferError
    {
        
        case noReason
        case missingMoveAtStart(offset: String.UnicodeScalarView.Index)
        case unexpectedCharacter(badCharacter: UnicodeScalar, offset: String.UnicodeScalarView.Index)
        case tooFewParameters(operand: UnicodeScalar, expectedParameterCount: Int, actualParameterCount: Int, offset: String.UnicodeScalarView.Index)
        case badParameter(operand: UnicodeScalar, parameterIndex: Int, unexpectedValue: String, offset: String.UnicodeScalarView.Index)
        case noOperands(offset: String.UnicodeScalarView.Index)
        
        public var failurePoint: String.UnicodeScalarView.Index?
        {
            switch self {
            case .noReason:
                return nil
            case .missingMoveAtStart(let result):
                return result
            case .unexpectedCharacter(_, let result):
                return result
            case .tooFewParameters(_, _, _, let result):
                return result
            case .badParameter(_, _, _,let result):
                return result
            case .noOperands(let result):
                return result
            }
        }
        
        public var description: String
        {
            switch self
            {
                case .noReason:
                    return "No Failure"
                case let .unexpectedCharacter(badCharacter, offset):
                    return "Unexpected character: \(badCharacter) at offset: \(offset)"
                case let .tooFewParameters(operand, expectedParameterCount, actualParameterCount, offset):
                    return "Operand '\(operand)' (\(PathToken.name(forOperand: operand))) expects \(expectedParameterCount), but had \(actualParameterCount) at offset: \(offset)"
                case let .badParameter(operand, parameterIndex, unexpectedValue, offset):
                    return "Operand '\(operand)' (\(PathToken.name(forOperand: operand))) had a unexpected parameter '\(unexpectedValue)' for parameter \(parameterIndex) at offset: \(offset)"
                case .noOperands:
                    return "Just white space."
                case .missingMoveAtStart:
                    return "Missing move to at start."
            }
        }
    }
    
    case bad(UnicodeScalar, FailureReason)
    case close
    case moveTo(PathParameter, PathParameter)
    case moveToAbsolute(PathParameter, PathParameter)
    case lineTo(PathParameter, PathParameter)
    case lineToAbsolute(PathParameter, PathParameter)
    case horizontalLineTo(PathParameter)
    case horizontalLineToAbsolute(PathParameter)
    case verticalLineTo(PathParameter)
    case verticalLineToAbsolute(PathParameter)
    case cubicBezierTo(PathParameter, PathParameter, PathParameter, PathParameter, PathParameter, PathParameter)
    case cubicBezierToAbsolute(PathParameter, PathParameter, PathParameter, PathParameter, PathParameter, PathParameter)
    case smoothCubicBezierTo(PathParameter, PathParameter, PathParameter, PathParameter)
    case smoothCubicBezierToAbsolute(PathParameter, PathParameter, PathParameter, PathParameter)
    case quadraticBezierTo(PathParameter, PathParameter, PathParameter, PathParameter)
    case quadraticBezierToAbsolute(PathParameter, PathParameter, PathParameter, PathParameter)
    case smoothQuadraticBezierTo(PathParameter, PathParameter)
    case smoothQuadraticBezierToAbsolute(PathParameter, PathParameter)
    case arcTo(PathParameter, PathParameter, Double, ArcChoice, ArcSweep, PathParameter, PathParameter)
    case arcToAbsolute(PathParameter, PathParameter, Double, ArcChoice, ArcSweep, PathParameter, PathParameter)
    
    
    public  init(operand: UnicodeScalar, parameters: [PathParameter], atOffset offset: String.UnicodeScalarView.Index) throws
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
                    throw PathToken.FailureReason.badParameter(operand: operand, parameterIndex: 3, unexpectedValue: String(describing: arcChoiceRaw), offset: offset)
                }
                
                guard arcSweepRaw == 1 || arcSweepRaw == 0 else
                {
                    throw PathToken.FailureReason.badParameter(operand: operand, parameterIndex: 4, unexpectedValue: String(describing: arcSweepRaw), offset: offset)
                }
                
                let archChoice = ArcChoice(rawValue: Int(arcChoiceRaw))
                let arcSweep = ArcSweep(rawValue: Int(arcSweepRaw))
                if operand == "a"
                {
                    self = .arcTo(parameters[0], parameters[1], Double(parameters[2]), archChoice!, arcSweep!, parameters[5], parameters[6])
                }
                else
                {
                    self = .arcToAbsolute(parameters[0], parameters[1], Double(parameters[2]), archChoice!, arcSweep!, parameters[5], parameters[6])
                }
            default:
                throw PathToken.FailureReason.unexpectedCharacter(badCharacter: operand, offset: offset)
        }
    }
    
    public var operand: UnicodeScalar
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
    
    fileprivate var impliedSubsequentOperand: UnicodeScalar
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
        let name = PathToken.name(forOperand: self.operand)
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
                let largeArcString = (largeArcFlag == .large) ? "true" : "false"
                let sweepString = (sweepFlag == .clockwise) ? "true" : "false"
                return "\(name) r_x: \(xRadius), r_y: \(yRadius), Θ: \(tiltAngle)°‚ large Arc: \(largeArcString), clockwise: \(sweepString), ∆x: \(x), ∆y: \(y)"
            case let .arcToAbsolute(xRadius, yRadius, tiltAngle, largeArcFlag, sweepFlag, x, y):
                let largeArcString = (largeArcFlag == .large) ? "true" : "false"
                let sweepString = (sweepFlag == .clockwise) ? "true" : "false"
                return "\(name) r_x: \(xRadius), r_y: \(yRadius), Θ: \(tiltAngle)°‚ large Arc: \(largeArcString), clockwise: \(sweepString), x: \(x), y: \(y)"
        }
    }
    
    fileprivate static func isValidOperand(operand : UnicodeScalar) -> Bool
    {
        switch String(operand).lowercased()
        {
            case "z", "m",  "l",  "h",  "v",  "q",  "c",  "s",  "t",  "a":
                return true
            default:
                return false
        }
    }
    
    fileprivate static func parametersPerOperand(operand : UnicodeScalar) -> Int
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

    fileprivate static func name(forOperand  operand: UnicodeScalar) -> String
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
