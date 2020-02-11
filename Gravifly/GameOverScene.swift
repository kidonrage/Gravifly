//
//  GameOverScene.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 11.02.2020.
//  Copyright © 2020 Vlad Eliseev. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        run(SKAction.playSoundFileNamed("game-over.mp3", waitForCompletion: false))
        addBackground()
        addButtons()
    }
    
    private func addBackground() {
        let background = SKSpriteNode(imageNamed: "gameover-pattern")
        background.zPosition = -1
        
        background.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
        
        addChild(background)
        
        let gameOverTexture = SKTexture(imageNamed: "gameover")
        gameOverTexture.filteringMode = .nearest
        
        let gameOverLabel = SKSpriteNode(texture: gameOverTexture)
        
        gameOverLabel.setScale(10)
        
        gameOverLabel.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 + 200
        )
        
        addChild(gameOverLabel)
    }
    
    private func addButtons() {
        let retryButton = Button(labelText: "RETRY", nodeName: "retry-button")
        
        retryButton.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 200
        )
        
        addChild(retryButton)
        
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.3)
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.8)
        
        let animationAction = SKAction.sequence([moveDown, moveUp, moveDown])
        
        retryButton.run(SKAction.repeatForever(animationAction))
        
        let menuButton = Button(labelText: "MENU", nodeName: "menu-button")
        
        menuButton.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 380
        )
        
        addChild(menuButton)
    }
    
    func retry() {
        let gameScene = GameScene(size: size)
        gameScene.size = size
        gameScene.scaleMode = scaleMode
        let fade = SKTransition.fade(with: .purple, duration: 1.5)
        
        view?.presentScene(gameScene, transition: fade)
    }
    
    func goToMenu() {
        let menuScene = MainMenuScene(size: size)
        menuScene.size = size
        menuScene.scaleMode = scaleMode
        let push = SKTransition.push(with: .right, duration: 1.5)
        
        view?.presentScene(menuScene, transition: push)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        print(touchedNode)
        
        if let nodeName = touchedNode.name {
            
            print(nodeName)
            
            if nodeName == "retry-button" {
              retry()
            } else if nodeName == "menu-button" {
              goToMenu()
            }
            
        }
    }
    
}
