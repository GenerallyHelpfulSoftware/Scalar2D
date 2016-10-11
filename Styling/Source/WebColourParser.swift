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
    private static let table : ColourTable = ["aliceblue": Colour.rgb(red:240/255.0, green: 248/255.0, blue: 255/255.0),
          "antiquewhite": Colour.rgb(red:250/255.0, green: 235/255.0, blue: 215/255.0),
          "aqua": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 255/255.0),
          "aquamarine": Colour.rgb(red:127/255.0, green: 255/255.0, blue: 212/255.0),
          "azure": Colour.rgb(red:240/255.0, green: 255/255.0, blue: 255/255.0),
          "beige": Colour.rgb(red:245/255.0, green: 245/255.0, blue: 220/255.0),
          "bisque": Colour.rgb(red:255/255.0, green: 228/255.0, blue: 196/255.0),
          "black": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 0/255.0),
          "blanchedalmond": Colour.rgb(red:255/255.0, green: 235/255.0, blue: 205/255.0),
          "blue": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 255/255.0),
          "blueviolet": Colour.rgb(red:138/255.0, green: 43/255.0, blue: 226/255.0),
          "brown": Colour.rgb(red:165/255.0, green: 42/255.0, blue: 42/255.0),
          "burlywood": Colour.rgb(red:222/255.0, green: 184/255.0, blue: 135/255.0),
          "cadetblue": Colour.rgb(red:95/255.0, green: 158/255.0, blue: 160/255.0),
          "chartreuse": Colour.rgb(red:127/255.0, green: 255/255.0, blue: 0/255.0),
          "chocolate": Colour.rgb(red:210/255.0, green: 105/255.0, blue: 30/255.0),
          "coral": Colour.rgb(red:255/255.0, green: 127/255.0, blue: 80/255.0),
          "cornflowerblue": Colour.rgb(red:100/255.0, green: 149/255.0, blue: 237/255.0),
          "cornsilk": Colour.rgb(red:255/255.0, green: 248/255.0, blue: 220/255.0),
          "crimson": Colour.rgb(red:220/255.0, green: 20/255.0, blue: 60/255.0),
          "cyan": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 255/255.0),
          "darkblue": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 139/255.0),
          "darkcyan": Colour.rgb(red:0/255.0, green: 139/255.0, blue: 139/255.0),
          "darkgoldenrod": Colour.rgb(red:184/255.0, green: 134/255.0, blue: 11/255.0),
          "darkgray": Colour.rgb(red:169/255.0, green: 169/255.0, blue: 169/255.0),
          "darkgrey": Colour.rgb(red:169/255.0, green: 169/255.0, blue: 169/255.0),
          "darkgreen": Colour.rgb(red:0/255.0, green: 100/255.0, blue: 0/255.0),
          "darkkhaki": Colour.rgb(red:189/255.0, green: 183/255.0, blue: 107/255.0),
          "darkmagenta": Colour.rgb(red:139/255.0, green: 0/255.0, blue: 139/255.0),
          "darkolivegreen": Colour.rgb(red:85/255.0, green: 107/255.0, blue: 47/255.0),
          "darkorange": Colour.rgb(red:255/255.0, green: 140/255.0, blue: 0/255.0),
          "darkorchid": Colour.rgb(red:153/255.0, green: 50/255.0, blue: 204/255.0),
          "darkred": Colour.rgb(red:139/255.0, green: 0/255.0, blue: 0/255.0),
          "darksalmon": Colour.rgb(red:233/255.0, green: 150/255.0, blue: 122/255.0),
          "darkseagreen": Colour.rgb(red:143/255.0, green: 188/255.0, blue: 143/255.0),
          "darkslateblue": Colour.rgb(red:72/255.0, green: 61/255.0, blue: 139/255.0),
          "darkslategray": Colour.rgb(red:47/255.0, green: 79/255.0, blue: 79/255.0),
          "darkslategrey": Colour.rgb(red:47/255.0, green: 79/255.0, blue: 79/255.0),
          "darkturquoise": Colour.rgb(red:0/255.0, green: 206/255.0, blue: 209/255.0),
          "darkviolet": Colour.rgb(red:148/255.0, green: 0/255.0, blue: 211/255.0),
          "deeppink": Colour.rgb(red:255/255.0, green: 20/255.0, blue: 147/255.0),
          "deepskyblue": Colour.rgb(red:0/255.0, green: 191/255.0, blue: 255/255.0),
          "dimgray": Colour.rgb(red:105/255.0, green: 105/255.0, blue: 105/255.0),
          "dimgrey": Colour.rgb(red:105/255.0, green: 105/255.0, blue: 105/255.0),
          "dodgerblue": Colour.rgb(red:30/255.0, green: 144/255.0, blue: 255/255.0),
          "firebrick": Colour.rgb(red:178/255.0, green: 34/255.0, blue: 34/255.0),
          "floralwhite": Colour.rgb(red:255/255.0, green: 250/255.0, blue: 240/255.0),
          "forestgreen": Colour.rgb(red:34/255.0, green: 139/255.0, blue: 34/255.0),
          "fuchsia": Colour.rgb(red:255/255.0, green: 0/255.0, blue: 255/255.0),
          "gainsboro": Colour.rgb(red:220/255.0, green: 220/255.0, blue: 220/255.0),
          "ghostwhite": Colour.rgb(red:248/255.0, green: 248/255.0, blue: 255/255.0),
          "gold": Colour.rgb(red:255/255.0, green: 215/255.0, blue: 0/255.0),
          "goldenrod": Colour.rgb(red:218/255.0, green: 165/255.0, blue: 32/255.0),
          "gray": Colour.rgb(red:128/255.0, green: 128/255.0, blue: 128/255.0),
          "grey": Colour.rgb(red:128/255.0, green: 128/255.0, blue: 128/255.0),
          "green": Colour.rgb(red:0/255.0, green: 128/255.0, blue: 0/255.0),
          "greenyellow": Colour.rgb(red:173/255.0, green: 255/255.0, blue: 47/255.0),
          "honeydew": Colour.rgb(red:240/255.0, green: 255/255.0, blue: 240/255.0),
          "hotpink": Colour.rgb(red:255/255.0, green: 105/255.0, blue: 180/255.0),
          "indianred": Colour.rgb(red:205/255.0, green: 92/255.0, blue: 92/255.0),
          "indigo": Colour.rgb(red:75/255.0, green: 0/255.0, blue: 130/255.0),
          "ivory": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 240/255.0),
          "khaki": Colour.rgb(red:240/255.0, green: 230/255.0, blue: 140/255.0),
          "lavender": Colour.rgb(red:230/255.0, green: 230/255.0, blue: 250/255.0),
          "lavenderblush": Colour.rgb(red:255/255.0, green: 240/255.0, blue: 245/255.0),
          "lawngreen": Colour.rgb(red:124/255.0, green: 252/255.0, blue: 0/255.0),
          "lemonchiffon": Colour.rgb(red:255/255.0, green: 250/255.0, blue: 205/255.0),
          "lightblue": Colour.rgb(red:173/255.0, green: 216/255.0, blue: 230/255.0),
          "lightcoral": Colour.rgb(red:240/255.0, green: 128/255.0, blue: 128/255.0),
          "lightcyan": Colour.rgb(red:224/255.0, green: 255/255.0, blue: 255/255.0),
          "lightgoldenrodyellow": Colour.rgb(red:250/255.0, green: 250/255.0, blue: 210/255.0),
          "lightgray": Colour.rgb(red:211/255.0, green: 211/255.0, blue: 211/255.0),
          "lightgrey": Colour.rgb(red:211/255.0, green: 211/255.0, blue: 211/255.0),
          "lightgreen": Colour.rgb(red:144/255.0, green: 238/255.0, blue: 144/255.0),
          "lightpink": Colour.rgb(red:255/255.0, green: 182/255.0, blue: 193/255.0),
          "lightsalmon": Colour.rgb(red:255/255.0, green: 160/255.0, blue: 122/255.0),
          "lightseagreen": Colour.rgb(red:32/255.0, green: 178/255.0, blue: 170/255.0),
          "lightskyblue": Colour.rgb(red:135/255.0, green: 206/255.0, blue: 250/255.0),
          "lightslategray": Colour.rgb(red:119/255.0, green: 136/255.0, blue: 153/255.0),
          "lightslategrey": Colour.rgb(red:119/255.0, green: 136/255.0, blue: 153/255.0),
          "lightsteelblue": Colour.rgb(red:176/255.0, green: 196/255.0, blue: 222/255.0),
          "lightyellow": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 224/255.0),
          "lime": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 0/255.0),
          "limegreen": Colour.rgb(red:50/255.0, green: 205/255.0, blue: 50/255.0),
          "linen": Colour.rgb(red:250/255.0, green: 240/255.0, blue: 230/255.0),
          "magenta": Colour.rgb(red:255/255.0, green: 0/255.0, blue: 255/255.0),
          "maroon": Colour.rgb(red:128/255.0, green: 0/255.0, blue: 0/255.0),
          "mediumaquamarine": Colour.rgb(red:102/255.0, green: 205/255.0, blue: 170/255.0),
          "mediumblue": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 205/255.0),
          "mediumorchid": Colour.rgb(red:186/255.0, green: 85/255.0, blue: 211/255.0),
          "mediumpurple": Colour.rgb(red:147/255.0, green: 112/255.0, blue: 219/255.0),
          "mediumseagreen": Colour.rgb(red:60/255.0, green: 179/255.0, blue: 113/255.0),
          "mediumslateblue": Colour.rgb(red:123/255.0, green: 104/255.0, blue: 238/255.0),
          "mediumspringgreen": Colour.rgb(red:0/255.0, green: 250/255.0, blue: 154/255.0),
          "mediumturquoise": Colour.rgb(red:72/255.0, green: 209/255.0, blue: 204/255.0),
          "mediumvioletred": Colour.rgb(red:199/255.0, green: 21/255.0, blue: 133/255.0),
          "midnightblue": Colour.rgb(red:25/255.0, green: 25/255.0, blue: 112/255.0),
          "mintcream": Colour.rgb(red:245/255.0, green: 255/255.0, blue: 250/255.0),
          "mistyrose": Colour.rgb(red:255/255.0, green: 228/255.0, blue: 225/255.0),
          "moccasin": Colour.rgb(red:255/255.0, green: 228/255.0, blue: 181/255.0),
          "navajowhite": Colour.rgb(red:255/255.0, green: 222/255.0, blue: 173/255.0),
          "navy": Colour.rgb(red:0/255.0, green: 0/255.0, blue: 128/255.0),
          "oldlace": Colour.rgb(red:253/255.0, green: 245/255.0, blue: 230/255.0),
          "olive": Colour.rgb(red:128/255.0, green: 128/255.0, blue: 0/255.0),
          "olivedrab": Colour.rgb(red:107/255.0, green: 142/255.0, blue: 35/255.0),
          "orange": Colour.rgb(red:255/255.0, green: 165/255.0, blue: 0/255.0),
          "orangered": Colour.rgb(red:255/255.0, green: 69/255.0, blue: 0/255.0),
          "orchid": Colour.rgb(red:218/255.0, green: 112/255.0, blue: 214/255.0),
          "palegoldenrod": Colour.rgb(red:238/255.0, green: 232/255.0, blue: 170/255.0),
          "palegreen": Colour.rgb(red:152/255.0, green: 251/255.0, blue: 152/255.0),
          "paleturquoise": Colour.rgb(red:175/255.0, green: 238/255.0, blue: 238/255.0),
          "palevioletred": Colour.rgb(red:219/255.0, green: 112/255.0, blue: 147/255.0),
          "papayawhip": Colour.rgb(red:255/255.0, green: 239/255.0, blue: 213/255.0),
          "peachpuff": Colour.rgb(red:255/255.0, green: 218/255.0, blue: 185/255.0),
          "peru": Colour.rgb(red:205/255.0, green: 133/255.0, blue: 63/255.0),
          "pink": Colour.rgb(red:255/255.0, green: 192/255.0, blue: 203/255.0),
          "plum": Colour.rgb(red:221/255.0, green: 160/255.0, blue: 221/255.0),
          "powderblue": Colour.rgb(red:176/255.0, green: 224/255.0, blue: 230/255.0),
          "purple": Colour.rgb(red:128/255.0, green: 0/255.0, blue: 128/255.0),
          "rebeccapurple": Colour.rgb(red:102/255.0, green: 51/255.0, blue: 153/255.0),
          "red": Colour.rgb(red:255/255.0, green: 0/255.0, blue: 0/255.0),
          "rosybrown": Colour.rgb(red:188/255.0, green: 143/255.0, blue: 143/255.0),
          "royalblue": Colour.rgb(red:65/255.0, green: 105/255.0, blue: 225/255.0),
          "saddlebrown": Colour.rgb(red:139/255.0, green: 69/255.0, blue: 19/255.0),
          "salmon": Colour.rgb(red:250/255.0, green: 128/255.0, blue: 114/255.0),
          "sandybrown": Colour.rgb(red:244/255.0, green: 164/255.0, blue: 96/255.0),
          "seagreen": Colour.rgb(red:46/255.0, green: 139/255.0, blue: 87/255.0),
          "seashell": Colour.rgb(red:255/255.0, green: 245/255.0, blue: 238/255.0),
          "sienna": Colour.rgb(red:160/255.0, green: 82/255.0, blue: 45/255.0),
          "silver": Colour.rgb(red:192/255.0, green: 192/255.0, blue: 192/255.0),
          "skyblue": Colour.rgb(red:135/255.0, green: 206/255.0, blue: 235/255.0),
          "slateblue": Colour.rgb(red:106/255.0, green: 90/255.0, blue: 205/255.0),
          "slategray": Colour.rgb(red:112/255.0, green: 128/255.0, blue: 144/255.0),
          "slategrey": Colour.rgb(red:112/255.0, green: 128/255.0, blue: 144/255.0),
          "snow": Colour.rgb(red:255/255.0, green: 250/255.0, blue: 250/255.0),
          "springgreen": Colour.rgb(red:0/255.0, green: 255/255.0, blue: 127/255.0),
          "steelblue": Colour.rgb(red:70/255.0, green: 130/255.0, blue: 180/255.0),
          "tan": Colour.rgb(red:210/255.0, green: 180/255.0, blue: 140/255.0),
          "teal": Colour.rgb(red:0/255.0, green: 128/255.0, blue: 128/255.0),
          "thistle": Colour.rgb(red:216/255.0, green: 191/255.0, blue: 216/255.0),
          "tomato": Colour.rgb(red:255/255.0, green: 99/255.0, blue: 71/255.0),
          "turquoise": Colour.rgb(red:64/255.0, green: 224/255.0, blue: 208/255.0),
          "violet": Colour.rgb(red:238/255.0, green: 130/255.0, blue: 238/255.0),
          "wheat": Colour.rgb(red:245/255.0, green: 222/255.0, blue: 179/255.0),
          "white": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 255/255.0),
          "whitesmoke": Colour.rgb(red:245/255.0, green: 245/255.0, blue: 245/255.0),
          "yellow": Colour.rgb(red:255/255.0, green: 255/255.0, blue: 0/255.0),
          "yellowgreen": Colour.rgb(red:154/255.0, green: 205/255.0, blue: 50/255.0)]
    
    /**
     * It's assumed that textColour is in lowercase
     */
    
    public func deserializeString(textColour: String) throws -> Colour?
    {
        return WebColourParser.table[textColour]
    }
    
    public init()
    {
    }
}
