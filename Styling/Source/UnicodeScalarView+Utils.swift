//
//  UnicodeScalarView+Utils.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/17/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
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
