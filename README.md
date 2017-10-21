# Scalar2D
Pure Swift implementation of 2D Vector Graphic Parsing and Rendering Library **(Early Development)**

Author [Glenn R. Howes](mailto:glenn@genhelp.com), *owner [Generally Helpful Software](http://genhelp.com)*

# Introduction
The intent here is to put together a package of types devoted to cross-platform 2D rendering. These will be based around the SVG document model, but not necessarily confined to using SVG documents. 

This is all very early in development. I'm gradually building up parsers, editors and data structures which should be platform agnostic, and the means to do rendering on Apple platforms. Hopefully, much of this code would be useful to someone on Linux. 

✔︎ SVG Path Parser ✔︎ Color Parser ❌CSS Parser ❌SVG Parser

✔︎ Path ➤ CGPath ✔︎ Path ➤ UIBezierPath ✔︎ Path ➤ NSBezierPath

✔︎ Colour ➤ CGColor ✔︎ Colour ➤ UIColor ✔︎ Colour ➤ NSColor ❌ Colour Palettes 

❌SVG Rendering  ❌ CSS Styling

✔︎ PathView • iOS • macOS ❌ ScalarView ❌ Button ❌ TabItem ❌ Segmented Control

❌ Document Editor ❌ Output



# Requirements
Xcode 9, Swift 4, Right now only the iOS framework is setup.
