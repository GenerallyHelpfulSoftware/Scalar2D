//
//  Parsing.swift
//  Scalar2D
//
//  Created by Glenn Howes on 11/2/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation

public protocol ParseBufferError : Error
{
    var failurePoint : String.UnicodeScalarView.Index?{get}
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
}
