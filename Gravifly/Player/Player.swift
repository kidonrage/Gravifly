//
//  Player.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 14/09/2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    
    private var runningFrames = [SKTexture]()
    private var jumpingFrames = [SKTexture]()
    private var runningShootingFrames = [SKTexture]()
    private var jumpingShootingFrames = [SKTexture]()
    
    private let runningAnimationKey = "runningAnimation"
    private let runShootingAnimationKey = "runShootingAnimation"
    private let foreverShootingKey = "foreverShooting"
    private let stopShootingKey = "stopShooting"
    
    private var isJumping: Bool = false
    private var isShooting: Bool = false
    
    init() {
        super.init(texture: nil, color: .white, size: CGSize(width: 238, height: 238))
        
        runningFrames = getFramesFromAtlas(atlasName: "PlayerRun", singleTextureName: "run")
        jumpingFrames = getFramesFromAtlas(atlasName: "PlayerJump", singleTextureName: "jump")
        if let jumpShootingFrame = jumpingFrames.last {
            jumpingShootingFrames = [jumpShootingFrame]
        }
        runningShootingFrames = getFramesFromAtlas(atlasName: "PlayerRunShoot", singleTextureName: "run-shoot")
        
        let initialTexture = runningFrames[0]
        self.texture = initialTexture
        self.name = "player"
        
        self.isJumping = false
    }
    
    func move(velocity: CGPoint, dt: TimeInterval) {
        let amountToMove = CGPoint(
            x: velocity.x * CGFloat(dt),
            y: velocity.y * CGFloat(dt)
        )
        print("Amount to move: \(amountToMove)")
        self.position = CGPoint(
            x: self.position.x + amountToMove.x,
            y: self.position.y + amountToMove.y
        )
    }
    
    func startRunning() {
        isJumping = false
        
        clearAnimation()
        
        self.run(SKAction.repeatForever(getAnimationAction(with: runningFrames)), withKey: runningAnimationKey)
    }
    
    func jump() {
        guard
            let lastFrame = jumpingFrames.last,
            isJumping == false
            else {return}
        
        clearAnimation()
        
        let jumpHeight: CGFloat = 450
        let jumpDuration: TimeInterval = 0.9
        let animateJump = SKAction.sequence([
            getAnimationAction(with: jumpingFrames),
            SKAction.run({ [weak self] in
                self?.texture = lastFrame
            })
        ])
        let moveUp = SKAction.moveBy(x: 0, y: jumpHeight, duration: jumpDuration / 2)
        let moveUpGroup = SKAction.group([
            animateJump,
            moveUp
            ])
        let moveDown = moveUp.reversed()
        let run = SKAction.run { [weak self] in
            self?.run(SKAction.playSoundFileNamed("land.wav", waitForCompletion: false))
            self?.startRunning()
            self?.isJumping = false
        }
        
        isJumping = true
        self.run(SKAction.sequence([moveUpGroup, moveDown, run]))
        self.run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
    }
    
    func startShooting() {
        let shootingAnimationFrames = isJumping ? jumpingShootingFrames : runningShootingFrames
        let animationAction = getAnimationAction(with: shootingAnimationFrames)
        let stopShootingSequence = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                self?.isShooting = false
                self?.removeAction(forKey: self?.foreverShootingKey ?? "")
                print("Stopped shooting")
            }
        ])
        
        if isShooting {
            self.removeAction(forKey: stopShootingKey)
            self.run(stopShootingSequence, withKey: stopShootingKey)
        } else {
            isShooting = true
            self.run(SKAction.repeatForever(animationAction), withKey: foreverShootingKey)
            self.run(stopShootingSequence, withKey: stopShootingKey)
        }
    }
    
    func clearAnimation() {
        self.removeAction(forKey: runningAnimationKey)
        self.removeAction(forKey: stopShootingKey)
        self.removeAction(forKey: foreverShootingKey)
        isShooting = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
