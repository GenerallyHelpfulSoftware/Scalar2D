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
    public var body: some View {
        Path(svgPath: "M100 250 C167 256 217 249 224 244S234 238 229 218 235 203 249 204 270 157 265 115 C260 100 236 81 228 95 S 221 137 220 145 207 19 135 30 C116 9 86 18 85 43Q66 45 53 68C21 68 17 96 32 112 43 205 113 189 185 212")?.strokedPath(StrokeStyle(lineWidth:3.0)).scaledToFit()
    }
}

#if DEBUG
struct TestFrogView_Previews : PreviewProvider {
    static var previews: some View {
        TestFrogView()
    }
}
#endif
