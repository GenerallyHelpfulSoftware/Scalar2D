//
//  ContentView.swift
//  Scalar2D tVOS Test App
//
//  Created by Glenn Howes on 7/1/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                TestFrogView().foregroundColor(Color(textual: "icc-color(p3, 0.6, 1.0, 0.5)")).scaledToFit()
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
