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
//    var physicsChildArray : [AnyObject] = []
    var strike1 : Apple!
    var strike2 : CCNode!
    var strike3 : CCNode!
    
    
//    var lifeLeft : Float = 10 {
//        didSet {
//            lifeLeft = max(min (lifeLeft, 10), 0)
//            lifeBar.scaleX =   lifeLeft / Float(10)
//            
//        }
//    }
    
    
//    var savedPhysicsNode : CCPhysicsNode!
//    var isPaused = false
    func didLoadFromCCB() {
        CCDirector.sharedDirector().resume()
        gameState = .Ready
        userInteractionEnabled = true
        //ccPhysicsNode.debugDraw = true
        //Necessary for ccphysicsCollisionDelegate
        ccPhysicsNode.collisionDelegate = self
        ccPhysicsNode.gravity = CGPoint(x: 0, y: -200)
        
        //pauseButton.opacity = 0
        //center the cone
        //cone.position = CGPoint(x: self.contentSizeInPoints.width / 2, y: cone.position.y)
    }
    override func onEnter() {
        super.onEnter()
        var coneX = self.contentSizeInPoints.width / 2
        cone.position = CGPoint(x: coneX, y: cone.position.y)
    }
    func pause() {
        
        if gameState == .Paused {
//            ccPhysicsNode = savedPhysicsNode
            gameState = .Playing
            CCDirector.sharedDirector().resume()
//            isPaused = false
//            for(var i = physicsChildArray.count - 1 ; i >= 0; i--) {
//                ccPhysicsNode.addChild(physicsChildArray[i] as! CCNode)
//            }
        } else {
            gameState = .Paused
            CCDirector.sharedDirector().pause()
//            savedPhysicsNode = ccPhysicsNode
            
//            var children = ccPhysicsNode.children
//            for child in children {
//                //                var copy = child
//                
//                physicsChildArray.append(child)
//                child.removeFromParent()
//                self.addChild(child as! CCNode)
//            }
        }
    }
    var scoopsHit : Int = 0 {
        didSet {
//// lifeBar     
//            if lifeLeft == 0 {
//                var timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("triggerGameOver"), userInfo: nil, repeats: false)
//            }
//            if scoopsHit > 0 {
//                lifeLeft -= 3.5
//            }
            
            
            
 //3 strikes
            if scoopsHit == 0 {
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
            }
            if scoopsHit == 1 {
                strike1.opacity = 1
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
            if score % 5 == 0 {
                ccPhysicsNode.gravity.y -= 40
                if frequencyOfDrops > 25 {
                    frequencyOfDrops -= 2
                    
                }
                if frequencyOfApples > 40 {
                    frequencyOfApples -= 2
                }
            }
           // lifeLeft += 0.25
        }
    }
    
    override func update(delta: CCTime) {
        if gameState != .Paused && gameState != .GameOver {
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
        if gameState != .Paused && gameState != .GameOver {
            if gameState == .Ready {
                gameState = .Playing
                startInstructions.runAction(CCActionFadeOut(duration: 0.3))
                scoopsHit = 0
               
                pauseButton.visible = true
                pauseButton.opacity = 0
                pauseButton.runAction(CCActionFadeIn(duration: 0.3))
            }
            let xPos = touch.locationInWorld().x
            println("original \(cone.position.x) \(cone.position.y)")
            
            cone.position = CGPoint(x: xPos, y: cone.position.y)
            
            println("new : \(cone.position.x)  \(cone.position.y)")
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState != .Paused && gameState != .GameOver{
            let xPos = touch.locationInWorld().x
            
           // println("original \(cone.position.x) \(cone.position.y)")
            
            cone.position = CGPoint(x: xPos, y: cone.position.y)
            
           // println("new : \(cone.position.x)  \(cone.position.y)")
        }
    }
    
    //spawns drops and drops them
    func createDrops() {
        let drop = CCBReader.load("Scoop")
        
        //so that the drop isnt on the sides
        var randomX = drop.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - drop.contentSizeInPoints.width)
        while randomX < lastApplePosition.x + 50 && randomX > lastApplePosition.x - 50 {
            randomX = drop.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - drop.contentSizeInPoints.width)
        }
        let launchDirection = CGPoint(x: 0, y: 1)
        let y = self.contentSizeInPoints.height + 100
        var force = ccpMult(launchDirection, 8000)
        drop.position = CGPoint(x: randomX, y: y)
        var random = Int(CCRANDOM_0_1() * 100)
        
        if random < 3 && score > 30 && counter > 300 {
            let powerup = CCBReader.load("powerupScoop1")
           // self.addChild(powerup)
            var randX = CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - 50) + 25
           // var randY = CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.height - 200) + 175
            let y = self.contentSizeInPoints.height + 100
            powerup.position = CGPoint(x: randX, y: y)
            ccPhysicsNode.addChild(powerup)

        }
        
        ccPhysicsNode.addChild(drop)
        lastDropPosition = drop.position
        drop.physicsBody.applyForce(force)
        
        //drop.physicsBody.sensor = true
        //drop.physicsBody.collisionMask = ["scoop"]
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
    func slowDownTime() {
        counter = 0
        var oldDropFrequency = frequencyOfDrops
        var oldAppleFrequency = frequencyOfApples
        gravity = CGPoint(x: 0, y: -200)
        frequencyOfDrops = 40
        for child in ccPhysicsNode.children {
            if child as! NSObject != cone && child as! NSObject != ground{
                child.removeFromParent()
            }
        }
        //insert animation here
        while frequencyOfDrops < oldDropFrequency {
            if counter % 50 == 0 {
                frequencyOfDrops -= 5
//                gravity = CGPoint(x: 0, y: gravity.y - 100)
            }
        }
        
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, powerupScoop1 : CCSprite!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            powerupScoop1.removeFromParent()
            }, key: powerupScoop1)
        
    }
  
    
    func triggerGameOver() {
        gameState = .GameOver
        // give the game over menu

//        strike1.removeAllChildren()
        strike1.removeFromParent()
        strike2.removeFromParent()
        strike3.removeFromParent()
        pauseButton.visible = false
        scoreLabel.visible = false
        CCDirector.sharedDirector().pause()
    
        var gameOverScene = CCBReader.load("GameOver") as! GameOver
        gameOverScene.score = score
        self.addChild(gameOverScene)
        
        
        
//        var gameOverScene = CCBReader.load("GameOver") as! GameOver
//        var newScene : CCScene = CCScene()
//        newScene.addChild(gameOverScene)
//        gameOverScene.score = score
//        CCDirector.sharedDirector().presentScene(newScene)
        //
    }
    
}
