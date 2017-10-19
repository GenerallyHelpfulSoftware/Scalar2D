//
//  UnicodeScalarView+Utils.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/17/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation


public protocol ParseBufferError : Error
{
    var failurePoint : String.UnicodeScalarView.Index?{get}
}

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

public extension ParseBufferError
{
    func description(forBuffer buffer: String.UnicodeScalarView) -> String
    {
        guard let failurePoint = self.failurePoint else
        {
            return self.localizedDescription
        }
        
        let lineCount = buffer.lineCount(before: failurePoint)
        
        let lineCountString = "Failure at line: \(lineCount+1)"
        
        var beginCursor = failurePoint
        var endCursor = failurePoint
        let validRange = buffer.startIndex..<buffer.endIndex
        
        var rangeCount = 10 // arbitrary
        while rangeCount >= 0
        {
            let newBegin = buffer.index(before: beginCursor)
            if validRange.contains(newBegin)
            {
                beginCursor = newBegin
            }
            
            let newEnd = buffer.index(after: endCursor)
            if validRange.contains(newEnd)
            {
                endCursor = newEnd
            }
            rangeCount -= 1
        }

        let rangeString = String(buffer[beginCursor...endCursor])
        
        return lineCountString + "\n" + ">>> \(rangeString) <<<<\n" + self.localizedDescription
    }
}

extension String.UnicodeScalarView
{
    public func lineCount(before: String.UnicodeScalarView.Index) -> Int
    {
        var result = 0
        var cursor = self.startIndex
        let range = cursor..<before
        
        while range.contains(cursor) {
            let character = self[cursor]
            if character == "\n"
            {
                result += 1
            }
            cursor = self.index(after: cursor)
        }
        
        return result
    }
    
    
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
