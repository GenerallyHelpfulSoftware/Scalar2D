// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scalar2D",
    platforms: [.macOS("10.11.2"), .iOS("10.0"), .watchOS("6.0"), .tvOS("10.0")],
    products: [
        .library(
            name: "Scalar2D_Utils",
            targets: ["Scalar2D_Utils"]),
        .library(
            name: "Scalar2D_Colour",
            targets: ["Scalar2D_Colour"]),
        .library(
            name: "Scalar2D_GraphicPath",
            targets: ["Scalar2D_GraphicPath"]),
        .library(
            name: "Scalar2D_CoreGraphics",
            targets: ["Scalar2D_CoreGraphics"]),
        .library(
            name: "Scalar2D_FontDescription",
            targets: ["Scalar2D_FontDescription"]),
        .library(
            name: "Scalar2D_Styling",
            targets: ["Scalar2D_Styling"]),
        .library(
            name: "Scalar2D_SVG",
            targets: ["Scalar2D_SVG"]),
        .library(
            name: "Scalar2D_CoreViews",
            targets: ["Scalar2D_CoreViews"]),
        .library(
            name: "Scalar2D_AppKitViews",
            targets: ["Scalar2D_AppKitViews"]),
        .library(
            name: "Scalar2D_UIKitViews",
            targets: ["Scalar2D_UIKitViews"]),
        .library(
            name: "Scalar2D_SwiftUI",
            targets: ["Scalar2D_SwiftUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Scalar2D_Utils",
            path: "Utils/Sources"
        ),
        .target(
            name: "Scalar2D_Colour",
            path: "Colour/Sources"
        ),
        .target(
            name: "Scalar2D_FontDescription",
            dependencies: ["Scalar2D_Utils"],
            path: "Font/Sources"
        ),
        .target(
            name: "Scalar2D_GraphicPath",
            dependencies: ["Scalar2D_Utils"],
            path: "GraphicPath/Sources"
        ),
        .target(
            name: "Scalar2D_CoreGraphics",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Styling"],
            path: "CoreGraphics/Sources"
        ),
        .target(
            name: "Scalar2D_Styling",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Colour", "Scalar2D_FontDescription"],
            path: "Styling/Sources"
        ),
        .target(
            name: "Scalar2D_SVG",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Colour", "Scalar2D_FontDescription", "Scalar2D_Styling", "Scalar2D_CoreGraphics"],
            path: "SVG/Sources"
        ),
        .target(
            name: "Scalar2D_CoreViews",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Colour", "Scalar2D_FontDescription", "Scalar2D_Styling", "Scalar2D_CoreGraphics"],
            path: "Views/CrossPlatform/Sources"
        ),
        .target(
            name: "Scalar2D_AppKitViews",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Colour", "Scalar2D_FontDescription", "Scalar2D_Styling", "Scalar2D_CoreGraphics", "Scalar2D_CoreViews"],
            path: "Views/Cocoa/Sources"
        ),
        .target(
            name: "Scalar2D_UIKitViews",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Colour", "Scalar2D_FontDescription", "Scalar2D_Styling", "Scalar2D_CoreGraphics", "Scalar2D_CoreViews"],
            path: "Views/UIKit/Sources"
        ),
        .target(
            name: "Scalar2D_SwiftUI",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Colour", "Scalar2D_FontDescription", "Scalar2D_Styling", "Scalar2D_CoreGraphics",],
            path: "SwiftUI/Sources"
        ),
        .testTarget(
            name: "Scalar2DTests",
            dependencies: ["Scalar2D_Utils", "Scalar2D_Colour", "Scalar2D_Styling", "Scalar2D_GraphicPath", "Scalar2D_FontDescription"],
            path: "Scalar2DTests")
        
    ]
)
