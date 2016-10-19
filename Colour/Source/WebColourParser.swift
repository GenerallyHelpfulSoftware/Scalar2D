//
//  WebColourParser.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/8/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//
//
//
// The MIT License (MIT)

//  Copyright (c) 2016 Generally Helpful Software

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


public struct WebColourParser : ColourParser
{
    private static let table : ColourTable = ["aliceblue": Colour.rgb(red:240/255.0, green: 248/255.0, blue: 255/255.0, source: "aliceblue"),
          "antiquewhite": Colour.rgb(red:250/255.0, green: 235/255.0, blue: 215/255.0, source: "antiquewhite"),
          "aqua": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 255/255.0, source: "aqua"),
          "aquamarine": Colour.rgb(red:127/255.0, green: 255/255.0, blue: 212/255.0, source: "aquamarine"),
          "azure": Colour.rgb(red:240/255.0, green: 255/255.0, blue: 255/255.0, source: "azure"),
          "beige": Colour.rgb(red:245/255.0, green: 245/255.0, blue: 220/255.0, source: "beige"),
          "bisque": Colour.rgb(red:255/255.0, green: 228/255.0, blue: 196/255.0, source: "bisque"),
          "black": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 0/255.0, source: "black"),
          "blanchedalmond": Colour.rgb(red:255/255.0, green: 235/255.0, blue: 205/255.0, source: "blanchedalmond"),
          "blue": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 255/255.0, source: "blue"),
          "blueviolet": Colour.rgb(red:138/255.0, green: 43/255.0, blue: 226/255.0, source: "blueviolet"),
          "brown": Colour.rgb(red:165/255.0, green: 42/255.0, blue: 42/255.0, source: "brown"),
          "burlywood": Colour.rgb(red:222/255.0, green: 184/255.0, blue: 135/255.0, source: "burlywood"),
          "cadetblue": Colour.rgb(red:95/255.0, green: 158/255.0, blue: 160/255.0, source: "cadetblue"),
          "chartreuse": Colour.rgb(red:127/255.0, green: 255/255.0, blue: 0/255.0, source: "chartreuse"),
          "chocolate": Colour.rgb(red:210/255.0, green: 105/255.0, blue: 30/255.0, source: "chocolate"),
          "coral": Colour.rgb(red:255/255.0, green: 127/255.0, blue: 80/255.0, source: "coral"),
          "cornflowerblue": Colour.rgb(red:100/255.0, green: 149/255.0, blue: 237/255.0, source: "cornflowerblue"),
          "cornsilk": Colour.rgb(red:255/255.0, green: 248/255.0, blue: 220/255.0, source: "cornsilk"),
          "crimson": Colour.rgb(red:220/255.0, green: 20/255.0, blue: 60/255.0, source: "crimson"),
          "cyan": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 255/255.0, source: "cyan"),
          "darkblue": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 139/255.0, source: "darkblue"),
          "darkcyan": Colour.rgb(red:0/255.0, green: 139/255.0, blue: 139/255.0, source: "darkcyan"),
          "darkgoldenrod": Colour.rgb(red:184/255.0, green: 134/255.0, blue: 11/255.0, source: "darkgoldenrod"),
          "darkgray": Colour.rgb(red:169/255.0, green: 169/255.0, blue: 169/255.0, source: "darkgray"),
          "darkgrey": Colour.rgb(red:169/255.0, green: 169/255.0, blue: 169/255.0, source: "darkgrey"),
          "darkgreen": Colour.rgb(red:0/255.0, green: 100/255.0, blue: 0/255.0, source: "darkgreen"),
          "darkkhaki": Colour.rgb(red:189/255.0, green: 183/255.0, blue: 107/255.0, source: "darkkhaki"),
          "darkmagenta": Colour.rgb(red:139/255.0, green: 0/255.0, blue: 139/255.0, source: "darkmagenta"),
          "darkolivegreen": Colour.rgb(red:85/255.0, green: 107/255.0, blue: 47/255.0, source: "darkolivegreen"),
          "darkorange": Colour.rgb(red:255/255.0, green: 140/255.0, blue: 0/255.0, source: "darkorange"),
          "darkorchid": Colour.rgb(red:153/255.0, green: 50/255.0, blue: 204/255.0, source: "darkorchid"),
          "darkred": Colour.rgb(red:139/255.0, green: 0/255.0, blue: 0/255.0, source: "darkred"),
          "darksalmon": Colour.rgb(red:233/255.0, green: 150/255.0, blue: 122/255.0, source: "darksalmon"),
          "darkseagreen": Colour.rgb(red:143/255.0, green: 188/255.0, blue: 143/255.0, source: "darkseagreen"),
          "darkslateblue": Colour.rgb(red:72/255.0, green: 61/255.0, blue: 139/255.0, source: "darkslateblue"),
          "darkslategray": Colour.rgb(red:47/255.0, green: 79/255.0, blue: 79/255.0, source: "darkslategray"),
          "darkslategrey": Colour.rgb(red:47/255.0, green: 79/255.0, blue: 79/255.0, source: "darkslategrey"),
          "darkturquoise": Colour.rgb(red:0/255.0, green: 206/255.0, blue: 209/255.0, source: "darkturquoise"),
          "darkviolet": Colour.rgb(red:148/255.0, green: 0/255.0, blue: 211/255.0, source: "darkviolet"),
          "deeppink": Colour.rgb(red:255/255.0, green: 20/255.0, blue: 147/255.0, source: "deeppink"),
          "deepskyblue": Colour.rgb(red:0/255.0, green: 191/255.0, blue: 255/255.0, source: "deepskyblue"),
          "dimgray": Colour.rgb(red:105/255.0, green: 105/255.0, blue: 105/255.0, source: "dimgray"),
          "dimgrey": Colour.rgb(red:105/255.0, green: 105/255.0, blue: 105/255.0, source: "dimgrey"),
          "dodgerblue": Colour.rgb(red:30/255.0, green: 144/255.0, blue: 255/255.0, source: "dodgerblue"),
          "firebrick": Colour.rgb(red:178/255.0, green: 34/255.0, blue: 34/255.0, source: "firebrick"),
          "floralwhite": Colour.rgb(red:255/255.0, green: 250/255.0, blue: 240/255.0, source: "floralwhite"),
          "forestgreen": Colour.rgb(red:34/255.0, green: 139/255.0, blue: 34/255.0, source: "forestgreen"),
          "fuchsia": Colour.rgb(red:255/255.0, green: 0/255.0, blue: 255/255.0, source: "fuchsia"),
          "gainsboro": Colour.rgb(red:220/255.0, green: 220/255.0, blue: 220/255.0, source: "gainsboro"),
          "ghostwhite": Colour.rgb(red:248/255.0, green: 248/255.0, blue: 255/255.0, source: "ghostwhite"),
          "gold": Colour.rgb(red:255/255.0, green: 215/255.0, blue: 0/255.0, source: "gold"),
          "goldenrod": Colour.rgb(red:218/255.0, green: 165/255.0, blue: 32/255.0, source: "goldenrod"),
          "gray": Colour.rgb(red:128/255.0, green: 128/255.0, blue: 128/255.0, source: "gray"),
          "grey": Colour.rgb(red:128/255.0, green: 128/255.0, blue: 128/255.0, source: "grey"),
          "green": Colour.rgb(red:0/255.0, green: 128/255.0, blue: 0/255.0, source: "green"),
          "greenyellow": Colour.rgb(red:173/255.0, green: 255/255.0, blue: 47/255.0, source: "greenyellow"),
          "honeydew": Colour.rgb(red:240/255.0, green: 255/255.0, blue: 240/255.0, source: "honeydew"),
          "hotpink": Colour.rgb(red:255/255.0, green: 105/255.0, blue: 180/255.0, source: "hotpink"),
          "indianred": Colour.rgb(red:205/255.0, green: 92/255.0, blue: 92/255.0, source: "indianred"),
          "indigo": Colour.rgb(red:75/255.0, green: 0/255.0, blue: 130/255.0, source: "indigo"),
          "ivory": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 240/255.0, source: "ivory"),
          "khaki": Colour.rgb(red:240/255.0, green: 230/255.0, blue: 140/255.0, source: "khaki"),
          "lavender": Colour.rgb(red:230/255.0, green: 230/255.0, blue: 250/255.0, source: "lavender"),
          "lavenderblush": Colour.rgb(red:255/255.0, green: 240/255.0, blue: 245/255.0, source: "lavenderblush"),
          "lawngreen": Colour.rgb(red:124/255.0, green: 252/255.0, blue: 0/255.0, source: "lawngreen"),
          "lemonchiffon": Colour.rgb(red:255/255.0, green: 250/255.0, blue: 205/255.0, source: "lemonchiffon"),
          "lightblue": Colour.rgb(red:173/255.0, green: 216/255.0, blue: 230/255.0, source: "lightblue"),
          "lightcoral": Colour.rgb(red:240/255.0, green: 128/255.0, blue: 128/255.0, source: "lightcoral"),
          "lightcyan": Colour.rgb(red:224/255.0, green: 255/255.0, blue: 255/255.0, source: "lightcyan"),
          "lightgoldenrodyellow": Colour.rgb(red:250/255.0, green: 250/255.0, blue: 210/255.0, source: "lightgoldenrodyellow"),
          "lightgray": Colour.rgb(red:211/255.0, green: 211/255.0, blue: 211/255.0, source: "lightgray"),
          "lightgrey": Colour.rgb(red:211/255.0, green: 211/255.0, blue: 211/255.0, source: "lightgrey"),
          "lightgreen": Colour.rgb(red:144/255.0, green: 238/255.0, blue: 144/255.0, source: "lightgreen"),
          "lightpink": Colour.rgb(red:255/255.0, green: 182/255.0, blue: 193/255.0, source: "lightpink"),
          "lightsalmon": Colour.rgb(red:255/255.0, green: 160/255.0, blue: 122/255.0, source: "lightsalmon"),
          "lightseagreen": Colour.rgb(red:32/255.0, green: 178/255.0, blue: 170/255.0, source: "lightseagreen"),
          "lightskyblue": Colour.rgb(red:135/255.0, green: 206/255.0, blue: 250/255.0, source: "lightskyblue"),
          "lightslategray": Colour.rgb(red:119/255.0, green: 136/255.0, blue: 153/255.0, source: "lightslategray"),
          "lightslategrey": Colour.rgb(red:119/255.0, green: 136/255.0, blue: 153/255.0, source: "lightslategrey"),
          "lightsteelblue": Colour.rgb(red:176/255.0, green: 196/255.0, blue: 222/255.0, source: "lightsteelblue"),
          "lightyellow": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 224/255.0, source: "lightyellow"),
          "lime": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 0/255.0, source: "lime"),
          "limegreen": Colour.rgb(red:50/255.0, green: 205/255.0, blue: 50/255.0, source: "limegreen"),
          "linen": Colour.rgb(red:250/255.0, green: 240/255.0, blue: 230/255.0, source: "linen"),
          "magenta": Colour.rgb(red:255/255.0, green: 0/255.0, blue: 255/255.0, source: "magenta"),
          "maroon": Colour.rgb(red:128/255.0, green: 0/255.0, blue: 0/255.0, source: "maroon"),
          "mediumaquamarine": Colour.rgb(red:102/255.0, green: 205/255.0, blue: 170/255.0, source: "mediumaquamarine"),
          "mediumblue": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 205/255.0, source: "mediumblue"),
          "mediumorchid": Colour.rgb(red:186/255.0, green: 85/255.0, blue: 211/255.0, source: "mediumorchid"),
          "mediumpurple": Colour.rgb(red:147/255.0, green: 112/255.0, blue: 219/255.0, source: "mediumpurple"),
          "mediumseagreen": Colour.rgb(red:60/255.0, green: 179/255.0, blue: 113/255.0, source: "mediumseagreen"),
          "mediumslateblue": Colour.rgb(red:123/255.0, green: 104/255.0, blue: 238/255.0, source: "mediumslateblue"),
          "mediumspringgreen": Colour.rgb(red:0/255.0, green: 250/255.0, blue: 154/255.0, source: "mediumspringgreen"),
          "mediumturquoise": Colour.rgb(red:72/255.0, green: 209/255.0, blue: 204/255.0, source: "mediumturquoise"),
          "mediumvioletred": Colour.rgb(red:199/255.0, green: 21/255.0, blue: 133/255.0, source: "mediumvioletred"),
          "midnightblue": Colour.rgb(red:25/255.0, green: 25/255.0, blue: 112/255.0, source: "midnightblue"),
          "mintcream": Colour.rgb(red:245/255.0, green: 255/255.0, blue: 250/255.0, source: "mintcream"),
          "mistyrose": Colour.rgb(red:255/255.0, green: 228/255.0, blue: 225/255.0, source: "mistyrose"),
          "moccasin": Colour.rgb(red:255/255.0, green: 228/255.0, blue: 181/255.0, source: "moccasin"),
          "navajowhite": Colour.rgb(red:255/255.0, green: 222/255.0, blue: 173/255.0, source: "navajowhite"),
          "navy": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 128/255.0, source: "navy"),
          "oldlace": Colour.rgb(red:253/255.0, green: 245/255.0, blue: 230/255.0, source: "oldlace"),
          "olive": Colour.rgb(red:128/255.0, green: 128/255.0, blue: 0/255.0, source: "olive"),
          "olivedrab": Colour.rgb(red:107/255.0, green: 142/255.0, blue: 35/255.0, source: "olivedrab"),
          "orange": Colour.rgb(red:255/255.0, green: 165/255.0, blue: 0/255.0, source: "orange"),
          "orangered": Colour.rgb(red:255/255.0, green: 69/255.0, blue: 0/255.0, source: "orangered"),
          "orchid": Colour.rgb(red:218/255.0, green: 112/255.0, blue: 214/255.0, source: "orchid"),
          "palegoldenrod": Colour.rgb(red:238/255.0, green: 232/255.0, blue: 170/255.0, source: "palegoldenrod"),
          "palegreen": Colour.rgb(red:152/255.0, green: 251/255.0, blue: 152/255.0, source: "palegreen"),
          "paleturquoise": Colour.rgb(red:175/255.0, green: 238/255.0, blue: 238/255.0, source: "paleturquoise"),
          "palevioletred": Colour.rgb(red:219/255.0, green: 112/255.0, blue: 147/255.0, source: "palevioletred"),
          "papayawhip": Colour.rgb(red:255/255.0, green: 239/255.0, blue: 213/255.0, source: "papayawhip"),
          "peachpuff": Colour.rgb(red:255/255.0, green: 218/255.0, blue: 185/255.0, source: "peachpuff"),
          "peru": Colour.rgb(red:205/255.0, green: 133/255.0, blue: 63/255.0, source: "peru"),
          "pink": Colour.rgb(red:255/255.0, green: 192/255.0, blue: 203/255.0, source: "pink"),
          "plum": Colour.rgb(red:221/255.0, green: 160/255.0, blue: 221/255.0, source: "plum"),
          "powderblue": Colour.rgb(red:176/255.0, green: 224/255.0, blue: 230/255.0, source: "powderblue"),
          "purple": Colour.rgb(red:128/255.0, green: 0/255.0, blue: 128/255.0, source: "purple"),
          "rebeccapurple": Colour.rgb(red:102/255.0, green: 51/255.0, blue: 153/255.0, source: "rebeccapurple"),
          "red": Colour.rgb(red:255/255.0, green: 0/255.0, blue: 0/255.0, source: "red"),
          "rosybrown": Colour.rgb(red:188/255.0, green: 143/255.0, blue: 143/255.0, source: "rosybrown"),
          "royalblue": Colour.rgb(red:65/255.0, green: 105/255.0, blue: 225/255.0, source: "royalblue"),
          "saddlebrown": Colour.rgb(red:139/255.0, green: 69/255.0, blue: 19/255.0, source: "saddlebrown"),
          "salmon": Colour.rgb(red:250/255.0, green: 128/255.0, blue: 114/255.0, source: "salmon"),
          "sandybrown": Colour.rgb(red:244/255.0, green: 164/255.0, blue: 96/255.0, source: "sandybrown"),
          "seagreen": Colour.rgb(red:46/255.0, green: 139/255.0, blue: 87/255.0, source: "seagreen"),
          "seashell": Colour.rgb(red:255/255.0, green: 245/255.0, blue: 238/255.0, source: "seashell"),
          "sienna": Colour.rgb(red:160/255.0, green: 82/255.0, blue: 45/255.0, source: "sienna"),
          "silver": Colour.rgb(red:192/255.0, green: 192/255.0, blue: 192/255.0, source: "silver"),
          "skyblue": Colour.rgb(red:135/255.0, green: 206/255.0, blue: 235/255.0, source: "skyblue"),
          "slateblue": Colour.rgb(red:106/255.0, green: 90/255.0, blue: 205/255.0, source: "slateblue"),
          "slategray": Colour.rgb(red:112/255.0, green: 128/255.0, blue: 144/255.0, source: "slategray"),
          "slategrey": Colour.rgb(red:112/255.0, green: 128/255.0, blue: 144/255.0, source: "slategrey"),
          "snow": Colour.rgb(red:255/255.0, green: 250/255.0, blue: 250/255.0, source: "snow"),
          "springgreen": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 127/255.0, source: "springgreen"),
          "steelblue": Colour.rgb(red:70/255.0, green: 130/255.0, blue: 180/255.0, source: "steelblue"),
          "tan": Colour.rgb(red:210/255.0, green: 180/255.0, blue: 140/255.0, source: "tan"),
          "teal": Colour.rgb(red:0/255.0, green: 128/255.0, blue: 128/255.0, source: "teal"),
          "thistle": Colour.rgb(red:216/255.0, green: 191/255.0, blue: 216/255.0, source: "thistle"),
          "tomato": Colour.rgb(red:255/255.0, green: 99/255.0, blue: 71/255.0, source: "tomato"),
          "turquoise": Colour.rgb(red:64/255.0, green: 224/255.0, blue: 208/255.0, source: "turquoise"),
          "violet": Colour.rgb(red:238/255.0, green: 130/255.0, blue: 238/255.0, source: "violet"),
          "wheat": Colour.rgb(red:245/255.0, green: 222/255.0, blue: 179/255.0, source: "wheat"),
          "white": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 255/255.0, source: "white"),
          "whitesmoke": Colour.rgb(red:245/255.0, green: 245/255.0, blue: 245/255.0, source: "whitesmoke"),
          "yellow": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 0/255.0, source: "yellow"),
          "yellowgreen": Colour.rgb(red:154/255.0, green: 205/255.0, blue: 50/255.0, source: "yellowgreen")]
    
    /**
     * It's assumed that source is in lowercase
     */
    
    public func deserializeString(source: String, colorContext: ColorContext?) throws -> Colour?
    {
        return WebColourParser.table[source]
    }
    
    public init()
    {
    }
}
