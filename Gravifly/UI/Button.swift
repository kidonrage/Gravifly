//
//  Button.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 11.02.2020.
//  Copyright © 2020 Vlad Eliseev. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKNode {
    
    init(labelText: String, nodeName: String) {
        super.init()
        
        let buttonTexture = SKTexture(imageNamed: "button")
        buttonTexture.filteringMode = .nearest
        let buttonNode = SKSpriteNode(texture: buttonTexture)
        buttonNode.setScale(10)
        buttonNode.zPosition = 1
        buttonNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(buttonNode)
        
        let buttonLabel = SKLabelNode(fontNamed: "UnrealEngine")
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.name = "start-button"
        buttonLabel.text = "START"
        buttonLabel.fontSize = 120
        buttonLabel.position.y += 10
        buttonLabel.fontColor = .white
        buttonLabel.zPosition = 10
        
        addChild(buttonLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
