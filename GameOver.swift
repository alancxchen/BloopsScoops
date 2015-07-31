//
//  GameOver.swift
//  Drops
//
//  Created by Alan on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class GameOver: CCNode {
    var scoreLabel: CCLabelTTF!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
        }
    }
    
    var restartButton: CCButton!
    func restart() {
        var gamePlayScene = CCBReader.loadAsScene("Scenes/Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
    }
    func didLoadFromCCB() {
   //     println("hi")
        restartButton.cascadeOpacityEnabled = true
        restartButton.runAction(CCActionFadeIn(duration: 0.3))
    }
}
