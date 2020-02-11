//
//  MainMenu.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 11.02.2020.
//  Copyright © 2020 Vlad Eliseev. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class MainMenuScene: SKScene {
    
    var backgroundMusicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        addBackground()
        addStartButton()
        addTitle()
        playBackgroundMusic(filename: "main-menu.wav")
    }
    
    func playBackgroundMusic(filename: String) {
        let resourceUrl = Bundle.main.url(forResource: filename, withExtension: nil)
        guard let url = resourceUrl else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch {
            print("Could not create audio player!")
            return
        }
    }
    
    private func addTitle() {
        let titleTexture = SKTexture(imageNamed: "game-title")
        titleTexture.filteringMode = .nearest
        
        let titleNode = SKSpriteNode(texture: titleTexture)
        titleNode.size = CGSize(width: 1092, height: 360)
        titleNode.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 + 200
        )
        
        addChild(titleNode)
    }
    
    private func addStartButton() {
        let startButton = Button(labelText: "START", nodeName: "start-button")
        
        startButton.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 300
        )
        
        addChild(startButton)
        
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.3)
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.8)
        
        let animationAction = SKAction.sequence([moveDown, moveUp, moveDown])
        
        startButton.run(SKAction.repeatForever(animationAction))
    }
    
    private func addBackground() {
        let background = SKSpriteNode(imageNamed: "menu-background")
        background.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
        
        addChild(background)
    }
    
    private func startGame() {
        let gameScene = GameScene(size: size)
        gameScene.size = size
        gameScene.scaleMode = scaleMode
        let push = SKTransition.push(with: .left, duration: 1.0)
        
        view?.presentScene(gameScene, transition: push)
        
        backgroundMusicPlayer.stop()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        if let nodeName = touchedNode.name {
            
            if nodeName == "start-button" {
              startGame()
            }
            
        }
    }
    
}
