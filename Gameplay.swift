//
//  Gameplay.swift
//  Drops
//
//  Created by Alan on 7/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

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
        counter = 0
        //        ccPhysicsNode.gravity = CGPoint(x: 0, y: 0)
    }
    
    override func onEnter() {
        super.onEnter()
        var coneX = self.contentSizeInPoints.width / 2
        cone.position = CGPoint(x: coneX, y: cone.position.y)
    }
    
    func pause() {
        //println("yo")
        
        if gameState == .Paused {
            pauseButton.visible = false
            pauseMenu.animationManager.runAnimationsForSequenceNamed("Exit")
            self.animationManager.runAnimationsForSequenceNamed("321")
            gameState = .Playing
            
            
        } else {
            pauseButton.visible = false
            gameState = .Paused
            ccPhysicsNode.paused = true
            isPaused = true
            pauseMenu = CCBReader.load("Scenes/PauseMenu", owner: self)
            self.addChild(pauseMenu)
        }
        
    }
    func restart() {
        var gamePlayScene = CCBReader.loadAsScene("Scenes/Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
    }
    func menu() {
        var mainMenu = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(mainMenu)
    }
    func resume() {
        ccPhysicsNode.paused = false
        isPaused = false
        //gameState = .Playing
        pauseButton.visible = true
    }
    
    var lives : Int = 5 {
        didSet {
            livesLeft.string = "\(lives)"
            if lives == 0 {
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("triggerGameOver"), userInfo: nil, repeats: false)
            }
            //3 strikes
//            if !strikesLoaded {
//                
//                strike1 = CCBReader.load("Apples/cone")
//                strike1.position = ccp(self.contentSizeInPoints.width / 4, self.contentSizeInPoints.height * 90 / 100)
//                scene.addChild(strike1)
//                
//                
//                strike2 = CCBReader.load("Apples/cone")
//                strike2.position = ccp(self.contentSizeInPoints.width / 2, self.contentSizeInPoints.height * 90 / 100)
//                scene.addChild(strike2)
//                
//                strike3 = CCBReader.load("Apples/cone")
//                strike3.position = ccp(self.contentSizeInPoints.width * 3 / 4, self.contentSizeInPoints.height * 90 / 100)
//                scene.addChild(strike3)
//                strikesLoaded = true
//            }
//            if lives == 0 {
//                strike1.opacity = 1
//                strike2.opacity = 1
//                strike3.opacity = 1
//            }
//            if lives == 1 {
//                strike1.opacity = 0.25
//                
//                //changes the other scoops because of minusOneX Powerup
//                strike2.opacity = 1
//                strike3.opacity = 1
//            }
//            if lives == 2 {
//                strike2.opacity = 0.25
//            }
//            if lives == 3 {
//                strike3.opacity = 0.25
//                
//                var timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("triggerGameOver"), userInfo: nil, repeats: false)
//                
//            }
        }
    }
    
    var score : Int = 0 {
        didSet {
            if score > highScore {
                highScore = score
                beatHighScore = true
            }
            scoreLabel.string = "\(score)"
            var dropSubtractFrequency = 2
            var appleSubtractFrequency = 2
            let random = CCRANDOM_0_1() * 200
            var gravitySubtractConstant = 40

            if score % 2 == 0 && !isInvincible{
                //spawnPowerUp()
                //spawnPowerUp()
                if ccPhysicsNode.gravity.y < -500 {
                    gravitySubtractConstant = 20
                }
                ccPhysicsNode.gravity.y -= CGFloat(gravitySubtractConstant)
                
//                if frequencyOfApples > 40 {
//                    if frequencyOfApples < 33 {
//                        appleSubtractFrequency = 1
//                    }
//                    frequencyOfApples -= appleSubtractFrequency
//                    
//                }
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
        
        //        println(lives)
        //        println(isPaused)
//        println(frequencyOfDrops)
//        println(ccPhysicsNode.gravity)
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
                    println(counter)
                    println(frequencyOfDrops)
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
                startInstructions.runAction(CCActionFadeOut(duration: 0.3))
                lives = 5
                //NSDate().timeIntervalSince1970
                pauseButton.visible = true
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
//
            let xPos = touch.locationInWorld().x
//            touchEndPos = touch.locationInWorld()
//            let distance = distanceBetweenTwoPoints(touchBeginPos, point2: touchEndPos)
//            touchEndTimestamp = NSDate().timeIntervalSince1970
//            let time = touchEndTimestamp - touchBeginTimestamp
//            var velocity : CGFloat = 0
//            if time != 0 {
//                velocity = distance  / CGFloat(time)
//            }
//            
        
            cone.position = CGPoint(x: xPos, y: cone.position.y)
    
            if particles != nil {
                particles.position = cone.position
            }
//            let powerupScoop = self.getChildByName("swipePowerup", recursively: false)
//            if powerupScoop != nil {
//                if CGRectContainsPoint(powerupScoop.boundingBox(), touch.locationInWorld()) {
//                    if velocity > 0.5 && powerupScoop != nil{
//                        
//                        powerupScoop.removeFromParent()
//                        print("removed")
//                        minusOneX()
//                        //insert animation here
//                    }
//                }
//            }
        }
        
    }
//    func distanceBetweenTwoPoints(point1 : CGPoint, point2 : CGPoint) ->CGFloat {
//        let xDistance = point1.x - point2.x
//        let yDistance = point1.y - point2.y
//        return sqrt(pow(xDistance, 2) + pow(yDistance, 2))
//    }
//    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        
//    }
    
    
    func spawnPowerUp() {
        let random = Int(CCRANDOM_0_1() * Float(3))
        
        var randX = CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - 50) + 25
//        if random == 0 {
//            let powerup = CCBReader.load("Powerups/explosionScoop") as! Powerup
//            // var randY = CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.height - 200) + 175
//            let y = self.contentSizeInPoints.height + 100
//            powerup.position = CGPoint(x: randX, y: y)
//            ccPhysicsNode.addChild(powerup)
//        }
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
    
//    func createApples() {
//        let apple = CCBReader.load("Apples/Apple")
//        var randomX = apple.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - apple.contentSizeInPoints.width)
//        while randomX < lastDropPosition.x + 50 && randomX > lastDropPosition.x - 50 {
//            randomX = apple.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - apple.contentSizeInPoints.width)
//        }
//        let launchDirection = CGPoint(x: 0, y: 1)
//        
//        //8000 is nice for starting out, 100000 is good for fast moving dots
//        var force = ccpMult(launchDirection, 80)
//        
//        var random = Int(CCRANDOM_0_1() * 100)
//        let y = self.contentSizeInPoints.height + 100
//        apple.position = CGPoint (x: randomX, y: y)
//        if random > 90 && score > 50 && counter > 500 {
//            var exclamation = CCBReader.load("Apples/exclamation")
//            self.addChild(exclamation)
//            exclamation.position = CGPoint(x: apple.position.x, y: self.contentSizeInPoints.height - 40)
//            force = ccpMult(launchDirection, -100000)
//        }
//        
//        
//        apple.physicsBody.applyForce(force)
//        lastApplePosition = apple.position
//        ccPhysicsNode.addChild(apple)
//    }
//    
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
//    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, coneCollision: CCSprite!, appleCollision: Apple!) {
//        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
//
//            if !self.isInvincible {
//                self.lives = max(self.lives - 1 , 0)
//            }
//            appleCollision.removeFromParent()
//            }, key: appleCollision)
//    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, scoopCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            if !self.isInvincible {
                self.lives = max(self.lives - 1 , 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            scoopCollision.removeFromParent()
            }, key: scoopCollision)
    }
//    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, appleCollision : Apple!) {
//        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
//            print("apple hit ground")
//            appleCollision.removeFromParent()
//            }, key: appleCollision)
//    }
//    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, explosionScoop : CCSprite!, coneCollision: CCSprite!) {
//        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
//            explosionScoop.removeFromParent()
//            self.explode()
//            }, key: explosionScoop)
//        
//    }
//    func explode() {
//        
//        for child in ccPhysicsNode.children {
//            if child as! NSObject != cone && child as! NSObject != ground && child as! NSObject != ground2{
//                score++
//                child.removeFromParent()
//            }
//            
//        }
//        counter = 0
//        var oldDropFrequency = frequencyOfDrops
//        var oldAppleFrequency = frequencyOfApples
//        ccPhysicsNode.gravity = CGPoint(x: 0, y: -300)
//        frequencyOfDrops = 30
//        //insert animation here
//        while frequencyOfDrops > oldDropFrequency {
//            if counter % 50 == 0 {
//                frequencyOfDrops -= 5
//            }
//        }
//        
//    }
//    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, explosionScoop : CCSprite!, ground: CCSprite!) {
//        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
//            explosionScoop.removeFromParent()
//            }, key: explosionScoop)
//        
//    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, invincibilityPowerup: Powerup!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            
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
            
        }, key: minusOneScoop)
        return true
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, minusOneScoop: Powerup!, ground: CCSprite!) -> Bool {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            minusOneScoop.removeFromParent()
            
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
            }, key: onePoint)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, onePoint: CCNode!, coneCollision: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            onePoint.physicsBody.collisionType = ""
            onePoint.physicsBody.type = .Static
            // if it is not exact
            let distance = onePoint.position.x - coneCollision.position.x
            if abs(distance) > 24 && !self.isInvincible {
                if distance < 0 {
                    onePoint.animationManager.runAnimationsForSequenceNamed("bounceOffLeft")
                } else {
                    onePoint.animationManager.runAnimationsForSequenceNamed("bounceOffRight")
                }
            
                self.lives = max(self.lives - 1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            else {
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
                if distance < 0 {
                    twoPoints.animationManager.runAnimationsForSequenceNamed("bounceOffLeft")
                } else {
                    twoPoints.animationManager.runAnimationsForSequenceNamed("bounceOffRight")
                }
                self.lives = max(self.lives-1, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
                
            }
            else {
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
                if distance < 0 {
                    threePoints.animationManager.runAnimationsForSequenceNamed("bounceOffLeft")
                } else {
                    threePoints.animationManager.runAnimationsForSequenceNamed("bounceOffRight")
                }
                self.lives = max(self.lives--, 0)
                self.animationManager.runAnimationsForSequenceNamed("Hit")
            }
            else {
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
        scoreLabel.visible = false
        ccPhysicsNode.paused = true
        cone.visible = false
        livesNode.visible = false
        
        var gameOverScene = CCBReader.load("Scenes/GameOver") as! GameOver
        gameOverScene.beatHighScore = beatHighScore
        gameOverScene.score = score
        gameOverScene.highScore = highScore
        
        self.addChild(gameOverScene)
        
    }
    
}

