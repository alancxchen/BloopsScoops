//
//  Gameplay.swift
//  Drops
//
//  Created by Alan on 7/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import Mixpanel
enum GameState {
    case GameOver, Playing, Ready, Tutorial, Paused
}

class Gameplay: CCNode, CCPhysicsCollisionDelegate {
    weak var ccPhysicsNode : CCPhysicsNode!
    weak var cone : Cone!
    weak var scoreLabel : CCLabelTTF!
    weak var pauseButton : CCButton!
    weak var startInstructions: CCLabelTTF!
    weak var lifeBar : CCSprite!
    weak var ground : CCSprite!
    weak var ground2 : CCSprite!
    weak var one : CCLabelTTF!
    weak var two : CCLabelTTF!
    weak var three : CCLabelTTF!
    weak var go : CCLabelTTF!
    weak var livesLeft: CCLabelTTF!
    weak var livesNode: CCNodeColor!
    weak var pauseSymbol: CCButton!
    var mixpanel = Mixpanel.sharedInstance()
    
    var beatHighScore = false
    var yScaleValue : CGFloat = 200
    var counter = 0
    var previousCounter = -30
    var duration : CGFloat = 0
    
    var dropHeight : CGFloat = 50
    var dropWidth : CGFloat = 50
    
    
    //less -> more drops
    var frequencyOfDrops = 40
    var frequencyOfApples = 125
    
    var gravity : CGPoint = CGPoint (x: 0, y: 0)
    
    var lastDropPosition = CGPoint(x: 0, y: 0)
    var lastApplePosition = CGPoint (x: 0, y: 0)
    
    var gameState : GameState = .Ready
    var strike1 : CCNode!
    var strike2 : CCNode!
    var strike3 : CCNode!
    
    var pauseMenu : CCNode!
    var isPaused = false
    
    var touchBeginPos : CGPoint!
    var touchEndPos : CGPoint!
    var touchBeginTimestamp : NSTimeInterval!
    var touchEndTimestamp : NSTimeInterval!
    var strikesLoaded = false
    var isInvincible = false
    
    //invincibility variables
    var previousGravity : CGPoint!
    var previousDropFrequency: Int!
    var previousAppleFrequency: Int!
    var particles : CCParticleSystem!
    func didLoadFromCCB() {
        CCDirector.sharedDirector().resume()
        gameState = .Ready
        userInteractionEnabled = true
        
        //Necessary for ccphysicsCollisionDelegate
        ccPhysicsNode.collisionDelegate = self
        ccPhysicsNode.gravity = CGPoint(x: 0, y: -200)
        counter = 15
        //        ccPhysicsNode.gravity = CGPoint(x: 0, y: 0)
    }
    
    override func onEnter() {
        super.onEnter()
        var coneX = self.contentSizeInPoints.width / 2
        cone.position = CGPoint(x: coneX, y: cone.position.y)
    }
    
    func pause() {
        
        if gameState == .Paused {
            pauseButton.visible = false
            pauseSymbol.visible = false
            pauseMenu.animationManager.runAnimationsForSequenceNamed("Exit")
            self.animationManager.runAnimationsForSequenceNamed("321")
            gameState = .Playing
            
            
        } else {
            mixpanel.track("ButtonPressed", properties: ["ButtonType": "Pause"])
            pauseButton.visible = false
            pauseSymbol.visible = false
            gameState = .Paused
            ccPhysicsNode.paused = true
            isPaused = true
            pauseMenu = CCBReader.load("Scenes/PauseMenu", owner: self)
            self.addChild(pauseMenu)
        }
        
    }
    func restart() {
        mixpanel.track("ButtonPressed", properties: ["ButtonType": "Restart"])
        var gamePlayScene = CCBReader.loadAsScene("Scenes/Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
    }
    func menu() {
        mixpanel.track("ButtonPressed", properties: ["ButtonType": "Main Menu"])
        var mainMenu = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(mainMenu)
    }
    func resume() {
        mixpanel.track("ButtonPressed", properties: ["ButtonType": "Resume"])
        ccPhysicsNode.paused = false
        isPaused = false
        //gameState = .Playing
        pauseButton.visible = true
        pauseSymbol.visible = true
    }
    
    var lives : Int = 5 {
        didSet {
            livesLeft.string = "\(lives)"
            if lives == 0 {
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("triggerGameOver"), userInfo: nil, repeats: false)
            }
        }
    }
    
    var score : Int = 0 {
        didSet {
            if score > highScore {
                highScore = score
                beatHighScore = true
                mixpanel.track("GameEvents", properties: ["EventType": "Beat High Score"])
            }
            scoreLabel.string = "\(score)"
            var dropSubtractFrequency = 2
            var appleSubtractFrequency = 2
            let random = CCRANDOM_0_1() * 200
            var gravitySubtractConstant = 40

            if score % 2 == 0 && !isInvincible{
                if ccPhysicsNode.gravity.y < -500 {
                    gravitySubtractConstant = 20
                }
                ccPhysicsNode.gravity.y -= CGFloat(gravitySubtractConstant)
            }
            
        }
    }
    var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("myHighScore") ?? 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey:"myHighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override func update(delta: CCTime) {

        if gameState != .Paused && gameState != .GameOver && !isPaused {
        
           
            if gameState == .Playing {
                if counter % 100 == 0 {
                    if frequencyOfDrops > 27 {
                        frequencyOfDrops -= 1
                    }
                }
                counter++
                duration = duration + CGFloat(delta)
                
                if counter % frequencyOfDrops == 0 && counter - previousCounter > 18 {
                    createDrops()
                    previousCounter = counter
                }
                
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState != .Paused && gameState != .GameOver && !isPaused {
            if gameState == .Ready {
                touchBeginTimestamp = NSDate().timeIntervalSince1970
                gameState = .Playing
                startInstructions.runAction(CCActionFadeOut(duration: 0.4))
                lives = 5
                mixpanel.track("GameEvents", properties: ["EventType": "Started"])
    
                pauseButton.visible = true
                pauseSymbol.visible = true
                
                pauseButton.opacity = 0
                pauseButton.runAction(CCActionFadeIn(duration: 0.3))
            }
            let xPos = touch.locationInWorld().x
            cone.position = CGPoint(x: xPos, y: cone.position.y)
            
            touchBeginPos = touch.locationInWorld()
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState != .Paused && gameState != .GameOver{
            let xPos = touch.locationInWorld().x
        
            cone.position = CGPoint(x: xPos, y: cone.position.y)
    
            if particles != nil {
                particles.position = cone.position
            }
        }
        
    }
    
    
    func spawnPowerUp() {
        let random = Int(CCRANDOM_0_1() * Float(3))
        
        var randX = CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - 50) + 25
        mixpanel.track("ScoopEvents", properties: ["EventType": "PowerupSpawned"])
        if random == 1 {
            let powerup = CCBReader.load("Powerups/minusOneScoop") as! Powerup
            let y = self.contentSizeInPoints.height + 100
            powerup.position = CGPoint(x: randX, y: y)
            
 //           self.addChild(powerup, z: 100, name: "swipePowerup")
            ccPhysicsNode.addChild(powerup)
        }
        if random == 2 {
            let powerup = CCBReader.load("Powerups/invincibilityPowerup") as! Powerup
            powerup.scale = 0.5
            let y = self.contentSizeInPoints.height + 100
            powerup.position = CGPoint(x: randX, y : y)
            ccPhysicsNode.addChild(powerup)
        }
    }
    
    //spawns drops and drops them
    func createDrops() {
        let random = CCRANDOM_0_1() * 100
        // println(random)
        var drop = CCBReader.load("Scoops/BlueScoop")
        
        if random < 100 {
            drop = CCBReader.load("Scoops/MintScoop")
        }
        if random < 92 {
            drop = CCBReader.load("Scoops/PinkScoop")
        }
        if random < 80 {
            drop = CCBReader.load("Scoops/VanillaScoop")
        }
        if random < 64 {
            drop = CCBReader.load("Scoops/ChocolateScoop")
            
        }
        if random < 48 {
            drop = CCBReader.load("Scoops/PurpleScoop")
        }
        if random < 32 {
            drop = CCBReader.load("Scoops/BlueScoop")
        }
        if random < 16 {
            drop = CCBReader.load("Scoops/RedScoop")
        }
        
        //so that the drop isnt on the sides
        var randomX = dropWidth / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - dropWidth)
        while abs(randomX-lastDropPosition.x) > self.contentSizeInPoints.width * 40 / 50 {
            randomX = dropWidth / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - dropWidth)
        }
        let launchDirection = CGPoint(x: 0, y: 1)
        let y = self.contentSizeInPoints.height + 100
        drop.position = CGPoint(x: randomX, y: y)
        lastDropPosition = drop.position
        var rand = CCRANDOM_0_1() * 200
       
        if rand < 5 && score > 15{
            if !isInvincible {
                spawnPowerUp()
            }
        } else {
            ccPhysicsNode.addChild(drop)
            var force = ccpMult(launchDirection, -10000)

            drop.physicsBody.applyForce(force)
        }
    }
    
    func scoopRemoved(scoop: Scoop) {
        scoop.removeFromParent()
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, coneCollision: CCSprite!, scoopCollision: Scoop!) -> Bool {
        //make sure its the right color
        //animate it so that it dissappears only once
        //swift bridging header #import "CCPhysics+ObjectiveChipmunk.h" necessary
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            self.scoopRemoved(scoopCollision)
            self.score++
            }, key: scoopCollision)
        return true
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, coneCollision: CCSprite!, purpleScoopCollision: Scoop!) -> Bool {
        //make sure its the right color
        //animate it so that it dissappears only once
        //swift bridging header #import "CCPhysics+ObjectiveChipmunk.h" necessary
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            self.scoopRemoved(purpleScoopCollision)
            self.score += 3
            }, key: purpleScoopCollision)
        return true
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, scoopCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            if !self.isInvincible {
                self.lives = max(self.lives - 1 , 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            scoopCollision.removeFromParent()
            }, key: scoopCollision)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, invincibilityPowerup: Powerup!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            self.mixpanel.track("ScoopEvents", properties: ["EventType": "MissedPowerup"])
            invincibilityPowerup.removeFromParent()
            
            }, key: invincibilityPowerup)
        
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, invincibilityPowerup: Powerup!, coneCollision: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            print("hit invincible")
            var invinciblecone = CCBReader.load("Cones/invinciblecone", owner: self) as! invincibleCone
            self.ccPhysicsNode.addChild(invinciblecone)
            invinciblecone.position = self.cone.position
            self.cone.removeFromParent()
            self.cone = invinciblecone
            

            invincibilityPowerup.removeFromParent()
            if !self.isInvincible {
                self.invincible()
            }
            }, key: invincibilityPowerup)
        
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, minusOneScoop: Powerup!, coneCollision: CCSprite!) -> Bool{
       // println("HIT")
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
          //  println("YO")
            minusOneScoop.removeFromParent()
            self.animationManager.runAnimationsForSequenceNamed("NewLife")
            self.minusOneX()
            self.mixpanel.track("ScoopEvents", properties: ["EventType": "CaughtMinusOne"])
        }, key: minusOneScoop)
        return true
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, minusOneScoop: Powerup!, ground: CCSprite!) -> Bool {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            minusOneScoop.removeFromParent()
            self.mixpanel.track("ScoopEvents", properties: ["EventType": "MissedMinusOne"])
            }, key: minusOneScoop)
        return true
    }
    
    
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, onePoint: CCNode!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            //animation
            onePoint.removeFromParent()
            if !self.isInvincible {
                self.lives = max(self.lives - 1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            self.mixpanel.track("ScoopEvents", properties: ["EventType": "DroppedOnePoint"])
            }, key: onePoint)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, onePoint: CCNode!, coneCollision: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            
            onePoint.physicsBody.collisionType = ""
            onePoint.physicsBody.type = .Static
            // if it is not exact
            let distance = onePoint.position.x - coneCollision.position.x
            if abs(distance) > 24 && !self.isInvincible {
                self.mixpanel.track("ScoopEvents", properties: ["EventType": "BounceOffOnePoint"])
                if distance < 0 {
                    onePoint.animationManager.runAnimationsForSequenceNamed("bounceOffLeft")
                } else {
                    onePoint.animationManager.runAnimationsForSequenceNamed("bounceOffRight")
                }
            
                self.lives = max(self.lives - 1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            else {
                self.mixpanel.track("ScoopEvents", properties: ["EventType": "CaughtOnePoint"])
                var copy = onePoint
                copy.position = CGPoint(x: 0 , y: 20)
                onePoint.removeFromParent()
                self.cone.addChild(copy)
                
               
                if self.isInvincible {
                    copy.animationManager.runAnimationsForSequenceNamed("plop2")
                    self.score += 2
                } else {
                    copy.animationManager.runAnimationsForSequenceNamed("plop")
                    self.score++
                }
            }
            }, key: onePoint)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, twoPoints: CCNode!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            //animation
            self.mixpanel.track("ScoopEvents", properties: ["EventType": "DroppedOnePoint"])
            
            twoPoints.removeFromParent()
            if !self.isInvincible {
                self.lives = max(self.lives - 1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            }, key: twoPoints)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, twoPoints: CCNode!, coneCollision: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            twoPoints.physicsBody.collisionType = ""
            twoPoints.physicsBody.type = .Static
            // if it is not exact
            let distance = twoPoints.position.x - coneCollision.position.x
            if abs(distance) > 24 && !self.isInvincible {
                self.mixpanel.track("ScoopEvents", properties: ["EventType": "BounceOffTwoPoint"])
                
                if distance < 0 {
                    twoPoints.animationManager.runAnimationsForSequenceNamed("bounceOffLeft")
                } else {
                    twoPoints.animationManager.runAnimationsForSequenceNamed("bounceOffRight")
                }
                self.lives = max(self.lives-1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
                
            }
            else {
                self.mixpanel.track("ScoopEvents", properties: ["EventType": "CaughtTwoPoint"])
                
                var copy = twoPoints
                copy.position = CGPoint(x: 0 , y: 20)
                twoPoints.removeFromParent()
                self.cone.addChild(copy)
                
                if self.isInvincible {
                    copy.animationManager.runAnimationsForSequenceNamed("plop2")
                    self.score += 4
                } else {
                    copy.animationManager.runAnimationsForSequenceNamed("plop")
                    self.score+=2
                }
            }
            }, key: twoPoints)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, threePoints: CCNode!, ground: CCSprite!) {
        
        
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            //animation
            self.mixpanel.track("ScoopEvents", properties: ["EventType": "DroppedThreePoints"])
            
            threePoints.removeFromParent()
            if !self.isInvincible {
                self.lives = max(self.lives-1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            }, key: threePoints)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, threePoints: CCNode!, coneCollision: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            
            threePoints.physicsBody.collisionType = ""
            threePoints.physicsBody.type = .Static
            // if it is not exact
            let distance = threePoints.position.x - coneCollision.position.x
            if abs(distance) > 24 && !self.isInvincible {
                self.mixpanel.track("ScoopEvents", properties: ["EventType": "BounceOffThreePoints"])
                
                if distance < 0 {
                    threePoints.animationManager.runAnimationsForSequenceNamed("bounceOffLeft")
                } else {
                    threePoints.animationManager.runAnimationsForSequenceNamed("bounceOffRight")
                }
                self.lives = max(self.lives-1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            else {
                self.mixpanel.track("ScoopEvents", properties: ["EventType": "CaughtThreePoints"])
                
                var copy = threePoints
                copy.position = CGPoint(x: 0 , y: 20)
                threePoints.removeFromParent()
                self.cone.addChild(copy)
                
                if self.isInvincible {
                    copy.animationManager.runAnimationsForSequenceNamed("plop2")
                    self.score += 5
                } else {
                    copy.animationManager.runAnimationsForSequenceNamed("plop")
                    self.score += 3
                }
            }
            }, key: threePoints)
    }

    func slowDownGravity() {
        ccPhysicsNode.gravity = previousGravity
    }

    func slowDownDrops() {
        frequencyOfDrops = previousDropFrequency + 10
    }
    func changeCone() {
        var originalCone = CCBReader.load("Cones/Cone") as! Cone
        ccPhysicsNode.addChild(originalCone)
        originalCone.position = cone.position
        cone.removeFromParent()
        
        cone = originalCone
        
    }
    func changeInvincible() {
        isInvincible = false
    }
    func speedUpGravity() {
        ccPhysicsNode.gravity.y -= 1000
    }
    func speedUpDrops() {
        frequencyOfDrops = max(20, previousDropFrequency - 20)
    }
    func changeFromInvincible() {
        cone.animationManager.runAnimationsForSequenceNamed("transition")
        var gravityTimer1 = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("slowDownGravity"), userInfo: nil, repeats: false)
        
        var dropTimer1 = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("slowDownDrops"), userInfo: nil, repeats: false)
        
        var timer3 = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("changeInvincible"), userInfo: nil, repeats: false)
        
    }
    func invincible() {
        isInvincible = true
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("changeFromInvincible"), userInfo: nil, repeats: false)
        var timer3 = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("speedUpGravity"), userInfo: nil, repeats: false)
        var dropTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("speedUpDrops"), userInfo: nil, repeats: false)
        previousGravity = ccPhysicsNode.gravity
        previousDropFrequency = frequencyOfDrops
        previousAppleFrequency = frequencyOfApples
    }
    
    func minusOneX() {
        lives = lives + 1
    }
    
    func triggerGameOver() {
        gameState = .GameOver
        // give the game over menu
//        strike1.removeFromParent()
//        strike2.removeFromParent()
//        strike3.removeFromParent()
        pauseButton.visible = false
        pauseSymbol.visible = false
        scoreLabel.visible = false
        ccPhysicsNode.paused = true
        cone.visible = false
        livesNode.visible = false
        
        var gameOverScene = CCBReader.load("Scenes/GameOver") as! GameOver
        gameOverScene.beatHighScore = beatHighScore
        gameOverScene.score = score
        gameOverScene.highScore = highScore
        mixpanel.track("GameEvents", properties: ["EventType": "GameOver"])
        
        self.addChild(gameOverScene)
        
    }
    
}

