//
//  Gameplay.swift
//  Drops
//
//  Created by Alan on 7/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum GameState {
    case GameOver, Playing, Ready, Tutorial
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
    var frequencyOfDrops = 30
    var frequencyOfApples = 125
    var gravity : CGPoint = CGPoint (x: 0, y: 0)
    
    var gameState : GameState = .Ready
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        //ccPhysicsNode.debugDraw = true
        //Necessary for ccphysicsCollisionDelegate
        ccPhysicsNode.collisionDelegate = self
    }
    
    func pause() {
//        gravity = ccPhysicsNode.gravity
  //      ccPhysicsNode.gravity = CGPoint (x: 0,y: 0)
        
    }
    var scoopsHit : Int = 0 {
        didSet {
            var strike1 = CCBReader.load("Apple")
           
            strike1.position = ccp(85, 410)
            scene.addChild(strike1)
            //strike1.runAction(CCActionFadeIn(duration: 0.3))
            strike1.opacity = 0.25
            var strike2 = CCBReader.load("Apple")
            strike2.opacity = 0.25
            strike2.position = ccp(160, 410)
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
                
               // triggerGameOver()
            }
        }
    }
    var score : Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
            if score % 5 == 0 {
                ccPhysicsNode.gravity.y -= 50
                if frequencyOfDrops > 20 {
                    frequencyOfDrops -= 3
                    
                }
                if frequencyOfApples > 40 {
                    frequencyOfApples -= 4
                }
            }
        }
    }
    
    override func update(delta: CCTime) {
        if gameState == .Playing {
            counter++
          //  println(delta)
            duration = duration + CGFloat(delta)
          // allows us to set gravity
          //  println(ccPhysicsNode.gravity)
            //ccPhysicsNode.gravity.y -=50
            
            if counter % frequencyOfDrops == 0{
                createDrops()
                
            }
            if counter % frequencyOfApples == 0 && counter > 1250 {
                createApples()
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState == .Ready {
            gameState = .Playing
            startInstructions.runAction(CCActionFadeOut(duration: 0.3))
            scoopsHit = 0
        }
        let xPos = touch.locationInWorld().x
   //   let yPos = touch.locationInWorld().y
        println("original \(cone.position.x) \(cone.position.y)")
        cone.position = CGPoint(x: xPos, y: cone.position.y)
        //cone.position = ccp(cone.position.x+10,cone.position.y)
        println("new : \(cone.position.x)  \(cone.position.y)")
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let xPos = touch.locationInWorld().x
        //   let yPos = touch.locationInWorld().y
        println("original \(cone.position.x) \(cone.position.y)")
        cone.position = CGPoint(x: xPos, y: cone.position.y)
        //cone.position = ccp(cone.position.x+10,cone.position.y)
        println("new : \(cone.position.x)  \(cone.position.y)")
    }
    //spawns drops and drops them
    func createDrops() {
        let drop = CCBReader.load("Scoop")
        
        //so that the drop isnt on the sides
        let randomX = drop.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - drop.contentSizeInPoints.width)
 //       let randomY = self.contentSizeInPoints.height + 100 + CGFloat(CCRANDOM_0_1()) * yScaleValue
        let y = self.contentSizeInPoints.height + 100
        drop.position = CGPoint(x: randomX, y: y)
        ccPhysicsNode.addChild(drop)
        
        //drop.physicsBody.sensor = true
        //drop.physicsBody.collisionMask = ["scoop"]
    }
    func createApples() {
        let apple = CCBReader.load("Apple")
        let randomX = apple.contentSizeInPoints.width / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - apple.contentSizeInPoints.width)
        let y = self.contentSizeInPoints.height + 100
        apple.position = CGPoint (x: randomX, y: y)
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
        
        //update score
        
        
        return true
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, coneCollision: CCSprite!, appleCollision: Apple!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            
            self.scoopsHit++
            appleCollision.removeFromParent()
            }, key: appleCollision)
    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, scoopCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
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
