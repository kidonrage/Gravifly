//
//  EnemyDrone.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 18/09/2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import SpriteKit

class EnemyDrone: SKSpriteNode {
    init() {
        super.init(texture: SKTexture(image: UIImage(named: "drone")!), color: .white, size: CGSize(width: 200, height: 200))
        self.name = "enemyDrone"
        
//        drawDebugShape()
    }
    
    private func drawDebugShape() {
        let debugShape = SKShapeNode(rect: CGRect(origin: CGPoint(x: -100, y: -100), size: CGSize(width: 200, height: 200)))
        debugShape.strokeColor = .red
        debugShape.lineWidth = 4.0
        addChild(debugShape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func die() {
        let explosionFrames = getFramesFromAtlas(atlasName: "EnemyExplosion", singleTextureName: "enemy-explosion")
        let explode = getAnimationAction(with: explosionFrames, isRestore: false)
        let disappear = SKAction.removeFromParent()
        
        self.run(SKAction.sequence([explode, disappear]))
    }
}
