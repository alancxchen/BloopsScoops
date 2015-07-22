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
    weak var one : CCLabelTTF!
    weak var two : CCLabelTTF!
    weak var three : CCLabelTTF!
    weak var go : CCLabelTTF!
    
    
    var yScaleValue : CGFloat = 200
    var counter = 0
    var duration : CGFloat = 0
    
    //less -> more drops
    var frequencyOfDrops = 40
    var frequencyOfApples = 125
    
    var gravity : CGPoint = CGPoint (x: 0, y: 0)
    
    var lastDropPosition = CGPoint(x: 0, y: 0)
    var lastApplePosition = CGPoint (x: 0, y: 0)
    
    var gameState : GameState = .Ready
    var strike1 : Apple!
    var strike2 : CCNode!
    var strike3 : CCNode!
//    var powerupRect : CGRect!
    
    var pauseMenu : CCNode!
//    var powerupInCounter = 0
    var isPaused = false
    
    var touchBeginPos : CGPoint!
    var touchEndPos : CGPoint!
    var touchBeginTimestamp : NSTimeInterval!
    var touchEndTimestamp : NSTimeInterval!
    var strikesLoaded = false

    func didLoadFromCCB() {
        CCDirector.sharedDirector().resume()
        gameState = .Ready
        userInteractionEnabled = true
        
        //Necessary for ccphysicsCollisionDelegate
        ccPhysicsNode.collisionDelegate = self
        ccPhysicsNode.gravity = CGPoint(x: 0, y: -200)
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
            pauseMenu = CCBReader.load("PauseMenu", owner: self)
            self.addChild(pauseMenu)
        }

    }
    func restart() {
        var gamePlayScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
    }
    func menu() {
        var mainMenu = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(mainMenu)
    }
    func resume() {
        ccPhysicsNode.paused = false
        isPaused = false
        pauseButton.visible = true
    }
    
    var scoopsHit : Int = 0 {


        didSet {
 //3 strikes
            if !strikesLoaded {
                strike1 = CCBReader.load("Apple") as! Apple!
                strike1.position = ccp(self.contentSizeInPoints.width / 4, self.contentSizeInPoints.height * 90 / 100)
                strike1.opacity = 0.25
                scene.addChild(strike1)
                
                strike2 = CCBReader.load("Apple")
                strike2.position = ccp(self.contentSizeInPoints.width / 2, self.contentSizeInPoints.height * 90 / 100)
                strike2.opacity = 0.25
                scene.addChild(strike2)
                
                strike3 = CCBReader.load("Apple")
                strike3.position = ccp(self.contentSizeInPoints.width * 3 / 4, self.contentSizeInPoints.height * 90 / 100)
                strike3.opacity = 0.25
                scene.addChild(strike3)
                strikesLoaded = true
            }
            if scoopsHit == 0 {
                strike1.opacity = 0.25
                strike2.opacity = 0.25
                strike3.opacity = 0.25
            }
            if scoopsHit == 1 {
                strike1.opacity = 1
                
                //changes the other scoops because of minusOneX Powerup
                strike2.opacity = 0.25
                strike3.opacity = 0.25
            }
            if scoopsHit == 2 {
               strike2.opacity = 1
            }
            if scoopsHit == 3 {
                strike3.opacity = 1
                
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("triggerGameOver"), userInfo: nil, repeats: false)
                
            }
        }
    }
    
    var score : Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
            var dropSubtractFrequency = 2
            var appleSubtractFrequency = 2
            let random = CCRANDOM_0_1() * 100
            var gravitySubtractConstant = 40
            if random < 2 {
                spawnPowerUp()
            }
            if score % 5 == 0 {
                spawnPowerUp()
                if ccPhysicsNode.gravity.y < -550 {
                    gravitySubtractConstant = 20
                }
                ccPhysicsNode.gravity.y -= CGFloat(gravitySubtractConstant)
                if frequencyOfDrops > 25 {
                    if frequencyOfDrops < 33 {
                        dropSubtractFrequency = 1
                    }
                    frequencyOfDrops -= dropSubtractFrequency
                    
                }
                if frequencyOfApples > 40 {
                    if frequencyOfApples < 33 {
                        appleSubtractFrequency = 1
                    }
                    frequencyOfApples -= appleSubtractFrequency
                }
            }
           
        }
    }
    
    override func update(delta: CCTime) {
        println(scoopsHit)
//        println(isPaused)
//        println(ccPhysicsNode.gravity)
        if gameState != .Paused && gameState != .GameOver && !isPaused {
            if gameState == .Playing {
                counter++
                duration = duration + CGFloat(delta)
                
                if counter % frequencyOfDrops == 0{
                    createDrops()
                    
                }
                if counter % frequencyOfApples == 0 && counter > 750 {
                    createApples()
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
                scoopsHit = 0
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
            let xPos = touch.locationInWorld().x
            touchEndPos = touch.locationInWorld()
            let distance = distanceBetweenTwoPoints(touchBeginPos, point2: touchEndPos)
            touchEndTimestamp = NSDate().timeIntervalSince1970
            let time = touchEndTimestamp - touchBeginTimestamp
            var velocity : CGFloat = 0
            if time != 0 {
                velocity = distance  / CGFloat(time)
                println(velocity)
            }

            cone.position = CGPoint(x: xPos, y: cone.position.y)
            let powerupScoop = self.getChildByName("swipePowerup", recursively: false)
            if powerupScoop != nil {
                if CGRectContainsPoint(powerupScoop.boundingBox(), touch.locationInWorld()) {
                    if velocity > 2 && powerupScoop != nil{

                        powerupScoop.removeFromParent()
                        println("removed")
                        minusOneX()
                        //insert animation here
                    }
                }
            }
        }
        
    }
    func distanceBetweenTwoPoints(point1 : CGPoint, point2 : CGPoint) ->CGFloat {
        let xDistance = point1.x - point2.x
        let yDistance = point1.y - point2.y
        return sqrt(pow(xDistance, 2) + pow(yDistance, 2))
    }
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
 
    }
    
    
    func spawnPowerUp() {
        let random = Int(CCRANDOM_0_1() * Float(2))
        
        var randX = CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - 50) + 25
        if random == 0 {
            let powerup = CCBReader.load("powerupScoop1") as! Powerup
            // var randY = CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.height - 200) + 175
            let y = self.contentSizeInPoints.height + 100
            powerup.position = CGPoint(x: randX, y: y)
            ccPhysicsNode.addChild(powerup)
        }
        if random == 1 {
            let powerup = CCBReader.load("powerupScoop2") as! Powerup
            let halfScreenHeight = self.contentSizeInPoints.height / 2
            let y = CGFloat(CCRANDOM_0_1()) * (halfScreenHeight - 50) + halfScreenHeight
            //powerupInCounter = counter
            powerup.position = CGPoint(x: randX, y: y)
//            powerupRect = CGRect(x: randX - powerup.contentSizeInPoints.height / 2, y: y -  powerup.contentSizeInPoints.height / 2, width: powerup.contentSizeInPoints.width, height: powerup.contentSizeInPoints.height)
            self.addChild(powerup, z: 100, name: "swipePowerup")

        }
    }
    
    //spawns drops and drops them
    func createDrops() {
        let random = CCRANDOM_0_1() * 100
       // println(random)
        var drop = CCBReader.load("Scoop")
        if random < 80 {
           // drop = CCBReader.load("Scoop")
        }
        if random > 80 && random < 95 {
            drop = CCBReader.load("greenScoop")
            
        }
        if random > 95 {
            drop = CCBReader.load("purpleScoop")
        }
        if score < 10 {
            drop = CCBReader.load("Scoop")
        }
        //so that the drop isnt on the sides
        var randomX = drop.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - drop.contentSizeInPoints.width)
        while randomX < lastApplePosition.x + 50 && randomX > lastApplePosition.x - 50 {
            randomX = drop.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - drop.contentSizeInPoints.width)
        }
        let launchDirection = CGPoint(x: 0, y: 1)
        let y = self.contentSizeInPoints.height + 100
        var force = ccpMult(launchDirection, -10000)
        drop.position = CGPoint(x: randomX, y: y)
        
        ccPhysicsNode.addChild(drop)
        lastDropPosition = drop.position
        drop.physicsBody.applyForce(force)
    }
    
    func createApples() {
        let apple = CCBReader.load("Apple")
        var randomX = apple.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - apple.contentSizeInPoints.width)
        while randomX < lastDropPosition.x + 50 && randomX > lastDropPosition.x - 50 {
            randomX = apple.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - apple.contentSizeInPoints.width)
        }
        let launchDirection = CGPoint(x: 0, y: 1)
        
        //8000 is nice for starting out, 100000 is good for fast moving dots
        var force = ccpMult(launchDirection, 80)
        
        var random = Int(CCRANDOM_0_1() * 100)
        let y = self.contentSizeInPoints.height + 100
        apple.position = CGPoint (x: randomX, y: y)
        if random > 90 && score > 50 && counter > 500 {
            var exclamation = CCBReader.load("exclamation")
            self.addChild(exclamation)
            exclamation.position = CGPoint(x: apple.position.x, y: self.contentSizeInPoints.height - 40)
            force = ccpMult(launchDirection, -100000)
        }
        
        
        apple.physicsBody.applyForce(force)
        lastApplePosition = apple.position
        ccPhysicsNode.addChild(apple)
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
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, coneCollision: CCSprite!, greenScoopCollision: Scoop!) -> Bool {
        //make sure its the right color
        //animate it so that it dissappears only once
        //swift bridging header #import "CCPhysics+ObjectiveChipmunk.h" necessary
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            self.scoopRemoved(greenScoopCollision)
            self.score += 2
            }, key: greenScoopCollision)
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
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, coneCollision: CCSprite!, appleCollision: Apple!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            //debugging apple movement
            self.scoopsHit++
            appleCollision.removeFromParent()
            }, key: appleCollision)
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, scoopCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            //Debugging apple movement
            self.scoopsHit++
            scoopCollision.removeFromParent()
            }, key: scoopCollision)
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, appleCollision : Apple!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            println("apple hit ground")
            appleCollision.removeFromParent()
            }, key: appleCollision)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, powerupScoop1 : CCSprite!, coneCollision: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            powerupScoop1.removeFromParent()
            self.slowDownTime()
            }, key: powerupScoop1)
        
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, greenScoopCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            //Debugging apple movement
            self.scoopsHit++
            greenScoopCollision.removeFromParent()
            }, key: greenScoopCollision)
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, purpleScoopCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            //Debugging apple movement
            self.scoopsHit++
            purpleScoopCollision.removeFromParent()
            }, key: purpleScoopCollision)
    }
    func slowDownTime() {
     
        for child in ccPhysicsNode.children {
            if child as! NSObject != cone && child as! NSObject != ground{
                score++
                child.removeFromParent()
            }

        }
        counter = 0
        var oldDropFrequency = frequencyOfDrops
        var oldAppleFrequency = frequencyOfApples
        ccPhysicsNode.gravity = CGPoint(x: 0, y: -100)
        frequencyOfDrops = 40
        //insert animation here
        while frequencyOfDrops < oldDropFrequency {
            if counter % 50 == 0 {
                frequencyOfDrops -= 5
            }
        }
        
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, powerupScoop1 : CCSprite!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            powerupScoop1.removeFromParent()
            }, key: powerupScoop1)
        
    }
    func minusOneX(){
        scoopsHit = max(scoopsHit - 1, 0)
    }
    
    func triggerGameOver() {
        gameState = .GameOver
        // give the game over menu
        strike1.removeFromParent()
        strike2.removeFromParent()
        strike3.removeFromParent()
        pauseButton.visible = false
        scoreLabel.visible = false
        CCDirector.sharedDirector().pause()
    
        var gameOverScene = CCBReader.load("GameOver") as! GameOver
        gameOverScene.score = score
        self.addChild(gameOverScene)

    }
    
}
