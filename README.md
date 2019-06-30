# Scalar2D
Pure Swift implementation of 2D Vector Graphic Parsing and Rendering Library **(Early Development)**

Author [Glenn R. Howes](mailto:glenn@genhelp.com), *owner [Generally Helpful Software](http://genhelp.com)*

# Introduction
The intent here is to put together a package of types devoted to cross-platform 2D rendering. These will be based around the SVG document model, but not necessarily confined to using SVG documents. 

This is all very early in development. I'm gradually building up parsers, editors and data structures which should be platform agnostic, and the means to do rendering on Apple platforms. Hopefully, much of this code would be useful to someone on Linux. 

At one point, I'd intended to provide a widget catalog, but with Apple's introduction of SwiftUI, it seems like that will be unneeded, and I should concentrate on integration with SwiftUI. Also, at some point Apple's likely to introduce an SVG rendering library of its own, so I will have to see what needs remain in that future ecosystem. 

✔︎ SVG Path Parser ✔︎ Color Parser ❌CSS Parser ❌SVG Parser

✔︎ Path ➤ CGPath ✔︎ Path ➤ UIBezierPath ✔︎ Path ➤ NSBezierPath

✔︎ Colour ➤ CGColor ✔︎ Colour ➤ UIColor ✔︎ Colour ➤ NSColor ❌ Colour Palettes 

❌SVG Rendering  ❌ CSS Styling

✔︎ PathView • iOS • macOS 

❌ Document Editor ❌ Output



# Requirements
Because of Swift Package Manager, and Swift UI. Xcode 11, Swift 5.0.1, I've moved to providing a set of Swift Package Manager packages, and I presume that will become the norm.  
