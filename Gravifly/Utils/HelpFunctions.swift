//
//  HelpFunctions.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 17/09/2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import SpriteKit

func getFramesFromAtlas(atlasName: String, singleTextureName: String) -> [SKTexture] {
    let animatedAtlas = SKTextureAtlas(named: atlasName)
    var frames: [SKTexture] = []
    
    let numImages = animatedAtlas.textureNames.count
    for i in 1...numImages {
        let textureName = "\(singleTextureName)-\(i)"
        frames.append(animatedAtlas.textureNamed(textureName))
    }
    
    return frames
}

func getAnimationAction(with frames: [SKTexture]) -> SKAction {
    return SKAction.animate(
        with: frames,
        timePerFrame: 0.1,
        resize: false,
        restore: true
    )
}
