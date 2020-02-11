//
//  CGFloat+Utils.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 14/09/2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}
