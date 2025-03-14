//
//  TappableButton.swift
//  Notes
//
//  Created by М Й on 14.03.2025.
//

import UIKit


class TappableButton: UIButton {
    let additionalHitRadius: CGFloat = 10
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let effectiveRadius = (bounds.width / 2) + additionalHitRadius
        return distance <= effectiveRadius
    }
}
