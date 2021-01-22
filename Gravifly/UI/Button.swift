//
//  Button.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 11.02.2020.
//  Copyright © 2020 Vlad Eliseev. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKSpriteNode {
    
    init(labelText: String, nodeName: String) {
        let buttonTexture = SKTexture(imageNamed: "button")
        buttonTexture.filteringMode = .nearest
        
        super.init(
            texture: buttonTexture,
            color: .clear,
            size: CGSize(
                width: buttonTexture.size().width * 10,
                height: buttonTexture.size().height * 10
            )
        )
        
        self.name = nodeName
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let buttonLabel = SKLabelNode(fontNamed: "UnrealEngine")
        buttonLabel.name = nodeName
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.text = labelText
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
