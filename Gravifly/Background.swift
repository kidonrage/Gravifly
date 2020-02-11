//
//  Background.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 14/09/2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import SpriteKit

class Background: SKSpriteNode {
    init(size: CGSize) {
        super.init(texture: nil, color: .white, size: size)
        
        self.name = "background"
        
        var backgroundImages: [String] = []
        
        let imagesNum = 2
        for _ in 1...imagesNum {
            let backgroundImageName = "background\(Int.random(in: 1...imagesNum))"
            backgroundImages.append(backgroundImageName)
        }
        
        var currentBackgroundSize = CGSize(width: 0, height: self.size.height)
        
        for image in backgroundImages {
            let backgroundNode = SKSpriteNode(imageNamed: image)
            backgroundNode.anchorPoint = CGPoint(x: 0, y: 0.5)
            backgroundNode.position = CGPoint(x: currentBackgroundSize.width, y: 0)
            currentBackgroundSize.width += backgroundNode.size.width
            self.addChild(backgroundNode)
        }
        
        self.size = currentBackgroundSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
