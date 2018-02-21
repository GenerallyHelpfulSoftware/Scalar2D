import UIKit
import CoreGraphics

let pointSize : CGFloat = 24
let fontDescriptor = UIFont(name: "HoeflerText-Regular", size: pointSize)!.fontDescriptor



let fractionFontDesc = fontDescriptor.addingAttributes(
    [
        UIFontDescriptor.AttributeName.featureSettings: [
            [
                UIFontDescriptor.FeatureKey.featureIdentifier: kLetterCaseType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kSmallCapsSelector
            ]
        ]
    ] )

print(fractionFontDesc.description)

let label = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 100))

label.font = UIFont(descriptor: fractionFontDesc, size:pointSize)
label.text = "Montpelier, Vermont" // note just plain numbers and a regular slash
