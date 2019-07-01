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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension CGPath
{
    func fitting(geometry : GeometryProxy) -> CGPath
    {
        let baseBox = self.boundingBoxOfPath
        guard !baseBox.isEmpty && !baseBox.isInfinite && !baseBox.isNull else
        {
            return self
        }
        
        let nativeWidth = baseBox.width
        let nativeHeight = baseBox.height
        let nativeAspectRatio = nativeWidth/nativeHeight;
        let boundedAspectRatio = geometry.size.width/geometry.size.height;
        
        var scale : CGFloat!
        if(nativeAspectRatio >= boundedAspectRatio) // blank space on top and bottom
        {
            scale = geometry.size.width / nativeWidth
        }
        else
        {
            scale = geometry.size.height / nativeHeight
        }
        var requiredTransform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: -baseBox.minX*scale, y: -baseBox.minY*scale)
        
        return self.copy(using: &requiredTransform) ?? self
    }
}


public struct TestFrogView : View {
    private let cgPath = CGPath.path(fromSVGPath: "M100 250 C167 256 217 249 224 244S234 238 229 218 235 203 249 204 270 157 265 115 C260 100 236 81 228 95 S 221 137 220 145 207 19 135 30 C116 9 86 18 85 43Q66 45 53 68C21 68 17 96 32 112 43 205 113 189 185 212")!

    public var body: some View
    {
        
       GeometryReader
        {
           proxy in
            Path(self.cgPath.fitting(geometry: proxy)).strokedPath(StrokeStyle(lineWidth:3.0))
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
            TestFrogView().scaledToFit().padding().foregroundColor($toggled.value ? Color(textual: "icc-color(p3, 0.50, 0.94, 0.94)") : Color(textual: "chartreuse"))
            }.background(Color(textual: "rgba(44, 100, 211, .5)"))
    }
}
#if DEBUG
struct TestFrogView_Previews : PreviewProvider {
    static var previews: some View {
        TestFrogButtonView()
    }
}
#endif
