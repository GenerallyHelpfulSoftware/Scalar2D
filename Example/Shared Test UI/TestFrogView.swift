//
//  TestFrogView.swift
//  Scalar2D
//
//  Created by Glenn Howes on 7/1/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import SwiftUI
import Scalar2D_SwiftUI
import CoreGraphics

public struct TestFrogView : View {
    private let cgPath = CGPath.path(fromSVGPath: "M185 212C139 183 40 199 39 108A18 18 0 1 1 56 75Q67 53 91 45A18 18 0 1 1 127 38C170 29 193 62 220 161L225 110Q231 84 260 115C260 142 265 205 241 198Q215 193 227 230C236 249 161 249 125 248A5 5 325 1 0 122 259C192 264 248 249 237 226Q230 206 247 211  266 210 272 161C273 139 276 106 252 93 245 86 209 65 216 133 200 46 176 19 132 26A28 28 0 0 0 81 40Q61 46 52 63A27 28 0 0 0 27 110C33 192 70 192 145 205Z")!

    public var body: some View
    {
       GeometryReader // using a GeometryReader as my SVG is not necessarily the exact size needed to fit the available size
        {
           proxy in
            Path(self.cgPath.fitting(geometry: proxy)) //using the fitting extension to scale the cgPath to fit the available size.
        }.frame(idealWidth:cgPath.boundingBoxOfPath.width, idealHeight:cgPath.boundingBoxOfPath.height)
    }
}
public struct TestFrogButtonView: View
{
    @State var toggled : Bool = false
    public var body: some View {
        Button(action: {self.toggled = !self.toggled})
        {
            // I'm using Scalar2D_Colour's to generate various Color elements and color the frog logo
            TestFrogView().scaledToFit().padding().foregroundColor($toggled.wrappedValue ? Color(textual: "icc-color(p3, 0.50, 0.94, 0.94)") : Color(textual: "chartreuse"))
        }.background(Color(textual: "rgba(25, 25, 100, .5)"))
    }
}
#if DEBUG
struct TestFrogView_Previews : PreviewProvider {
    static var previews: some View {
        TestFrogButtonView().previewDevice("Apple Watch Series 4 - 44mm")
    }
}
#endif
