import Foundation
import Mixpanel

class MainScene: CCNode, CCPhysicsCollisionDelegate{
    var dropWidth : CGFloat = 50
    var lastDropPosition: CGPoint = CGPoint(x: 0, y: 0)
    weak var ccPhysicsNode: CCPhysicsNode!
    weak var ground: CCSprite!
    weak var ground2: CCSprite!
    var counter = 10
    var mixpanel = Mixpanel.sharedInstance()
    func didLoadFromCCB() {
        
        userInteractionEnabled = true
        ccPhysicsNode.collisionDelegate = self
    }
    override func update(delta: CCTime) {
     
        counter++
        if counter % 27 == 0 {
            createDrops()
        }
        ccPhysicsNode.gravity = CGPoint(x: 0, y: -50)
    }
    func play() {
        self.animationManager.runAnimationsForSequenceNamed("exit")
        mixpanel.track("ButtonPressed", properties: ["ButtonType": "Play"])
    }
    func transferScene() {
        let gamePlayScene = CCBReader.loadAsScene("Scenes/Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
        

    }
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, ground: CCSprite!, scoopCollision : Scoop!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            scoopCollision.removeFromParent()
            }, key: scoopCollision)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, onePoint: CCNode!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            onePoint.removeFromParent()
            }, key: onePoint)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, twoPoints: CCNode!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
                twoPoints.removeFromParent()
            }, key: twoPoints)
    }
    func ccPhysicsCollisionPostSolve (pair: CCPhysicsCollisionPair!, threePoints: CCNode!, ground: CCSprite!) {
        ccPhysicsNode.space.addPostStepBlock({ () -> Void in
            
            threePoints.removeFromParent()
            }, key: threePoints)
    }

    
    func createDrops() {
        let random = CCRANDOM_0_1() * 100

        var drop = CCBReader.load("Scoops/VanillaScoop")
        if random < 75 {
            drop = CCBReader.load("Scoops/MintScoop")
        }
        if random < 50 {
            drop = CCBReader.load("Scoops/PinkScoop")
        }
        if random < 25{
            drop = CCBReader.load("Scoops/ChocolateScoop")
        }
        
        //so that the drop isnt on the sides
        var randomX = dropWidth / 2 + CGFloat(CCRANDOM_0_1()) * (self.contentSizeInPoints.width - dropWidth)
        let launchDirection = CGPoint(x: 0, y: 1)
        let y = self.contentSizeInPoints.height + 100
        drop.position = CGPoint(x: randomX, y: y)
        lastDropPosition = drop.position
        var rand = CCRANDOM_0_1() * 200
        
        ccPhysicsNode.addChild(drop)
        var force = ccpMult(launchDirection, -10000)
        
        drop.physicsBody.applyForce(force)
    

    
    
    }
}