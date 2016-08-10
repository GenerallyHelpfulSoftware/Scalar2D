# Scalar2D
Pure Swift implementation of 2D Vector Graphic Parsing and Rendering Library **(Early Development)**

Author [Glenn R. Howes](mailto:glenn@genhelp.com), *owner [Generally Helpful Software](http://genhelp.com)*

# Introduction
The intent here is to put together a package of types devoted to cross-platform 2D rendering. These will be based around the SVG document model, but not necessarily confined to using SVG documents. 

This is all very early in development. Right now, I've just implemented an SVG path parser and used it to generate the iOS and macOS native types: CGPath, NSBezierPath (in progress) and UIBezierPath. 

# Requirements
Xcode 8, Swift 3, Right now only the iOS framework is setup, and I have not debugged the NSBezierPath generator.
