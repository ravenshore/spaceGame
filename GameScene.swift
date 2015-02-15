//
//  GameScene.swift
//  Space Game
//
//  Created by Razvigor Andreev on 2/2/15.
//  Copyright (c) 2015 Razvigor Andreev. All rights reserved.
//

import SpriteKit
import AVFoundation
import CoreMotion
import GameKit



var backgroundMusicPlayer: AVAudioPlayer!
var audioPlayer: AVAudioPlayer!
var score = 0

func documentsDirectory() -> String {
    let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
    return documentsFolderPath
}
// Get path for a file in the directory

func fileInDocumentsDirectory(filename: String) -> String {
    return documentsDirectory().stringByAppendingPathComponent(filename)
}

let scoreSavePath = fileInDocumentsDirectory("highScore.txt")

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerShip: SKSpriteNode!
    var playerShipTop: SKSpriteNode!
    var playerShipSpeed: CGFloat = 500
    var asteroidLayer: SKNode!
    var engine: SKEmitterNode!
    var smoke: SKEmitterNode!
    var stars: SKEmitterNode!
    var stars2: SKEmitterNode!
    var slow: SKEmitterNode!
    let bottom = SKNode()
    
    var asteroidsPerSecond: CGFloat!
    var asteroidInterval: NSTimeInterval!
    var asteroidInterval2: NSTimeInterval!
    
    var border: SKNode!
    var borderBody: SKPhysicsBody!
    
    // accelerometer stuff
    let motionManager: CMMotionManager = CMMotionManager()
    
    
    //switch
    
    var tiltSwitch: UISwitch!
    var pauseSwitch: UISwitch!
    var pauseLabel: UILabel!
    
    
    
    let tryAgain = SKSpriteNode(imageNamed: tryAgainButton)
    let returnToMenu = SKSpriteNode(imageNamed: returnToMenuButton)
    
    
    let iss = SKSpriteNode(imageNamed: paralaxObj1)
    
    
    
    
    
    let colorBlend:CGFloat = 0.1
    var gravityVar: CGFloat!
    
    var gamePaused: Bool = false
    var slowTrue: Bool = false
    var slowTime: Bool = false
    var justHit: Bool = false
    var tiltOn: Bool = false
    var rockets: Bool = true
    var gameIsOver: Bool = false
    
    
    
    
    // hit
    
    
    var hits: Int = 0
    var savedHighScore: Int!
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    
    
    override func didMoveToView(view: SKView) {
        
        
        
        //play music
        playMusic("techno1.mp3", loops: -1)
        
        // World Settings
        physicsWorld.contactDelegate = self
        gravityVar = 0.2
        self.physicsWorld.gravity = CGVectorMake(0.0, -(gravityVar))
        
        callISS()
        setupShip()
        
        delay(2) {
            self.createBorder()
        }
        
        
        
        setupMain()
        motionManager.startAccelerometerUpdates()
        
        // Create the Bottom
        let bottomRect = CGRectMake(frame.origin.x, frame.origin.y , frame.size.width, 1)
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        
        addChild(bottom)
        
        var background = SKSpriteNode(imageNamed: "GalaxyBackground")
        background.position = CGPoint(x: screenW / 2, y: screenH / 2)
        background.zPosition = 1
        addChild(background)
        
        
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        bottom.physicsBody?.contactTestBitMask = asteroidCategory
        
        
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 4
        addChild(asteroidLayer)
        
        
        setupLabels()
        spawnAsteroids()
        loadHighScore()
        showHud()
        
    }
    
    func createBorder() {
        
        
        // 1. Create a physics body that borders the screen
        //        borderBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: ScreenW / 2, y: ((ScreenH / 2) - 100), width: ScreenW, height: ScreenH))
        borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.categoryBitMask = borderCategory
        borderBody.contactTestBitMask = shipCategory
        borderBody.collisionBitMask = shipCategory
        // 2. Set the friction of that physicsBody to 0
        borderBody.friction = 0
        borderBody.affectedByGravity = false
        
        // 3. Set physicsBody of scene to borderBody
        border = SKNode()
        border.frame == self.frame
        
        border.physicsBody = borderBody
        border.physicsBody?.dynamic = false
        border.position = CGPoint(x: 0, y: 0)
        border.zPosition = 12
        addChild(border)
        
        
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if let touch = touches.anyObject() as UITouch? {
            
            let location = touch.locationInNode(self)
            
            if tryAgain .containsPoint(location) && gameIsOver == true {
                
                tryAgainPressed()
                
            }
            
            
            
            
            
            
            
            if gamePaused == false && tiltOn == false {
                
                
                var distanceX = location.x - playerShip.position.x
                var distanceY = location.y - playerShip.position.y
                let newLocation = CGPoint(x: location.x, y: location.y + 50)
                
                let distance = CGFloat(sqrt(distanceX*distanceX + distanceY*distanceY))
                let speed: CGFloat = playerShipSpeed
                let duration: NSTimeInterval = timeToTravelDistance(distance, speed: speed)
                
                
                let move = SKAction.moveTo(newLocation, duration: duration)
                move.timingMode = SKActionTimingMode.EaseInEaseOut
                engine.particleBirthRate = 400
                engine.particlePositionRange.dy = 50
                playerShip.runAction(move)
                
                
                
            }
            
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if let touch = touches.anyObject() as UITouch? {
            let location = touch.locationInNode(self)
            
            if gamePaused == false && tiltOn == false {
                
                var distanceX = location.x - playerShip.position.x
                var distanceY = location.y - playerShip.position.y
                let newLocation = CGPoint(x: location.x, y: location.y + 50)
                
                let distance = CGFloat(sqrt(distanceX*distanceX + distanceY*distanceY))
                let speed: CGFloat = playerShipSpeed
                let duration: NSTimeInterval = timeToTravelDistance(distance, speed: speed)
                
                
                let move = SKAction.moveTo(newLocation, duration: duration)
                move.timingMode = SKActionTimingMode.Linear
                engine.particleBirthRate = 400
                engine.particlePositionRange.dy = 50
                
                
                
                
                playerShip.runAction(move)
            }
            
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        delay(0.6, closure: { () -> () in
            
            self.engine.particleBirthRate = 80
            self.engine.particlePositionRange.dy = 15
            
        })
        
        
        
    }
    
    
    func createAsteroid() -> SKSpriteNode {
        
        var asteroid: SKSpriteNode!
        let asteroidTextureDraw = Int(randomBetweenNumbers(1, secondNum: 3))
        
        if asteroidTextureDraw == 1 {
            asteroid = SKSpriteNode(imageNamed: "Asteroid2")
        } else {
            
            asteroid = SKSpriteNode(imageNamed: "Asteroid1")
            
        }
        
        
        // random position
        
        
        let randomX = arc4random_uniform(UInt32(frame.size.width))
        let randomY = arc4random_uniform(UInt32(frame.size.height))
        
        asteroid.position.x = CGFloat(randomX)
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        //scale
        
        let scale = randomBetweenNumbers(0.1, secondNum: 0.4)
        let mass = (randomBetweenNumbers(0.005, secondNum: 0.04)) * scale * 10
        asteroid.xScale = scale
        asteroid.yScale = scale
        
        //add physics after any changes ot images etc.
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture, size: asteroid.size)
        asteroid.physicsBody?.mass = mass
        
        // Collision
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory  // asteroid
        asteroid.physicsBody?.collisionBitMask = shipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = shipCategory | bottomCategory
        
        
        asteroid.name  = "asteroid"
        asteroid.zPosition = 8
        
        
        // random offset
        var direction: CGFloat!
        
        if asteroid.position.x < frame.width / 2 {
            direction = CGFloat(drand48() * 1)
        }
        
        if asteroid.position.x >= frame.width / 2 {
            direction = CGFloat(drand48() * -1)
        }
        
        var maxSpeed: CGFloat = 200
        var xSpeed = direction * maxSpeed
        asteroid.physicsBody?.velocity.dx = xSpeed
        asteroid.physicsBody?.allowsRotation = false
        
        
        var pi = CGFloat(M_PI)
        //        asteroid.physicsBody?.angularVelocity = 2 * pi * direction * mass
        
        
        return asteroid
        
        
    }
    
    
    func createAsteroidRed() -> SKSpriteNode {
        
        var asteroid: SKSpriteNode!
        let asteroidTextureDraw = Int(randomBetweenNumbers(1, secondNum: 3))
        
        if asteroidTextureDraw == 1 {
            asteroid = SKSpriteNode(imageNamed: "Asteroid2")
        } else {
            
            asteroid = SKSpriteNode(imageNamed: "Asteroid1")
            
        }
        
        
        // random position
        
        
        let randomX = arc4random_uniform(UInt32(frame.size.width))
        let randomY = arc4random_uniform(UInt32(frame.size.height))
        
        asteroid.position.x = CGFloat(randomX)
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        //scale
        
        let scale = CGFloat(0.2)
        let mass = (randomBetweenNumbers(3, secondNum: 9)) * scale * 15
        asteroid.xScale = scale
        asteroid.yScale = scale
        
        //add physics after any changes ot images etc.
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture, size: asteroid.size)
        asteroid.physicsBody?.mass = mass
        
        // Collision
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory2  // asteroidRed
        asteroid.physicsBody?.collisionBitMask = shipCategory | asteroidCategory2
        asteroid.physicsBody?.contactTestBitMask = shipCategory | bottomCategory
        
        
        asteroid.name  = "asteroid"
        asteroid.zPosition = 8
        
        
        // random offset
        var direction: CGFloat!
        
        if asteroid.position.x < frame.width / 2 {
            direction = CGFloat(drand48() * 1)
        }
        
        if asteroid.position.x >= frame.width / 2 {
            direction = CGFloat(drand48() * -1)
        }
        
        var maxSpeed: CGFloat = 200
        var xSpeed = direction * maxSpeed
        asteroid.physicsBody?.velocity.dx = xSpeed
        asteroid.physicsBody?.allowsRotation = false
        asteroid.color = SKColor(red: 0.9, green: 0.2, blue: 0.3, alpha: 0.9)
        asteroid.colorBlendFactor = 1.0
        
        
        var pi = CGFloat(M_PI)
        //        asteroid.physicsBody?.angularVelocity = 0.3 * pi * direction * (mass / 10)
        
        
        return asteroid
        
        
    }
    
    
    func createAsteroidBlue() -> SKSpriteNode {
        
        var asteroid: SKSpriteNode!
        let asteroidTextureDraw = Int(randomBetweenNumbers(1, secondNum: 3))
        
        if asteroidTextureDraw == 1 {
            asteroid = SKSpriteNode(imageNamed: "Asteroid2")
        } else {
            
            asteroid = SKSpriteNode(imageNamed: "Asteroid1")
            
        }
        
        
        // random position
        
        
        let randomX = arc4random_uniform(UInt32(frame.size.width))
        let randomY = arc4random_uniform(UInt32(frame.size.height))
        
        asteroid.position.x = CGFloat(randomX)
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        //scale
        
        let scale = CGFloat(0.2)
        let mass = (randomBetweenNumbers(3, secondNum: 9)) * scale * 15
        asteroid.xScale = scale
        asteroid.yScale = scale
        
        //add physics after any changes ot images etc.
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture, size: asteroid.size)
        asteroid.physicsBody?.mass = mass
        
        // Collision
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory3  // asteroidRed
        asteroid.physicsBody?.collisionBitMask = shipCategory | asteroidCategory3
        asteroid.physicsBody?.contactTestBitMask = shipCategory | bottomCategory
        
        
        asteroid.name  = "asteroid"
        asteroid.zPosition = 8
        
        
        // random offset
        var direction: CGFloat!
        
        if asteroid.position.x < frame.width / 2 {
            direction = CGFloat(drand48() * 1)
        }
        
        if asteroid.position.x >= frame.width / 2 {
            direction = CGFloat(drand48() * -1)
        }
        
        var maxSpeed: CGFloat = 200
        var xSpeed = direction * maxSpeed
        asteroid.physicsBody?.velocity.dx = xSpeed
        asteroid.physicsBody?.allowsRotation = false
        asteroid.color = SKColor(red: 0.1, green: 0.2, blue: 0.9, alpha: 0.9)
        asteroid.colorBlendFactor = 1.0
        
        
        var pi = CGFloat(M_PI)
        //        asteroid.physicsBody?.angularVelocity = 0.3 * pi * direction * (mass / 10)
        
        
        return asteroid
        
        
    }
    
    
    
    
    override func update(currentTime: NSTimeInterval) {
        
        if gamePaused == false && tiltOn == true {
            accelerate()
        }
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func randomIntBetweenNumbers(firstNum: Int, secondNum: Int) -> Int{
        return Int(arc4random()) / Int(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> NSTimeInterval {
        
        let time = distance / speed
        
        return NSTimeInterval(time)
    }
    
    override func didSimulatePhysics() {
        
        // any asteroids off the screen ?
        
        asteroidLayer.enumerateChildNodesWithName("asteroid", usingBlock: { asteroid, stop in
            
            if asteroid.position.y < 0 {
                
                asteroid.removeFromParent()
                //                                println("asteroid removed")
            }
        })
        
        self.enumerateChildNodesWithName("rocket", usingBlock: { rocket, stop in
            
            if rocket.position.y > (screenH + 100) {
                
                rocket.removeFromParent()
                println("rocket removed")
            }
        })
        
        
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        //        println("collision")
        
        if contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == shipCategory ||
            contact.bodyB.categoryBitMask == asteroidCategory && contact.bodyA.categoryBitMask == shipCategory {
                
                var asteroidBody: SKPhysicsBody!
                // do stuff
                if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
                    
                    //body A is the Asteroid
                    asteroidBody = contact.bodyA
                    asteroidBody.node?.removeFromParent()
                    
                    
                } else {
                    asteroidBody = contact.bodyB
                    asteroidBody.node?.removeFromParent()
                }
                
                
                playAudio("jump.wav", loops: 0)
                if justHit == false {            // we haven't been hit
                    hits++
                    println(hits)
                    if hits <= 2 {
                    }
                    justHit = true   // now we have
                    
                    
                    delay(0.5, closure: { () -> () in
                        
                        self.justHit = false
                    })
                    smoke.particleAlpha += 0.3
                    smoke.particleAlphaRange += 0.3
                    colorBlend == 0.8
                }
                
                if hits >= 3 {
                    //game over
                    gameOver()
                }
        }
        
        if contact.bodyA.categoryBitMask == asteroidCategory2 && contact.bodyB.categoryBitMask == shipCategory && slowTrue == false ||
            contact.bodyB.categoryBitMask == asteroidCategory2 && contact.bodyA.categoryBitMask == shipCategory && slowTrue == false {
                
                var asteroidBody: SKPhysicsBody!
                let contactVector = contact.contactNormal
                let contactImpulse = contact.collisionImpulse
                //                playerShip.physicsBody?.applyImpulse(CGVector(dx: -contactVector.dx, dy: -contactVector.dy))
                
                // do stuff
                if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
                    
                    //body A is the Asteroid
                    asteroidBody = contact.bodyA
                    asteroidBody.node?.removeFromParent()
                    
                    
                } else {
                    //body B is the Asteroid
                    asteroidBody = contact.bodyB
                    asteroidBody.node?.removeFromParent()
                }
                
                
                playAudio("jump.wav", loops: 0)
                playerShipSpeed = 150
                
                
                slow = SKEmitterNode(fileNamed: "slow.sks")
                slow.position = CGPoint(x: 0, y: 0)
                slow.name = "slow"
                slow.zPosition = 1
                
                playerShip.addChild(slow)
                playerShipTop.color = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
                playerShipTop.colorBlendFactor = 0.8
                slowTrue = true
                delay(3, closure: { () -> () in
                    
                    self.playerShipSpeed = 500
                    self.slow.removeFromParent()
                    self.playerShipTop.colorBlendFactor = 0.2
                    self.slowTrue = false
                    
                })
                
                
                
                
        }
        
        if contact.bodyA.categoryBitMask == asteroidCategory3 && contact.bodyB.categoryBitMask == shipCategory && slowTime == false ||
            contact.bodyB.categoryBitMask == asteroidCategory3 && contact.bodyA.categoryBitMask == shipCategory && slowTime == false {
                
                
                var asteroidBody: SKPhysicsBody!
                let contactVector = contact.contactNormal
                let contactImpulse = contact.collisionImpulse
                //                playerShip.physicsBody?.applyImpulse(CGVector(dx: -contactVector.dx, dy: -contactVector.dy))
                
                // do stuff
                if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
                    
                    //body A is the Asteroid
                    asteroidBody = contact.bodyA
                    asteroidBody.node?.removeFromParent()
                    
                    
                } else {
                    asteroidBody = contact.bodyB
                    asteroidBody.node?.removeFromParent()
                }
                
                
                playAudio("jump.wav", loops: 0)
                physicsWorld.gravity = CGVectorMake(0.0, -(0.1))
                
                playerShipTop.color = SKColor(red: 0.2, green: 0.2, blue: 0.9, alpha: 1.0)
                playerShipTop.colorBlendFactor = 0.8
                slowTime = true
                rockets = true
                
                delay(3, closure: { () -> () in
                    
                    self.gravityVar = ((CGFloat(score) / 30) + 0.2)
                    self.physicsWorld.gravity = CGVectorMake(0.0, -(self.gravityVar))
                    self.playerShipTop.colorBlendFactor = 0.2
                    self.slowTime = false
                })
                
                
                
                
        }
        
        if contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == bottomCategory ||
            contact.bodyB.categoryBitMask == asteroidCategory && contact.bodyA.categoryBitMask == bottomCategory {
                
                var asteroid: SKPhysicsBody!
                if contact.bodyA.categoryBitMask == asteroidCategory {
                    asteroid = contact.bodyA
                    
                } else {
                    
                    asteroid = contact.bodyB
                }
                asteroid.categoryBitMask = asteroidCategory3
                scored()
                
        }
        
        if contact.bodyA.categoryBitMask == asteroidCategory3 && contact.bodyB.categoryBitMask == shipCategory && slowTime == false ||
            contact.bodyB.categoryBitMask == asteroidCategory3 && contact.bodyA.categoryBitMask == shipCategory && slowTime == false {
                
                
                var asteroidBody: SKPhysicsBody!
                let contactVector = contact.contactNormal
                let contactImpulse = contact.collisionImpulse
                //                playerShip.physicsBody?.applyImpulse(CGVector(dx: -contactVector.dx, dy: -contactVector.dy))
                
                // do stuff
                if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
                    
                    //body A is the Asteroid
                    asteroidBody = contact.bodyA
                    asteroidBody.node?.removeFromParent()
                    
                    
                } else {
                    asteroidBody = contact.bodyB
                    asteroidBody.node?.removeFromParent()
                }
                
                
                playAudio("jump.wav", loops: 0)
                physicsWorld.gravity = CGVectorMake(0.0, -(0.1))
                
                playerShipTop.color = SKColor(red: 0.2, green: 0.2, blue: 0.9, alpha: 1.0)
                playerShipTop.colorBlendFactor = 0.8
                slowTime = true
                delay(3, closure: { () -> () in
                    
                    self.gravityVar = ((CGFloat(score) / 30) + 0.2)
                    self.physicsWorld.gravity = CGVectorMake(0.0, -(self.gravityVar))
                    self.playerShipTop.colorBlendFactor = 0.2
                    self.slowTime = false
                })
                
                
                
                
        }
        
        
        
        
        if contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == rocketCategory ||
            contact.bodyB.categoryBitMask == asteroidCategory && contact.bodyA.categoryBitMask == rocketCategory ||
            contact.bodyA.categoryBitMask == asteroidCategory2 && contact.bodyB.categoryBitMask == rocketCategory ||
            contact.bodyB.categoryBitMask == asteroidCategory2 && contact.bodyA.categoryBitMask == rocketCategory ||
            contact.bodyA.categoryBitMask == asteroidCategory3 && contact.bodyB.categoryBitMask == rocketCategory ||
            contact.bodyB.categoryBitMask == asteroidCategory3 && contact.bodyA.categoryBitMask == rocketCategory
            
        {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            var explosion: SKEmitterNode!
            //generate emmitter
            explosion = SKEmitterNode(fileNamed: "explosion")
            explosion.position = contact.contactPoint
            explosion.name = "rocketFlare"
            explosion.xScale = 0.3
            explosion.yScale = 0.3
            explosion.zPosition = 8
            addChild(explosion)
            delay(0.7) {
                explosion.removeFromParent()
            }
            
            scored()
        }
        
        
        if contact.bodyA.categoryBitMask == shipCategory && contact.bodyB.categoryBitMask == borderCategory ||
            contact.bodyB.categoryBitMask == borderCategory && contact.bodyA.categoryBitMask == shipCategory {
                
                println("border hit")
        }
        
    }
    
    
    func didEndContact(contact: SKPhysicsContact) {
        
        
        
    }
    
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
        
        
    }
    
    func setupShip() {
        
        playerShip = SKSpriteNode(imageNamed: "PlayerShip1")
        playerShip.position = CGPoint(x: screenW / 2, y: -10)
        
        
        
        let path = CGPathCreateMutable()
        let startY = self.frame.origin.y - 30
        let endY = self.frame.origin.y + 100
        CGPathMoveToPoint(path, nil, 0, startY)
        CGPathAddLineToPoint(path, nil, 0, endY)
        
        
        //    SKAction *followline = [SKAction followPath:path asOffset:YES orientToPath:NO duration:3.0];
        let followLine = SKAction.followPath(path, asOffset: true, orientToPath: false, duration: 3.0)
        
        playerShip.runAction(followLine)
        UIView.animateWithDuration(1.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: nil, animations: {
            
            }, completion: nil)
        
        
        
        playerShipTop = SKSpriteNode(imageNamed: "PlayerShip1")
        playerShipTop.position = CGPoint(x: 0, y: 0)
        playerShipTop.zPosition = 2
        playerShipTop.color = SKColor(red: 0.9, green: 0.2, blue: 0.4, alpha: 1.0)
        playerShipTop.colorBlendFactor = colorBlend
        
        var colorAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 0.55, duration: 2)
        var colorAction2 = SKAction.colorizeWithColor(SKColor.whiteColor(), colorBlendFactor: 0.3, duration: 2)
        var colorActionSequence = SKAction.sequence([colorAction, colorAction2])
        var colorAnimation = SKAction.repeatActionForever(colorActionSequence)
        playerShipTop.runAction(colorAnimation)
        
        playerShip.physicsBody = SKPhysicsBody(texture: playerShip.texture, size: playerShip.size)
        playerShip.physicsBody?.dynamic = true
        playerShip.physicsBody?.affectedByGravity = false
        playerShip.physicsBody?.allowsRotation = false
        playerShip.physicsBody?.mass = 0.2
        playerShip.xScale = 0.5
        playerShip.yScale = 0.5
        playerShip.zPosition = 5
        
        
        // Collision Rules
        playerShip.physicsBody?.categoryBitMask = shipCategory  // ship
        playerShip.physicsBody?.collisionBitMask = asteroidCategory | borderCategory
        playerShip.physicsBody?.contactTestBitMask = asteroidCategory | borderCategory
        
        
        //generate emmitter
        engine = SKEmitterNode(fileNamed: "fire.sks")
        engine.position = CGPoint(x: 0, y: -10)
        engine.name = "engine"
        engine.zPosition = 1
        
        smoke = SKEmitterNode(fileNamed: "smoke.sks")
        smoke.position = CGPoint(x: -10, y: -10)
        smoke.name = "smoke"
        smoke.particleAlpha = 0
        smoke.particleAlphaRange = 0
        smoke.zPosition = 1
        
        playerShip.addChild(engine)
        playerShip.addChild(playerShipTop)
        playerShip.addChild(smoke)
        
        addChild(playerShip)
        
        
    }
    
    func setupMain() {
        
        // Setup Ship
        
        
        asteroidsPerSecond = 1 + CGFloat(score / 50)
        asteroidInterval = NSTimeInterval(1 / asteroidsPerSecond)
        asteroidInterval2 = NSTimeInterval(3 / asteroidsPerSecond)
        
        
        
        stars = SKEmitterNode(fileNamed: "stars.sks")
        stars.position = CGPoint(x: screenW / 2, y: screenH / 2)
        stars.name = "stars"
        stars.zPosition = 1
        
        stars2 = SKEmitterNode(fileNamed: "stars2.sks")
        stars2.position = CGPoint(x: screenW / 2, y: screenH)
        stars2.name = "stars2"
        stars2.zPosition = 1
        
        
        
        
        addChild(stars)
        addChild(stars2)
        
    }
    
    
    
    func saveText(text: String, path: String) -> Bool {
        var error: NSError? = nil
        let status = text.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        if !status { //status == false {
            println("Error saving file at path: \(path) with error: \(error?.localizedDescription)")
        }
        return status
    }
    
    
    
    
    
    // Load text
    
    func loadTextFromPath(path: String) -> String? {
        var error: NSError? = nil
        let text = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: &error)
        if text == nil {
            println("Error loading text from path: \(path) error: \(error?.localizedDescription)")
        }
        return text
    }
    
    
    func loadHighScore() {
        
        if let savedHighScore = loadTextFromPath(scoreSavePath) {
            highScoreLabel.text = ("High Score: \(savedHighScore)")
            println("\(savedHighScore)")
        }
        
    }
    
    func saveHighScore() {
        println("Trying to save current High Score of: \(score)")
        //        let currentScore = scoreLabel.text
        if let savedHighScore = loadTextFromPath(scoreSavePath) {
            if score > savedHighScore.toInt()  {
                println("Our score of: \(score) is bigger than the saved HS of: \(savedHighScore)")
                saveText("\(score)", path: scoreSavePath )
            }
        } else {
            
            saveText("\(score)", path: scoreSavePath )
        }
    }
    
    func reset() {
        
        gamePaused = false
        score = 0
        hits = 0
        asteroidsPerSecond = 1 + CGFloat(score / 50)
        asteroidInterval = NSTimeInterval(1 / asteroidsPerSecond)
        asteroidInterval2 = NSTimeInterval(3 / asteroidsPerSecond)
        self.scoreLabel.text = "Score: \(score)"
        
        gravityVar = 0.2
        smoke.particleAlpha = 0
        smoke.particleAlphaRange = 0
        colorBlend == 0.1
        playerShip.removeFromParent()
        asteroidLayer.removeFromParent()
        stars.removeFromParent()
        stars2.removeFromParent()
        engine.removeFromParent()
        smoke.removeFromParent()
        iss.removeFromParent()
        self.addChild(asteroidLayer)
        loadHighScore()
        clearUpAsteroids()
        border.removeFromParent()
        //        callISS()
        //        setupShip()
        //        delay(2) {
        //            self.createBorder()
        //        }
        
        
    }
    
    func pauseGame() {
        
        
        asteroidLayer.paused = true
        physicsWorld.speed = 0
        //        pauseButton.text = "RESUME"
        //        pauseButtonSprite.texture = SKTexture(imageNamed: "resume")
        pauseLabel.text = "Resume"
        gamePaused = true
        println("pause")
    }
    
    
    func unPauseGame() {
        
        
        asteroidLayer.paused = false
        physicsWorld.speed = 1
        //        pauseButton.text = "PAUSE"
        //        pauseButtonSprite.texture = SKTexture(imageNamed: "pause")
        pauseLabel.text = "Pause"
        gamePaused = false
        println("unpause")
        
        
    }
    
    func gameOver() {
        
        reset()
        gameIsOver = true
        playerShip.removeFromParent()
        
        tryAgain.removeFromParent()
        addChild(tryAgain)
        returnToMenu.removeFromParent()
        addChild(returnToMenu)
        
        tryAgain.xScale = 0.7
        tryAgain.yScale = 0.7
        returnToMenu.xScale = 0.7
        returnToMenu.yScale = 0.7
        
        saveHighScore()
        //        reset()
    }
    
    func playMusic(filename: String, loops: Int) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            println("Could not find file: \(filename)")
            return
        }
        var error: NSError? = nil
        
        backgroundMusicPlayer =
            AVAudioPlayer(contentsOfURL: url, error: &error)
        if backgroundMusicPlayer == nil {
            println("Could not create audio player: \(error!)")
            return
        }
        
        backgroundMusicPlayer.numberOfLoops = loops
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
    func playAudio(filename: String, loops: Int) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            println("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        
        audioPlayer =
            AVAudioPlayer(contentsOfURL: url, error: &error)
        if audioPlayer == nil {
            println("Could not create audio player: \(error!)")
            return
        }
        
        audioPlayer.numberOfLoops = loops
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func clearUpAsteroids() {
        
        
        enumerateChildNodesWithName("asteroid", usingBlock: { (asteroid: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            
            asteroid.removeFromParent()
            
        })
        
    }
    
    func setupLabels() {
        
        //setup Labels
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.frame == CGRect(x: 0, y: 0, width: 100, height: 50)
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPoint(x: 120, y: screenH - 40)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(text: "High Score: 0")
        highScoreLabel.frame == CGRect(x: 0, y: 0, width: 100, height: 50)
        highScoreLabel.fontSize = 20
        highScoreLabel.position = CGPoint(x: screenW - 100, y: screenH - 40)
        highScoreLabel.zPosition = 10
        addChild(highScoreLabel)
        
        
        tryAgain.position = CGPoint(x: screenW / 2, y: screenH / 2 + 50)
        tryAgain.zPosition = 10
        
        returnToMenu.position = CGPoint(x: screenW / 2, y: screenH / 2 - 50)
        returnToMenu.zPosition = 10
        
    }
    
    func spawnAsteroids() {
        
        //asteroid actions ( spawn code )
        // run code, wait, repeat sequence
        
        let asteroidCreateAction = SKAction.runBlock { () -> Void in
            
            let asteroid = self.createAsteroid()
            let trace = self.createTraceEmitter(asteroid.size.width * 3, range: asteroid.physicsBody?.angularVelocity)
            let orientationRange = SKRange(lowerLimit: 1, upperLimit: 1)
            let orientConstraint = SKConstraint.orientToNode(self.bottom, offset: orientationRange)
            trace.constraints = [orientConstraint]
            asteroid.addChild(trace)
            self.asteroidLayer.addChild(asteroid)
        }
        
        let asteroidRedCreateAction = SKAction.runBlock { () -> Void in
            
            let asteroid = self.createAsteroidRed()
            let trace = self.createTraceEmitter(asteroid.size.width * 3, range: asteroid.physicsBody?.angularVelocity)
            
            asteroid.addChild(trace)
            self.asteroidLayer.addChild(asteroid)
            
            
        }
        
        let asteroidBlueCreateAction = SKAction.runBlock { () -> Void in
            
            let asteroid = self.createAsteroidBlue()
            let trace = self.createTraceEmitter(asteroid.size.width * 3, range: asteroid.physicsBody?.angularVelocity)
            
            asteroid.addChild(trace)
            self.asteroidLayer.addChild(asteroid)
            
            
        }
        
        
        let asteroidWaitAction = SKAction.waitForDuration(asteroidInterval, withRange: 0.1)
        let asteroidRedWaitAction = SKAction.waitForDuration(15, withRange: 5)
        let asteroidBlueWaitAction = SKAction.waitForDuration(20, withRange: 4)
        
        let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction,asteroidWaitAction])
        let asteroidSequenceAction2 = SKAction.sequence([asteroidRedCreateAction,asteroidRedWaitAction])
        let asteroidSequenceAction3 = SKAction.sequence([asteroidBlueCreateAction,asteroidRedWaitAction])
        
        let asteroidRepeatAction = SKAction.repeatActionForever(asteroidSequenceAction)
        let asteroidRepeatAction2 = SKAction.repeatActionForever(asteroidSequenceAction2)
        let asteroidRepeatAction3 = SKAction.repeatActionForever(asteroidSequenceAction3)
        
        runAction(asteroidRepeatAction)
        runAction(asteroidRepeatAction2)
        runAction(asteroidRepeatAction3)
        
        
    }
    
    func createTraceEmitter(ppX: CGFloat, range: CGFloat?) -> SKEmitterNode {
        
        
        var trace: SKEmitterNode!
        //generate emmitter
        trace = SKEmitterNode(fileNamed: "trace.sks")
        trace.position = CGPoint(x: 0, y: 0)
        trace.name = "trace"
        trace.zPosition = 8
        trace.particlePositionRange.dx = ppX
        if range != nil {
            trace.particleRotationRange = range!
        }
        return trace
    }
    
    func tiltSwitchedGS(sender: AnyObject) {
        
        if tiltOn == false {
            
            tiltOn = true
            
        } else {
            
            tiltOn = false
        }
        
    }
    
    func pauseSwitchedGS(sender: AnyObject) {
        
        
        if gamePaused == false {
            pauseGame()
        } else
            
            if gamePaused == true {
                
                unPauseGame()
        }
    }
    
    func accelerate() {
        
        // 2
        if let data = motionManager.accelerometerData {
            
            if tiltOn == true {
                if (fabs(data.acceleration.x) > 0.2) || (fabs(data.acceleration.y) > 0.2){
                    
                    playerShip.physicsBody!.applyForce(CGVectorMake(350.0 * CGFloat(data.acceleration.x), 350.0 * CGFloat(data.acceleration.y) ))
                }
                
            }
        }
        
    }
    
    
    func callISS() {
        
        iss.position = CGPoint(x: (screenW / 2) - 100, y: -700)
        iss.zPosition = 3
        addChild(iss)
        let path = CGPathCreateMutable()
        let startY = self.frame.origin.y + 2000
        let endY = self.frame.origin.y + -1000
        CGPathMoveToPoint(path, nil, 0, startY)
        CGPathAddLineToPoint(path, nil, 0, endY)
        
        
        //    SKAction *followline = [SKAction followPath:path asOffset:YES orientToPath:NO duration:3.0];
        let followLine = SKAction.followPath(path, asOffset: true, orientToPath: false, duration: 600.0)
        
        iss.runAction(followLine)
        
        
    }
    
    func shoot() {
        
        
        let rocketFired = rocket()
        
        rocketFired.position = CGPoint(x: playerShip.position.x, y: playerShip.position.y + 50)
        rockets = false
        
        
        addChild(rocketFired)
        rocketFired.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        
        
        
    }
    
    func scored() {
        
        score++
        self.scoreLabel.text = "Score: \(score)"
        gravityVar = ((CGFloat(score) / 30) + 0.2)
        self.physicsWorld.gravity = CGVectorMake(0.0, -(gravityVar))
        asteroidsPerSecond = 1 + CGFloat(score / 50)
        asteroidInterval = NSTimeInterval(1 / asteroidsPerSecond)
        asteroidInterval2 = NSTimeInterval(3 / asteroidsPerSecond)
        
        
    }
    
    func shootingRepeater() {
        let shooting = SKAction.runBlock { () -> Void in
            let rocketFired = rocket()
            
            rocketFired.position = CGPoint(x: self.playerShip.position.x, y: self.playerShip.position.y + 50)
            self.addChild(rocketFired)
        rocketFired.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        
    }
    
   let shootingDelay = SKAction.waitForDuration(2)
    let shootingAction = SKAction.sequence(([shooting, shootingDelay]))
    }
    
    func tryAgainPressed() {
        
        self.removeAllChildren()
        gameIsOver = false
        let scene = GameScene.unarchiveFromFile("GameScene") as GameScene
        scene.scaleMode = .AspectFill
        scene.size = UIScreen.mainScreen().bounds.size
        let delay = SKAction.waitForDuration(0.2)
        let transitionToLevel = SKAction.runBlock({
            
            let transition = SKTransition.doorwayWithDuration(0.2)
            
            self.view?.presentScene(scene, transition: transition)
            
        })
        runAction(SKAction.sequence([delay, transitionToLevel]))
        
    }
    
    func showHud() {
        
        let myHud = hud(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        
        self.view?.addSubview(myHud)
        
        
    }

}
