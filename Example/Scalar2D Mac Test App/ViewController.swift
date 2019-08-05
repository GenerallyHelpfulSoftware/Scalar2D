//
//  ViewController.swift
//  Scalar2D Mac Test App
//
//  Created by Glenn Howes on 8/7/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
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
import Cocoa
import SwiftUI
import Scalar2D_AppKitViews


class TestView: NSView
{
    override func draw(_ dirtyRect: NSRect) {
        let myBezier = NSBezierPath(svgPath: "M 170 207C139 183 40 199 41 109A18 18 0 1 1 56 75Q67 53 91 45A18 18 0 1 1 127 40C170 29 193 62 212 173L225 110Q241 70 252 120L253 156 C253 180 265 223 235 214Q210 210 215 242 C222 265 161 249 125 248")
        NSColor.darkGray.setFill()
        NSColor.blue.setStroke()
        myBezier?.lineWidth = 5
        myBezier?.fill()
        myBezier?.stroke()
    }
    
    override public var isFlipped: Bool // to be like the iOS version
    {
        return true
    }
}

class ViewController: NSViewController {
    @IBSegueAction func showSwiftUI(_ coder: NSCoder, sender: Any?) -> NSViewController? {
        return NSHostingController<TestFrogButtonView>(coder: coder, rootView: TestFrogButtonView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

