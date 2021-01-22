//
//  Shot.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 17/09/2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import SpriteKit

class Shot: SKSpriteNode {
    private var shotFrames = [SKTexture]()
    
    init() {
        super.init(texture: nil, color: .white, size: CGSize(width: 40, height: 40))
        shotFrames = getFramesFromAtlas(atlasName: "Shot", singleTextureName: "shot")
        let initialTexture = shotFrames[0]
        self.texture = initialTexture
        self.name = "shot"
        self.zPosition = 100
        
        self.run(SKAction.repeatForever(getAnimationAction(with: shotFrames)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
