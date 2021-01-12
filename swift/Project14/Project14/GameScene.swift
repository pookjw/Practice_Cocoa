//
//  GameScene.swift
//  Project14
//
//  Created by Jinwoo Kim on 1/12/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var bulletsSprite: SKSpriteNode!
    var bulletsTextures = [
        SKTexture(imageNamed: "shots0"),
        SKTexture(imageNamed: "shots1"),
        SKTexture(imageNamed: "shots2"),
        SKTexture(imageNamed: "shots3")
    ]
    var bulletsInClip = 3 {
        didSet {
            bulletsSprite.texture = bulletsTextures[bulletsInClip]
        }
    }
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var targetSpeed = 4.0
    var targetDelay = 0.8
    var targetsCreated = 0
    
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        createBackground()
        createWater()
        createOverlay()
        levelUp()
    }
    
    deinit {
        print("deinit")
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: 400, y: 300)
        background.blendMode = .replace
        addChild(background)
        
        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 400, y: 300)
        addChild(grass)
        grass.zPosition = 100
    }
    
    func createWater() {
        func animate(_ node: SKNode, distance: CGFloat, duration: TimeInterval) {
            let movementUp = SKAction.moveBy(x: 0, y: distance, duration: duration)
            let movementDown = movementUp.reversed()
            let sequence = SKAction.sequence([movementUp, movementDown])
            let repeatForever = SKAction.repeatForever(sequence)
            node.run(repeatForever)
        }
        
        let waterBackground = SKSpriteNode(imageNamed: "water-bg")
        waterBackground.position = CGPoint(x: 400, y: 180)
        waterBackground.zPosition = 200
        addChild(waterBackground)
        
        let waterForeground = SKSpriteNode(imageNamed: "water-fg")
        waterForeground.position = CGPoint(x: 400, y: 120)
        waterForeground.zPosition = 300
        addChild(waterForeground)
        
        animate(waterBackground, distance: 8, duration: 1.3)
        animate(waterForeground, distance: 12, duration: 1)
    }
    
    func createOverlay() {
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: 400, y: 300)
        curtains.zPosition = 400
        addChild(curtains)
        
        bulletsSprite = SKSpriteNode(imageNamed: "shots3")
        bulletsSprite.position = CGPoint(x: 170, y: 60)
        bulletsSprite.zPosition = 500
        addChild(bulletsSprite)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        // SKSpriteNode는 anchorPoint로 중심을 잡지만, SKLabelNode는 alignment로 잡는다.
        scoreLabel.horizontalAlignmentMode = .right
        
        scoreLabel.position = CGPoint(x: 680, y: 50)
        scoreLabel.zPosition = 500
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }
    
    func createTarget() {
        // create and initialize our custom node
        let target = Target()
        target.setup()
        
        // decide where we want to place it in the game scene
        let level = Int.random(in: 0...2)
        
        // default to targets moving left to right
        var movingRight = true
        
        switch level {
        case 0:
            // in front of the grass
            target.zPosition = 150
            target.position.y = 280
            target.setScale(0.7)
        case 1:
            // in front of the water background
            target.zPosition = 250
            target.position.y = 190
            target.setScale(0.85)
            movingRight = false
        default:
            // in front of the water foreground
            target.zPosition = 350
            target.position.y = 100
        }
        
        // now position the target at the left or right edge, moving it to the opposite edge.
        let move: SKAction
        
        if movingRight {
            target.position.x = 0
            move = SKAction.moveTo(x: 800, duration: targetSpeed)
        } else {
            target.position.x = 800
            // flip the target horizontally so it faces the direction of travel
            target.xScale = -target.xScale
            move = SKAction.moveTo(x: 0, duration: targetSpeed)
        }
        
        // create a sequence that moves the target across the screen then removes from the screen afterwards
        let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
        
        // start the target moving, then add it to our game scene
        target.run(sequence)
        addChild(target)
        
        levelUp()
    }
    
    func levelUp() {
        // make the game slightly harder
        targetSpeed *= 0.99
        targetDelay *= 0.99
        
        // update our target counter
        targetsCreated += 1
        
        if targetsCreated < 100 {
            // schedule another target to be created after `targetDelay` seconds have passed
            
            DispatchQueue.main.asyncAfter(deadline: .now() + targetDelay) { [unowned self] in
                self.createTarget()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                self.gameOver()
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if isGameOver {
            if let newGame = SKScene(fileNamed: "GameScene") {
                let transition = SKTransition.doorway(withDuration: 1)
                view?.presentScene(newGame, transition: transition)
                // 기존 Scene은 removeFromParent되고 deinit 된다.
            }
        } else {
            if bulletsInClip > 0 {
                run(SKAction.playSoundFileNamed("shot.wav", waitForCompletion: false))
                bulletsInClip -= 1
                
                let location = event.location(in: self)
                shot(at: location)
            } else {
                run(SKAction.playSoundFileNamed("empty.wav", waitForCompletion: false))
            }
        }
    }
    
    func shot(at location: CGPoint) {
        let hitNodes = nodes(at: location).filter { $0.name == "target" }
        
        guard let hitNode = hitNodes.first else { return }
        guard let parentNode = hitNode.parent as? Target else { return }
        
        parentNode.hit()
        
        score += 3
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        if event.charactersIgnoringModifiers == " " {
            run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
            bulletsInClip = 3
            score -= 1
        }
    }
    
    func gameOver() {
        isGameOver = true
        
        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.position = CGPoint(x: 400, y: 300)
        gameOverTitle.setScale(2)
        gameOverTitle.alpha = 0
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 1, duration: 0.3)
        let group = SKAction.group([fadeIn, scaleDown])
        
        gameOverTitle.run(group)
        gameOverTitle.zPosition = 900
        addChild(gameOverTitle)
    }
}
