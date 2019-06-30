import UIKit
import CoreGraphics



let nativeBounds = CGRect(x: -48, y: -58, width: 390, height: 511)
let myBounds = CGRect(x: 0.0, y: 0, width: 100, height: 100)


var transform = CGAffineTransform.identity

let nativeAspectRatio = nativeBounds.width / nativeBounds.height
let myAspectRatio = myBounds.width / myBounds.height

var scaledSize : CGSize!
if nativeAspectRatio < myAspectRatio
{
    scaledSize = CGSize(width: myBounds.height*nativeAspectRatio, height: myBounds.height)
}
else
{
    scaledSize = CGSize(width: myBounds.width, height: myBounds.width / nativeAspectRatio)
}
let scale = scaledSize.width / nativeBounds.width
let wantedRect = CGRect(x: (myBounds.width-scaledSize.width)/2.0, y: (myBounds.height-scaledSize.height)/2.0, width:  scaledSize.width
    , height: scaledSize.height)


let zeroTransform = CGAffineTransform(translationX: wantedRect.minX - nativeBounds.minX, y: wantedRect.minY-nativeBounds.minY)
let zeroRect = nativeBounds.applying(zeroTransform)
let scaledTransform = CGAffineTransform(scaleX: scale, y: scale)
let scaledRect = nativeBounds.applying(scaledTransform)
let scaleTransform = zeroTransform.concatenating(scaledTransform)
let transformedRect = nativeBounds.applying(scaleTransform)
//transform = scaleTransform.translatedBy(x: wantedRect.minX, y: nativeBounds.minX*scale)
//let tx = transform.tx
//let ty = transform.ty
//
//let testRect = nativeBounds.applying(transform)
