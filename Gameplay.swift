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
    var physicsChildArray : [AnyObject] = []
//    var savedPhysicsNode : CCPhysicsNode!
//    var isPaused = false
    func didLoadFromCCB() {
        userInteractionEnabled = true
        //ccPhysicsNode.debugDraw = true
        //Necessary for ccphysicsCollisionDelegate
        ccPhysicsNode.collisionDelegate = self
        ccPhysicsNode.gravity = CGPoint(x: 0, y: -200)
        pauseButton.opacity = 0
        //center the cone
        //cone.position = CGPoint(x: self.contentSizeInPoints.width / 2, y: cone.position.y)
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
            var strike1 = CCBReader.load("Apple")
            strike1.position = ccp(85, 410)
            strike1.opacity = 0.25
            scene.addChild(strike1)
            
            
            var strike2 = CCBReader.load("Apple")
            strike2.position = ccp(160, 410)
            strike2.opacity = 0.25
            scene.addChild(strike2)
            
            var strike3 = CCBReader.load("Apple")
            strike3.position = ccp(235, 410)
            strike3.opacity = 0.25
            scene.addChild(strike3)
            
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
        }
    }
    
    override func update(delta: CCTime) {
        if gameState != .Paused {
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
        if gameState != .Paused {
            if gameState == .Ready {
                gameState = .Playing
                startInstructions.runAction(CCActionFadeOut(duration: 0.3))
                scoopsHit = 0
                pauseButton.runAction(CCActionFadeIn(duration: 0.3))
            }
            let xPos = touch.locationInWorld().x
            println("original \(cone.position.x) \(cone.position.y)")
            
            cone.position = CGPoint(x: xPos, y: cone.position.y)
            
            println("new : \(cone.position.x)  \(cone.position.y)")
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState != .Paused {
            let xPos = touch.locationInWorld().x
            
            println("original \(cone.position.x) \(cone.position.y)")
            
            cone.position = CGPoint(x: xPos, y: cone.position.y)
            
            println("new : \(cone.position.x)  \(cone.position.y)")
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
 //     let randomY = self.contentSizeInPoints.height + 100 + CGFloat(CCRANDOM_0_1()) * yScaleValue
        let y = self.contentSizeInPoints.height + 100
        drop.position = CGPoint(x: randomX, y: y)
        let launchDirection = CGPoint(x: 0, y: 1)
        //8000 is nice for starting out, 100000 is good for fast moving dots
        var force = ccpMult(launchDirection, 8000)
        var random = Int(CCRANDOM_0_1() * 100)
        if random > 90 && score > 30 {
            var exclamation = CCBReader.load("exclamation")
            self.addChild(exclamation)
            exclamation.position = CGPoint(x: drop.position.x, y: self.contentSizeInPoints.height - 40)
            force = ccpMult(launchDirection, -100000)
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
        let y = self.contentSizeInPoints.height + 100
        apple.position = CGPoint (x: randomX, y: y)
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
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, appleCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            println("apple hit ground")
            appleCollision.removeFromParent()
            }, key: appleCollision)
    }
    
    
    func triggerGameOver() {
        gameState = .GameOver
        // give the game over menu
//        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
//        gameOverScreen.score = score
//        self.addChild(gameOverScreen)
        
        var gameOverScene = CCBReader.load("GameOver") as! GameOver
        var newScene : CCScene = CCScene()
        newScene.addChild(gameOverScene)
        gameOverScene.score = score
        CCDirector.sharedDirector().presentScene(newScene)
        //
    }
    
}
