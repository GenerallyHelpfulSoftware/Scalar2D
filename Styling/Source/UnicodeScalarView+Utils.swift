//
//  UnicodeScalarView+Utils.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/17/17.
//  Copyright © 2017-2019 Generally Helpful Software. All rights reserved.
//
//
// The MIT License (MIT)

//  Copyright (c) 2017-2019 Generally Helpful Software

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

public enum CommentParsingError : CustomStringConvertible, ParseBufferError
{
    case unterminatedComment(String.UnicodeScalarView.Index)
    
    public var description: String
    {
        switch self
        {
        case .unterminatedComment:
            return "Unterminated Comment"
        }
    }
    
    public var failurePoint : String.UnicodeScalarView.Index?
    {
        switch self
        {
        case .unterminatedComment(let result):
            return result
        }
    }
}

extension String.UnicodeScalarView
{
    public func findUncommentedIndex () throws  -> String.UnicodeScalarView.Index
    {
        let result = self.startIndex
        guard result != self.endIndex else
        {
            return result
        }
        let character = self[result]
        if character == "/"
        {
            var cursor = self.index(after: result)
            guard cursor != self.endIndex else
            {
                return result
            }
            let secondCharacter = self[cursor]
            if secondCharacter == "*" // in a comment
            {
                let range = cursor..<self.endIndex
                var lastCharacter:UnicodeScalar = " "
                cursor = self.index(after: cursor)
                while range.contains(cursor)
                {
                    let character = self[cursor]
                    if character == "/" && lastCharacter == "*"
                    {
                        return self.index(after:cursor)
                    }
                    lastCharacter = character
                    cursor = self.index(after: cursor)
                }
                
                throw CommentParsingError.unterminatedComment(self.startIndex)

            }
        }

        return result
    }
    
    public func hasPrefix(_ string: String, inRange range: Range<String.UnicodeScalarView.Index>) -> Bool
    {
        let prefixBuffer = string.unicodeScalars
        let prefixRange = prefixBuffer.startIndex..<prefixBuffer.endIndex
        
        var prefixCursor = prefixRange.lowerBound
        var myCursor = range.lowerBound
        
        while prefixRange.contains(prefixCursor)
        {
            guard range.contains(myCursor) else
            {
                return false
            }
            
            let prefixChar = prefixBuffer[prefixCursor]
            let myChar = self[myCursor]
            if myChar != prefixChar
            {
                return false 
            }
            
            myCursor = self.index(after: myCursor)
            prefixCursor = prefixBuffer.index(after: prefixCursor)
        }
        return true
    }
    
    public func findNonWhiteSpace(inRange range: Range<String.UnicodeScalarView.Index>) throws -> String.UnicodeScalarView.Index?
    {
        var cursor = range.lowerBound
        while range.contains(cursor)
        {
            let aChar = self[cursor]
            switch aChar
            {
                case " ", "\t", " ", "\n":
                    cursor = self.index(after: cursor)
                default:
                    return cursor
                
            }
        }
        return nil
    }
    
    public func uncommentedIndex(after: String.UnicodeScalarView.Index)throws  -> String.UnicodeScalarView.Index
    {
        let result = self.index(after: after)
        guard result != self.endIndex else
        {
            return result
        }
        let character = self[result]
        if character == "/"
        {
            var cursor = self.index(after: result)
            guard cursor != self.endIndex else
            {
                return result
            }
            let secondCharacter = self[cursor]
            if secondCharacter == "*" // in a comment
            {
                let range = cursor..<self.endIndex
                var lastCharacter:UnicodeScalar = " "
                cursor = self.index(after: cursor)
                while range.contains(cursor)
                {
                    let character = self[cursor]
                    if character == "/" && lastCharacter == "*"
                    {
                        return self.index(after:cursor)
                    }
                    lastCharacter = character
                    cursor = self.index(after: cursor)
                }
                
                throw CommentParsingError.unterminatedComment(after)
            }
        }
        
        return result
    }
}
