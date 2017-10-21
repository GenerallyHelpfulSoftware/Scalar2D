##Styling
Styling is accomplished through applying CSS (cascading style sheets) to that which is scalable. Eventually, this will include not only the dynamic styling of SVG graphics, but also the appearance of user interface elements. 

##Data Types
The protocols, structs, enums and classes used in styling can be broken down into 3 general functional groups: parsing css, in memory representation of css, and providing a mechanism for applying styles. 

###Parsing
The CSSParser struct is where parsing begins. It is responsible for walking through a bit of supposed CSS and breaking it up into a list of style blocks: style blocks themselves are composed of a set of selectors (which describe what objects are to be styled) and a set of properties to be applied. As different flavors of CSS will have a different set of properties, this document model can be provided by providing an alternate implementation of a StylePropertyInterpreter (protocol). 

###Internal Representation
Let's say you had a snippet of CSS such as:
```` 
g:nth-child(odd)
{
	fill: cyan
} 
````
Which is saying that any "g" element which was an odd child would have a fill color of cyan.

This would be represented by a Style block composed of a single selector
````
let selectors = [StyleSelector(element: .element(name: "g"), pseudoClasses: [.nth_child(.odd)]
````
and a simple list of properties like 
````
let properties = [GraphicStyle(key: "fill", webColour: "cyan")]
````
Giving a StyleBlock of: 
````
let aStyleBlock = StyleBlock(selectors: selectors, styles: properties, important: false)
````
These style blocks, especially the selectors can be quite complex due to the flexibility of css. 

###Application 

To be done: applying the styling to visual elements