//
//  GameScene.swift
//  Gravifly
//
//  Created by Vlad Eliseev on 02/09/2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let playableRect: CGRect
    var gameTimer: Timer?
    
    let cameraNode = SKCameraNode()
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height
        )
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var lives = 3 {
        didSet {
            renderLives()
        }
    }
    var availableShots = 10 {
        didSet {
            renderShots()
        }
    }
    var gameOver = false
    var isPlayerInvincible = false
    
    let scoreLabel = SKLabelNode()
    
    let backgroundNodeScrollTime: TimeInterval = 6
    
    let player = Player()
    var playerMovePointsPerSec: CGFloat = 600.0 {
        didSet {
            removeAllActions()
            startSpawning()
        }
    }
    var velocity = CGPoint.zero
    
    let healthIndicator = SKNode()
    let remainingShotsIndicator = SKNode()
    
    var backgroundMusicPlayer: AVAudioPlayer!
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 2.16
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { timer in
            self.playerMovePointsPerSec += 10
            if self.availableShots < 10 {
                self.availableShots += 1
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        createRoof()
        createBackground()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpHandler))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tapRecognizer)
        
        player.position = CGPoint(x: 300, y: playableRect.minY + player.size.height / 2)
        player.zPosition = 1
        addChild(player)
        player.startRunning()
        
        startSpawning()
        
        setupUI()
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        renderLives()
        renderShots()
        
        playBackgroundMusic(filename: "pursuit.mp3")
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
    
    private func renderLives() {
        healthIndicator.removeAllChildren()
        
        for i in 0 ..< 3 {
            let hpImageName = i < lives ? "hp_full" : "hp_empty"
            
            let hpNode = SKSpriteNode(imageNamed: hpImageName)
            hpNode.setScale(4.0)
            
            hpNode.position = CGPoint(
                x: hpNode.size.width * 1.2 * CGFloat(i),
                y: 0
            )
            hpNode.zPosition = CGFloat(i)
            
            healthIndicator.addChild(hpNode)
        }
    }
    
    private func renderShots() {
        remainingShotsIndicator.removeAllChildren()
        
        for i in 0 ..< 10 {
            let shotImageName = i < availableShots ? "fire-full" : "fire-empty"
            
            let shotNode = SKSpriteNode(imageNamed: shotImageName)
            shotNode.setScale(5.0)
            
            shotNode.position = CGPoint(
                x: shotNode.size.width * 1.5 * CGFloat(i),
                y: 0
            )
            shotNode.zPosition = CGFloat(i)
            
            remainingShotsIndicator.addChild(shotNode)
        }

    }
    
    private func startSpawning() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval(1200.0 / playerMovePointsPerSec)),
                SKAction.run { [weak self] in
                    self?.createBackgroundBuildings()
                }
            ])
        ))
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval(1200.0 / playerMovePointsPerSec)),
                SKAction.run { [weak self] in
                    self?.createForegroundBuildings()
                }
            ])
        ))
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval(1500.0 / playerMovePointsPerSec)),
                SKAction.run() { [weak self] in
                    self?.spawnDrone()
                }
            ])
        ))
    }
    
    private func setupUI() {
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontName = "UnrealEngine"
        scoreLabel.fontSize = 64
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(
            x: cameraRect.maxX - scoreLabel.frame.width / 2 - 30,
            y: cameraRect.maxY - 30
        )
        
        cameraNode.addChild(scoreLabel)
        scoreLabel.zPosition = 100
        
        healthIndicator.position = CGPoint(
            x: cameraRect.minX + 60,
            y: cameraRect.maxY - 60
        )
        cameraNode.addChild(healthIndicator)
        
        remainingShotsIndicator.position = CGPoint(
            x: cameraRect.minX + 60,
            y: cameraRect.maxY
        )
        cameraNode.addChild(remainingShotsIndicator)
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(
            x: velocity.x * CGFloat(dt),
            y: velocity.y * CGFloat(dt)
        )
        
        sprite.position = CGPoint(
            x: sprite.position.x + amountToMove.x,
            y: sprite.position.y + amountToMove.y
        )
    }
    
    func spawnDrone() {
        let drone = EnemyDrone()
        
        drone.position = CGPoint(
            x: cameraRect.maxX + drone.size.width / 2,
            y: CGFloat.random(
                min: cameraRect.minY + drone.size.height / 2,
                max: cameraRect.maxY - 200 - drone.size.height / 2))
        drone.zPosition = player.zPosition
        addChild(drone)
        
        let amountToMove = frame.size.width + drone.size.width
        
        let minTime = TimeInterval(amountToMove / (playerMovePointsPerSec))
        let maxTime = TimeInterval(amountToMove / (playerMovePointsPerSec - 200))
        
        let actionMove = SKAction.moveBy(x: -amountToMove, y: 0, duration: TimeInterval.random(in: minTime...maxTime))
        let actionRemove = SKAction.removeFromParent()
        
        drone.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func shotHit(enemy: SKSpriteNode) {
        score += 1
        playerMovePointsPerSec += 100
        
        let explosionFrames = getFramesFromAtlas(atlasName: "EnemyExplosion", singleTextureName: "enemy-explosion")
        let explode = getAnimationAction(with: explosionFrames, isRestore: false)
        let disappear = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([explode, disappear]))
        
        run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
    }
    
    func createRoof() {
        let roofTexture = SKTexture(imageNamed: "roof")
        let roofDecorTexture = SKTexture(imageNamed: "roof-decor")
        
        for i in 0...1 {
            let roof = SKSpriteNode(texture: roofTexture)
            roof.name = "roof"
            
            let roofDecor = SKSpriteNode(texture: roofDecorTexture)
            roofDecor.anchorPoint = .zero
            roofDecor.position = CGPoint(x: 0, y: roofTexture.size().height)
            roof.addChild(roofDecor)
            
            roof.anchorPoint = CGPoint(
                x: 0,
                y: 0
            )
            roof.zPosition = 1
            roof.position = CGPoint(
                x: roof.size.width * CGFloat(i),
                y: playableRect.minY - roofTexture.size().height
            )
            addChild(roof)
            
            let moveLeft = SKAction.moveBy(x: -playerMovePointsPerSec, y: 0, duration: 1.0)
            roof.run(SKAction.repeatForever(moveLeft))
        }
    }
    
    func createBackground() {
        let backgroundMovePerSecond: CGFloat = 80.0
        for i in 1...2 {
            let background = SKSpriteNode(imageNamed: "background\(i)")
            background.name = "background"
            background.anchorPoint = .zero
            background.position = CGPoint(
                x: background.size.width * CGFloat(i - 1),
                y: 0)
            background.zPosition = -30
            addChild(background)
            
            let moveLeft = SKAction.moveBy(x: -backgroundMovePerSecond, y: 0, duration: 1.0)
            background.run(SKAction.repeatForever(moveLeft))
        }
    }
    
    func createBackgroundBuildings() {
        let backgroundBuildingMovePerSecond: CGFloat = 160.0
        
        let backgroundBuildingTexture = SKTexture(imageNamed: "background-building")
        let building = SKSpriteNode(texture: backgroundBuildingTexture)
        
        building.name = "building"
        building.anchorPoint = CGPoint.zero
        building.zPosition = -20
        
        let moveLeft = SKAction.moveBy(x: -backgroundBuildingMovePerSecond, y: 0, duration: 1.0)
        
        let wait = SKAction.wait(forDuration: TimeInterval.random(in: 0.0...TimeInterval(600.0 / playerMovePointsPerSec)))
        let add = SKAction.run { [weak self] in
            self?.addChild(building)
            print("Added")
            building.position = CGPoint(
                x: self?.cameraRect.maxX ?? 0,
                y: self?.cameraRect.minY ?? 0
            )
            building.run(SKAction.repeatForever(moveLeft))
        }
        
        run(SKAction.sequence([wait, add]))
    }
    
    func createForegroundBuildings() {
        let foregroundBuildingMovePerSecond: CGFloat = 300.0
        
        let buildingTextures = getFramesFromAtlas(atlasName: "Buildings", singleTextureName: "building")
        let currentTextureIndex = Int.random(in: 0..<buildingTextures.count)
        let building = SKSpriteNode(texture: buildingTextures[currentTextureIndex])
        
        building.name = "building"
        building.anchorPoint = .zero
        building.zPosition = -10
        
        let moveLeft = SKAction.moveBy(x: -foregroundBuildingMovePerSecond, y: 0, duration: 1.0)
        
        let wait = SKAction.wait(forDuration: TimeInterval.random(in: 0.0...TimeInterval(1200.0 / playerMovePointsPerSec)))
        let add = SKAction.run { [weak self] in
            self?.addChild(building)
            print("Added")
            building.position = CGPoint(
                x: self?.cameraRect.maxX ?? 0,
                y: self?.cameraRect.minY ?? 0
            )
            building.run(SKAction.repeatForever(moveLeft))
        }
        
        run(SKAction.sequence([wait, add]))
    }
    
    @objc func swipeUpHandler() {
        player.jump()
    }
    
    @objc func tapHandler() {
        guard availableShots >= 0 else {
            return
        }
        
        player.startShooting()
        
        let shot = Shot();
        let position = CGPoint(
            x: player.size.width / 2,
            y: 10
        )
        shot.position = player.convert(position, to: self)
        shot.zPosition = player.zPosition
        addChild(shot)
        
        let moveLeft = SKAction.moveBy(x: playerMovePointsPerSec + 1000, y: 0, duration: 1.0)
        shot.run(SKAction.repeatForever(moveLeft))
        run(SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false))
        
        availableShots -= 1
        renderShots()
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.blue
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func getDamage() {
        lives -= 1
        run(SKAction.playSoundFileNamed("playerhit.wav", waitForCompletion: false))
        
        if lives <= 0 && !gameOver {
            gameOver = true
            
            let gameOverScene = GameOverScene(size: size)
            gameOverScene.scaleMode = scaleMode
            
            let fade = SKTransition.fade(with: .white, duration: 0.5)
            
            view?.presentScene(gameOverScene, transition: fade)
            
            backgroundMusicPlayer.stop()
        } else {
            isPlayerInvincible = true
            
            let blinkTimes = 16.0
            let duration = 3.0
            let blinkAction = SKAction.customAction(
            withDuration: duration) { node, elapsedTime in
                let slice = duration / blinkTimes
                let remainder = Double(elapsedTime).truncatingRemainder(
                    dividingBy: slice)
                node.isHidden = remainder > slice / 2
            }
            let godModeOff = SKAction.run { [weak self] in
                self?.isPlayerInvincible = false
                self?.player.isHidden = false
            }
            
            player.run(SKAction.sequence([blinkAction, godModeOff]))
        }
    }
    
    func checkCollisions() {
        var hitDrones: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemyDrone") { (node, _) in
            let drone = node as! SKSpriteNode
            
            if (!self.isPlayerInvincible && drone.frame.insetBy(dx: 40, dy: 40).intersects(self.player.frame)) {
                self.getDamage()
            }
            
            self.enumerateChildNodes(withName: "shot", using: { (shot, _) in
                if (drone.frame.intersects(shot.frame)) {
                    hitDrones.append(drone)
                    drone.name = ""
                    shot.removeFromParent()
                }
            })
        }
        
        for drone in hitDrones {
            shotHit(enemy: drone)
        }
        
    }
    
    func moveCamera() {
        let cameraVelocity = CGPoint(x: playerMovePointsPerSec, y: 0)
        
        let amountToMove = CGPoint(
            x: cameraVelocity.x * CGFloat(dt),
            y: cameraVelocity.y * CGFloat(dt)
        )
        
        cameraNode.position = CGPoint(
            x: cameraNode.position.x + amountToMove.x,
            y: cameraNode.position.y + amountToMove.y
        )
        
        respawnInvisibleNodes(withName: "roof")
        respawnInvisibleNodes(withName: "background")
        
        clearInvisibleNodes(withName: "building")
        
        enumerateChildNodes(withName: "shot") { node, _ in
            let shot = node as! SKSpriteNode
            
            if shot.position.x + shot.size.width > self.cameraRect.maxX {
                shot.removeFromParent()
            }
        }
    }
    
    func respawnInvisibleNodes(withName nodeName: String) {
        enumerateChildNodes(withName: nodeName) { node, _ in
            let invisibleNode = node as! SKSpriteNode
            
            if invisibleNode.position.x + invisibleNode.size.width < self.cameraRect.origin.x {
                invisibleNode.position = CGPoint(
                    x: invisibleNode.position.x + invisibleNode.size.width * 2,
                    y: invisibleNode.position.y
                )
            }
        }
    }
    
    func clearInvisibleNodes(withName nodeName: String) {
        enumerateChildNodes(withName: nodeName) { node, _ in
            let invisibleNode = node as! SKSpriteNode
            
            if invisibleNode.position.x + invisibleNode.size.width < self.cameraRect.origin.x {
                invisibleNode.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        move(sprite: player, velocity: CGPoint(x: playerMovePointsPerSec, y: 0))
        
        checkCollisions()
        
        moveCamera()
    }
}
