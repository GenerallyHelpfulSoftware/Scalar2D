//
//  ViewController.swift
//  Scalar2D Mac Test App
//
//  Created by Glenn Howes on 8/7/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import Cocoa
import Scalar2D_mac


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

