//
//  GameScene.swift
//  Flappy bird
//
//  Created by Alexander Podkopaev on 27.11.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var groundNode = SKNode()
    
    let birdGroup:UInt32 = 1
    let objGroup:UInt32 = 2
    let gapGroup:UInt32 = 0 << 3
    
    var gameOver = false
    
    var nodeGroup = SKNode()
 
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        
        self.addChild(nodeGroup)
        
        var birdTexture = SKTexture(imageNamed: "flappy1.png")
        var birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        var animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        var makeBirdFlap = SKAction.repeatActionForever(animation)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 50)
        scoreLabel.zPosition = 6
        self.addChild(scoreLabel)
        
        makeBG()
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        bird.runAction(makeBirdFlap)
    
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
    

        bird.zPosition = 5
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = objGroup
        bird.physicsBody?.contactTestBitMask = objGroup
        bird.physicsBody?.collisionBitMask = gapGroup
        self.addChild(bird)
        
        groundNode.position = CGPointMake(0, 0)
        groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        groundNode.physicsBody?.dynamic = false
        groundNode.physicsBody?.categoryBitMask = objGroup
        self.addChild(groundNode)
        
        var spawner = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("one"), userInfo: nil, repeats: true)
        
    }
    
    func one() {
        
        if !gameOver {
        
        var pipeUpTexture = SKTexture(imageNamed: "pipe1")
        var pipeLowerTexture = SKTexture(imageNamed: "pipe2")
        
        var removePipes = SKAction.removeFromParent()
        
        var pipeMove = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        
        let gaoHeight = bird.size.height * 4
        
        var pipeMoveAndRemove = SKAction.sequence([pipeMove, removePipes])
        
        var movementAmound = arc4random() % UInt32(self.frame.size.height / 2)
        
        var pipeOffset = CGFloat(movementAmound) - self.frame.size.height / 4
        
        var upperPipe = SKSpriteNode(texture: pipeUpTexture)
        var lowerPipe = SKSpriteNode(texture: pipeLowerTexture)
        upperPipe.position = CGPoint(x:CGRectGetMidX(self.frame) + self.frame.size.width, y:CGRectGetMidY(self.frame) + upperPipe.size.height / 2 + gaoHeight / 2 + pipeOffset)
        lowerPipe.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - lowerPipe.size.height / 2 - gaoHeight / 2 + pipeOffset)
        upperPipe.runAction(pipeMoveAndRemove)
        lowerPipe.runAction(pipeMoveAndRemove)
        
        upperPipe.physicsBody = SKPhysicsBody(rectangleOfSize: upperPipe.size)
        upperPipe.physicsBody?.dynamic = false
        
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOfSize: lowerPipe.size)
        lowerPipe.physicsBody?.dynamic = false
        
        upperPipe.physicsBody?.categoryBitMask = objGroup
        lowerPipe.physicsBody?.categoryBitMask = objGroup
        
        nodeGroup.addChild(upperPipe)
        nodeGroup.addChild(lowerPipe)
            
            var gap = SKNode()
            gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(upperPipe.size.width, gaoHeight))
            gap.physicsBody?.dynamic = false
            gap.runAction(pipeMoveAndRemove)
            gap.physicsBody?.categoryBitMask = gapGroup
            gap.physicsBody?.collisionBitMask = gapGroup
            gap.physicsBody?.contactTestBitMask = birdGroup
            nodeGroup.addChild(gap)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup && contact.bodyB.categoryBitMask == birdGroup {
            score++
            scoreLabel.text = "\(score)"
        } else {
            if !gameOver {
            gameOver = true
            nodeGroup.speed = 0
            bird.physicsBody?.allowsRotation = true
            bird.physicsBody?.angularVelocity = 2
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game over! Tap to play again!"
            gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            gameOverLabel.zPosition = 7
            self.addChild(gameOverLabel)
            }
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if !gameOver {
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else  {
            score = 0
            scoreLabel.text = "0"
            nodeGroup.removeAllChildren()
            makeBG()
            bird.physicsBody?.allowsRotation = false
            bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.angularVelocity = 0
            bird.zRotation = 0
            nodeGroup.speed = 1
            gameOverLabel.removeFromParent()
            gameOver = false
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func makeBG() {
        var bgTexture = SKTexture(imageNamed: "bg.png")
        var moveBG = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        var replaceBG = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        var replaceBGForever = SKAction.repeatActionForever(SKAction.sequence([moveBG, replaceBG]))
        
        for var i = 0; i<3; i++ {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2.0 + bgTexture.size().width * CGFloat(i), y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            bg.size.width = self.frame.width
            
            bg.runAction(replaceBGForever)
            
            nodeGroup.addChild(bg)
        }

    }
}
