//
//  CSSParser.swift
//  Scalar2D
//
// The MIT License (MIT)

//  Copyright (c) 2016-2017 Generally Helpful Software

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

extension String
{
    // css does not support nested comments so this is fairly dimwitted.
    public func substringWithoutComments() -> String
    {
        guard let _ = self.range(of: "/*") else
        {
            return self
        }
        var result = String()
        var inComment = false
        var lastCharacter: Character = " "
        
        for aCharacter in self.characters
        {
            switch (aCharacter, inComment, lastCharacter)
            {
                case ("/", true, "*"):
                    inComment = false
                    continue 
                case ("*", false, "/"):
                    inComment = true
                case ("/", false, _):
                    break
                case (_, false, "/"):
                    result.append("/")
                    result.append(aCharacter)
                case (_, false, _):
                    result.append(aCharacter)
                default:
                    break
            }
            lastCharacter = aCharacter
        }
        
        if(inComment)
        {
            print("String.substringWithoutComments returned with an unterminated comment")
        }
        
        
        return result
    }
    
    public func asStyleBlocks() throws -> [StyleBlock]
    {
        let parser = CSSParser(cssString: self)
        
        try parser.parse()
        
        let result = parser.resultBlocks
        
        
        return result
    }
}

public  struct CSSParser
{
    public enum FailureReason : CustomStringConvertible, Error
    {
        case unexpectedCharacter(badCharacter: Character, offset: Int)
        
        public var description: String
        {
            switch self {
                case let .unexpectedCharacter(badCharacter, offset):
                    return "Unexpected character: \(badCharacter) at offset: \(offset)"
                
                
            }
        }
    }

    
    fileprivate struct CSSSelectorBuilder
    {
        var selectors = [StyleSelector]()
        enum SelectorBuildState
        {
            case lookingForSelector
            case inSelector
            case complete
        }
        
        var state : SelectorBuildState = .lookingForSelector
        
        
        
    }
    
    private enum ParseState
    {
        case awaitingSelector
        case insideSelector
        case insideBlock
    }
    
    let cssString: String
    var resultBlocks = [StyleBlock]()
    private var parseState = ParseState.awaitingSelector
  //  private var tokenBuilder: BlockBuilder
    
    init(cssString: String)
    {
        self.cssString = cssString.substringWithoutComments()
    }
    
    public func parse() throws
    {
    }
}

