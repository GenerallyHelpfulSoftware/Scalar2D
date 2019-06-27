//
//  TestCSS_001.swift
//  Scalar2DTests
//
//  Created by Glenn Howes on 6/26/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

// The MIT License (MIT)

//  Copyright (c) 2019 Generally Helpful Software

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

// Because Swift Package Manager (at this writing) does not allow for non source files, I've moved this block of
// CSS out of a .css file and into this Swift file.

let testCSS_001 =
"""
/*/*  A text/css sampler * */

*{
fill: transparent;
stroke: #FF0;
stroke-width: 3.0;
}

text, tspan
{
font-family:Georgia, system;
font-size:31pt;
font-weight:bold;
fill:#FF1;
font-stretch: extra-expanded;
}

rect
{
fill: #FF2;
stroke: none;
}

.named
{
fill: #FF3;
stroke-width: 1;
}

path#specified
{
fill: #FF4;
stroke-width: 3;
stroke-linecap:square;
stroke-linejoin:miter;
stroke-miterlimit: 3;
stroke-dashoffset: 75.0%;
stroke-dasharray: 10% 20% ;
}

circle, path
{
fill: #FF5;
stroke: blue;
}

.named path
{
fill: #FF6;
stroke: green;
}

g:first-child
{
fill: #FF7;
background-color: orange;
border-style: initial none;
border-width: 3px thick;
}

switch > g > rect
{
fill: #FF8;
}

g:nth-child(odd)
{
fill: #FF9;
stroke-width: 5;
stroke: red;
}

g:nth-child(3n+2)
{
fill: #FFA;
stroke-width: 2;
stroke: lightblue;
}

.named rect:first-of-type
{
fill: #FFB;
stroke: darkgray;
}

.named rect:last-of-type
{
    fill: #FFC;
    stroke: teal;
}


circle:not(.named)
{
fill: #FFD;
stroke: magenta;
}

button:hover
{
fill:#CCC;
}

/* end test.css */

"""
