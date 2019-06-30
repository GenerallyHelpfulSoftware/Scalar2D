//
//  ContentView.swift
//  Scalar2D watchOS TestApp WatchKit Extension
//
//  Created by Glenn Howes on 7/1/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import SwiftUI
import Scalar2D_SwiftUI



struct ContentView : View {
    
    var body: some View {
        Button(action: {}) {
            TestFrogView().foregroundColor(Color(textual: "icc-color(p3, 0, 1.0, 0.5)")).scaledToFit()
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
