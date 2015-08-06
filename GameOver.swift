//
//  GameOver.swift
//  Drops
//
//  Created by Alan on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class GameOver: CCNode {
    var notHighScoreNode : CCNode!
    var scoreLabel: CCLabelTTF!
    var highScoreLabel: CCLabelTTF!
    var beatHighScore = false
    var newBestLabel : CCLabelTTF!
    var newBestNode: CCNode!
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
}
