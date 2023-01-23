//
//  RotatedView.swift
//  FriendlyChatSwift
//
//  Created by Dara Adekore on 2023-01-21.
//  Copyright © 2023 Google Inc. All rights reserved.
//

import Foundation


class RotatedView: UIView {
    var word = ""

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        // Set the text attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]

        // Get the size of the text
        let textSize = word.size(withAttributes: attributes)

        // Set the rotation angle
        let angle = CGFloat.pi / 4

        // Translate and rotate the context
        context?.translateBy(x: rect.width / 2, y: rect.height / 2)
        context?.rotate(by: angle)

        // Draw the text multiple times
        for i in stride(from: -3, through: 3, by: 1) {
            for j in stride(from: -3, through: 3, by: 1) {
                let x = CGFloat(i) * textSize.width
                let y = CGFloat(j) * textSize.height
                word.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
            }
        }
    }
}
