//
//  Parsing.swift
//  Scalar2D
//
//  Created by Glenn Howes on 11/2/17.
//  Copyright © 2017-2019 Generally Helpful Software. All rights reserved.
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
