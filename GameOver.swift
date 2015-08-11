//
//  GameOver.swift
//  Drops
//
//  Created by Alan on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel
class GameOver: CCNode {
    var notHighScoreNode : CCNode!
    var scoreLabel: CCLabelTTF!
    var highScoreLabel: CCLabelTTF!
    var beatHighScore = false
    var newBestLabel : CCLabelTTF!
    var newBestNode: CCNode!
    var infoLayer : CCNode!
    var infoVisible = false
    var mixpanel = Mixpanel.sharedInstance()
    var score: Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
        }
    }
    var highScore: Int = 0 {
        didSet {
            if beatHighScore {
                notHighScoreNode.visible = false
                newBestNode.visible = true
            }
            newBestLabel.string = "\(highScore)"
            highScoreLabel.string = "\(highScore)"
        }
    }
    
    var restartButton: CCButton!
    func changeScene() {
        var gamePlayScene = CCBReader.loadAsScene("Scenes/Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
    }
    func restart() {
        
        self.animationManager.runAnimationsForSequenceNamed("exit")
    }
    func didLoadFromCCB() {

        restartButton.cascadeOpacityEnabled = true
        restartButton.runAction(CCActionFadeIn(duration: 0.3))
    }
    
    func info() {
        if !infoVisible {
            infoLayer = CCBReader.load("Scenes/credits", owner: self)
            self.addChild(infoLayer)
            infoVisible = true
        }
    }
    func back() {
        
        infoLayer.animationManager.runAnimationsForSequenceNamed("exit")
        infoVisible = false
    }

    func shareButtonTapped() {
        var scene = CCDirector.sharedDirector().runningScene
        var node: AnyObject = scene.children[0]
        var screenshot = screenShotWithStartNode(node as! CCNode)
        
        let sharedText = "Check out this cool game yo!"
        let itemsToShare = [screenshot, sharedText]
        
        var excludedActivities = [ UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList, UIActivityTypePostToTencentWeibo]
        
        var controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        if controller.respondsToSelector(Selector("popoverPresentationController")) {
            controller.popoverPresentationController?.sourceView = UIApplication.sharedApplication().keyWindow?.rootViewController?.view
        }
        controller.excludedActivityTypes = excludedActivities
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)

    }
    
    func screenShotWithStartNode(node: CCNode) -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        var viewSize = CCDirector.sharedDirector().viewSize()
        var rtx = CCRenderTexture(width: Int32(viewSize.width), height: Int32(viewSize.height))
        rtx.begin()
        node.visit()
        rtx.end()
        return rtx.getUIImage()
    }
}
